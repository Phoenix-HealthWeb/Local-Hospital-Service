defmodule LocalHospitalService.NdbSyncronization.Producer do
  @moduledoc """
  This module is responsible for queuing data to syncronize to the NDB API.
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

    {:ok, %{channel: channel, queue_name: queue_name}}
  end

  @doc """
  Used to publish a message to the queue.
  """
  def produce(message) do
    GenServer.cast(__MODULE__, {:publish, message})
  end

  @impl true
  def handle_cast({:publish, message}, state) do
    AMQP.Basic.publish(state.channel, "", state.queue_name, message)
    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("Terminating #{__MODULE__} with reason: #{inspect(reason)}")
    AMQP.Channel.close(state.channel)
    :ok
  end
end
