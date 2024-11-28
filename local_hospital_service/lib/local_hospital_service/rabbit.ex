defmodule LocalHospitalService.Rabbit do
  use GenServer

  require Logger

  # TODO: Pick from config
  @queue_name "testing_queue_elixir"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_init_args) do
    {:ok, conn} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(conn)
    {:ok, queue} = AMQP.Queue.declare(channel, @queue_name, durable: true)

    # Limit unacknowledged messages to 10
    :ok = AMQP.Basic.qos(channel, prefetch_count: 10)

    AMQP.Basic.consume(channel, @queue_name)

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
    Logger.info("Received message: #{inspect(payload)}")
    # You might want to run payload consumption in separate Tasks in production
    consume(state.channel, tag, redelivered, payload)

    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("Terminating Rabbit GenServer with reason: #{inspect(reason)}")
    AMQP.Connection.close(state.conn)
    :ok
  end

  defp consume(channel, tag, _redelivered, _payload) do
    # TODO: Do something with the payload
    :ok = AMQP.Basic.ack(channel, tag)
    #:ok = AMQP.Basic.reject(channel, tag, requeue: true)
  rescue
    # You might also want to catch :exit signal in production code.
    # Make sure you call ack, nack or reject otherwise consumer will stop
    # receiving messages.
    _exception ->
      :ok = AMQP.Basic.reject(channel, tag, requeue: true)
  end
end
