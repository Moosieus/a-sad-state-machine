defmodule ASadStateMachine.StateMachine do
  @behaviour :gen_statem

  @impl true
  def callback_mode, do: :state_functions

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
    :gen_statem.start_link({:local, __MODULE__}, __MODULE__, %{}, [])
  end

  @impl true
  def init(_) do
    {:ok, :started, %{}}
  end

  def started({:call, from}, term, _data) do
    reply_action = {:reply, from, term}

    {:keep_state_and_data, reply_action}
  end

  def started(:cast, :raise, _data) do
    raise "Goodbye, curel world."
  end

  def started(:cast, :state, data) do
    {:next_state, :oops, data}
  end

  def started(:cast, :match, _data) do
    1 = 0
  end

  def started(:cast, :call_self, _data) do
    :gen_statem.call(__MODULE__, :goodbye_cruel_world)
  end

  def crash_with_raise() do
    :gen_statem.cast(__MODULE__, :raise)
  end

  def crash_with_match() do
    :gen_statem.cast(__MODULE__, :match)
  end

  def enter_undefined_state() do
    :gen_statem.cast(__MODULE__, :state)
  end

  def call_self() do
    :gen_statem.cast(__MODULE__, :call_self)
  end

  def echo_call(term) do
    :gen_statem.call(__MODULE__, term)
  end
end
