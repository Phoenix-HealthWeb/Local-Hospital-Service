defmodule LocalHospitalService.NdbSyncronization.Producer do
  @moduledoc """
  This module is responsible for queuing data to syncronize to the NDB API.
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
  @spec init(any()) ::
          {:ok,
           %{
             channel: AMQP.Channel.t(),
             conn: AMQP.Connection.t(),
             queue: %{consumer_count: integer(), message_count: integer(), queue: binary()}
           }}
  def init(__init_args) do
    # TODO: Connection url
    {:ok, conn} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(conn)
    {:ok, queue} = AMQP.Queue.declare(channel, @queue_name, durable: true)

    {:ok, %{conn: conn, channel: channel, queue: queue}}
  end

  @doc """
  Used to publish a message to the queue.
  """
  def publish(message) do
    GenServer.cast(__MODULE__, {:publish, message})
  end

  @impl true
  def handle_cast({:publish, message}, state) do
    AMQP.Basic.publish(state.channel, "", @queue_name, message)
    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("Terminating #{__MODULE__} with reason: #{inspect(reason)}")
    AMQP.Channel.close(state.channel)
    AMQP.Connection.close(state.conn)
    :ok
  end
end
