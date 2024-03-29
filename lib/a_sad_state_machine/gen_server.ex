defmodule ASadStateMachine.GenServer do
  use GenServer

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 1000
    }
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  # echo calls
  @impl true
  def handle_call(term, _from, state) do
    {:reply, term, state}
  end

  # crash on cast
  @impl true
  def handle_cast(:crash, _state) do
    raise "Goodbye, cruel world."
  end

  @impl true
  def handle_cast(:call_self, _state) do
    GenServer.call(__MODULE__, :goodbye_cruel_world)
  end

  def echo_call(term) do
    GenServer.call(__MODULE__, term, 1000)
  end

  def crash_with_cast() do
    GenServer.cast(__MODULE__, :crash)
  end

  def call_self() do
    GenServer.cast(__MODULE__, :call_self)
  end
end
