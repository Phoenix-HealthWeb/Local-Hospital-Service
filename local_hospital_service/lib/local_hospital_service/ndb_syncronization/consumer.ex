defmodule LocalHospitalService.NdbSyncronization.Consumer do
  @moduledoc """
  This module is responsible for synchronizing the local database with the NDB API.
  """

  use GenServer

  require Logger

  @queue_name Application.compile_env!(
                :local_hospital_service,
                LocalHospitalService.NdbSyncronization
              )[:queue_name]

  @doc """
  Called by the supervisor to start process.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_init_args) do
    rabbit_host =
      Application.get_env(:local_hospital_service, LocalHospitalService.NdbSyncronization)[
        :rabbit_host
      ]

    {:ok, conn} =
      AMQP.Connection.open(host: rabbit_host)

    {:ok, channel} = AMQP.Channel.open(conn)
    {:ok, queue} = AMQP.Queue.declare(channel, @queue_name, durable: true)

    # Limit unacknowledged messages to 10
    :ok = AMQP.Basic.qos(channel, prefetch_count: 10)

    AMQP.Basic.consume(channel, @queue_name)
    Logger.info("#{__MODULE__} starting consuming from queue #{@queue_name}")

    {:ok, %{conn: conn, channel: channel, queue: queue}}
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
    # TODO: You might want to run payload consumption in separate Tasks in production
    case Jason.decode(payload, keys: :atoms) do
      {:ok, %{type: "condition", data: unstructed_condition}} ->
        consume(
          state.channel,
          tag,
          LocalHospitalService.Dto.Condition,
          unstructed_condition,
          fn condition ->
            Logger.info("Consuming Condition: #{inspect(condition)}")
          end
        )

      {:ok, %{type: "medication_request", data: unstructed_medication_request}} ->
        consume(
          state.channel,
          tag,
          LocalHospitalService.Dto.MedicationRequest,
          unstructed_medication_request,
          fn medication_request ->
            Logger.info("Consuming Medication Request: #{inspect(medication_request)}")
          end
        )

      {:ok, %{type: "observation", data: unstructed_observation}} ->
        consume(
          state.channel,
          tag,
          LocalHospitalService.Dto.Observation,
          unstructed_observation,
          fn observation ->
            Logger.info("Consuming Observation: #{inspect(observation)}")
          end
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
    AMQP.Connection.close(state.conn)
    :ok
  end

  # Tries to struct and then consume a certain payload.
  # The payload is passed as an unstructured map, along with the desired struct to be created.
  # If the structuring process succeeds, the callback function is called with the structured payload.
  # Otherwise, the payload is rejected and not requeued.
  defp consume(channel, tag, target_struct, unstructed, cb) do
    # Try to structure the payload, and handle if it fails
    structed_res =
      try do
        {:ok, struct!(target_struct, unstructed)}
      rescue
        exception -> {:error, exception}
      end

    case structed_res do
      {:ok, structed} ->
        try do
          cb.(structed)

          :ok = AMQP.Basic.ack(channel, tag)
        rescue
          # Here the payload is well-formed but the consumption process failed. It should be requeued
          _ -> :ok = AMQP.Basic.reject(channel, tag, requeue: true)
        end

      # In case of structuring failure, the payload is malformed and should not be requeued
      {:error, exception} ->
        Logger.warning(
          "Failed to struct payload: #{inspect(unstructed)} to #{target_struct}. Error: #{inspect(exception)}"
        )

        :ok = AMQP.Basic.reject(channel, tag, requeue: false)
    end
  end
end
