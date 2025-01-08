defmodule LocalHospitalService.NdbSyncronization.Consumer do
  @moduledoc """
  This module is responsible for synchronizing the local database with the NDB API.
  """

  use GenServer

  require Logger

  @doc """
  Called by the supervisor to start process.
  """
  def start_link([connection: _, queue_name: _] = init_args) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @impl true
  def init(connection: connection, queue_name: queue_name) do
    {:ok, channel} = AMQP.Channel.open(connection)

    # Limit unacknowledged messages to 10
    :ok = AMQP.Basic.qos(channel, prefetch_count: 10)

    AMQP.Basic.consume(channel, queue_name)
    Logger.info("#{__MODULE__} starting consuming from queue #{queue_name}")

    {:ok, %{channel: channel}}
  end

  @impl true
  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, _}, state) do
    {:noreply, state}
  end

  @impl true
  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, _}, state) do
    {:stop, :normal, state}
  end

  @impl true
  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, _}, state) do
    {:noreply, state}
  end

  @doc """
  Handles incoming messages from RabbitMQ.
  """
  @impl true
  def handle_info(
        {:basic_deliver, payload, %{delivery_tag: tag, redelivered: _redelivered}} = _meta,
        state
      ) do
    case Jason.decode(payload, keys: :atoms) do
      {:ok, %{type: "condition", data: unstructed_condition}} ->
        consume(
          state.channel,
          tag,
          LocalHospitalService.Conditions.Condition,
          unstructed_condition,
          &LocalHospitalService.Conditions.Condition.struct!/2,
          &LocalHospitalService.Api.Condition.create/1
        )

      {:ok, %{type: "medication_request", data: unstructed_medication_request}} ->
        consume(
          state.channel,
          tag,
          LocalHospitalService.MedicationRequests.MedicationRequest,
          unstructed_medication_request,
          &LocalHospitalService.MedicationRequests.MedicationRequest.struct!/2,
          &LocalHospitalService.Api.MedicationRequest.create/1
        )

      {:ok, %{type: "observation", data: unstructed_observation}} ->
        consume(
          state.channel,
          tag,
          LocalHospitalService.Observations.Observation,
          unstructed_observation,
          &LocalHospitalService.Observations.Observation.struct!/2,
          &LocalHospitalService.Api.Observation.create/1
        )

      {:ok, %{type: "patient", data: unstructed_patient}} ->
        consume(
          state.channel,
          tag,
          LocalHospitalService.Hospital.Patient,
          unstructed_patient,
          &LocalHospitalService.Hospital.Patient.struct!/2,
          &LocalHospitalService.Api.Patient.create/1
        )

      {:ok, decoded} ->
        Logger.warning("Received unknown payload from RabbitMQ: #{inspect(decoded)}")
        :ok = AMQP.Basic.reject(state.channel, tag, requeue: false)

      {:error, error = %Jason.DecodeError{}} ->
        Logger.warning(
          "Failed to decode payload from RabbitMQ: #{inspect(payload)}. Error: #{inspect(error)}"
        )

        :ok = AMQP.Basic.reject(state.channel, tag, requeue: false)
    end

    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("Terminating #{__MODULE__} with reason: #{inspect(reason)}")
    AMQP.Channel.close(state.channel)
    :ok
  end

  # Tries to struct and then consume a certain payload.
  # The payload is passed as an unstructured map, along with the desired struct to be created.
  # If the structuring process succeeds, the callback function is called with the structured payload.
  # Otherwise, the payload is rejected and not requeued.
  defp consume(channel, tag, target_struct, unstructed, struct!, cb) do
    try do
      struct!.(target_struct, unstructed)
      |> cb.()
      |> case do
        {:ok, _} ->
          :ok = AMQP.Basic.ack(channel, tag)

        # The only condition to requeue a message if the connection is failed
        {:error, :econnrefused} ->
          :ok = AMQP.Basic.reject(channel, tag, requeue: true)

        {:error, err} ->
          raise err
      end
    rescue
      # Here something went wrong on either sending the request or receiving the response. The payload should not be requeued.
      err ->
        Logger.warning("Failed to consume payload. Error: #{inspect(err)}")
        :ok = AMQP.Basic.reject(channel, tag, requeue: false)
    end
  end
end
