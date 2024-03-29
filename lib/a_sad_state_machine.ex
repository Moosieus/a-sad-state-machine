defmodule ASadStateMachine do
  use Supervisor

  require Logger

  def start_link() do
    Supervisor.start_link(__MODULE__, %{})
  end

  @impl true
  def init(_) do
    # Logger.add_translator({Nostrum.StateMachineTranslator, :translate})

    children = [
      {ASadStateMachine.StateMachine, []},
      {ASadStateMachine.GenServer, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
