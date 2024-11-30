defmodule LocalHospitalService.NdbSyncronization.Consumer do
  @moduledoc """
  This module is responsible for synchronizing the local database with the NDB API.
  """

  use GenServer

  require Logger

  # TODO: Pick from config
  @queue_name "testing_queue_elixir"

  @doc """
  Called by the supervisor to start process.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_init_args) do
    # TODO: Connection url
    {:ok, conn} = AMQP.Connection.open()
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

  @impl true
  def handle_info(
        {:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}} = _meta,
        state
      ) do
    # You might want to run payload consumption in separate Tasks in production
    consume(state.channel, tag, redelivered, payload)

    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("Terminating #{__MODULE__} with reason: #{inspect(reason)}")
    AMQP.Channel.close(state.channel)
    AMQP.Connection.close(state.conn)
    :ok
  end

  defp consume(channel, tag, _redelivered, payload) do
    # TODO: Do something with the payload
    Logger.info("Received message: #{inspect(payload)}")

    :ok = AMQP.Basic.ack(channel, tag)
    # :ok = AMQP.Basic.reject(channel, tag, requeue: true)
  rescue
    # You might also want to catch :exit signal in production code.
    # Make sure you call ack, nack or reject otherwise consumer will stop
    # receiving messages.
    _exception ->
      :ok = AMQP.Basic.reject(channel, tag, requeue: true)
  end
end
