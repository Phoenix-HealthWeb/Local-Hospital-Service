defmodule LocalHospitalService.NdbSyncronization.Supervisor do
  use Supervisor

  @queue_name Application.compile_env!(
                :local_hospital_service,
                LocalHospitalService.NdbSyncronization
              )[:queue_name]

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_init_args) do
    rabbit_host =
      Application.get_env(:local_hospital_service, LocalHospitalService.NdbSyncronization)[
        :rabbit_host
      ]

    {:ok, connection} =
      AMQP.Connection.open(host: rabbit_host)

    {:ok, channel} = AMQP.Channel.open(connection)

    {:ok, queue} =
      AMQP.Queue.declare(channel, @queue_name,
        durable: true,
        arguments: [
          {"x-dead-letter-exchange", :longstr, "#{@queue_name}_deadletter_exchange"},
          {"x-dead-letter-routing-key", :longstr, ""}
        ]
      )

    # Additionally, declare a deadletter queue
    {:ok, deadletter} = AMQP.Queue.declare(channel, "#{@queue_name}_deadletter", durable: true)
    :ok = AMQP.Exchange.declare(channel, "#{@queue_name}_deadletter_exchange", :direct)

    :ok =
      AMQP.Queue.bind(channel, deadletter.queue, "#{@queue_name}_deadletter_exchange",
        routing_key: ""
      )

    :ok = AMQP.Channel.close(channel)

    children = [
      {LocalHospitalService.NdbSyncronization.Consumer,
       connection: connection, queue_name: queue.queue}
      # {LocalHospitalService.NdbSyncronization.Producer, connection: connection, queue_name: queue.queue}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
