defmodule NewTranslator do
  # https://github.com/elixir-lang/elixir/blob/d30c5c0185607f08797441ab8af12636ad8dbd7e/lib/logger/lib/logger/translator.ex#L39
  def translate(min_level, :error, :report, {:logger, %{label: label} = report}) do
    case label do
      {:gen_statem, :terminate} ->
        report_gen_statem_terminate(min_level, report)

      _ ->
        :none
    end
  end

  def translate(_min_level, _level, _kind, _data) do
    :none
  end

  # This is the only thing that needs to be added.
  defp report_gen_statem_terminate(min_level, report) do
    inspect_opts = Application.get_env(:logger, :translator_inspect_opts)

    %{
      client_info: client,
      last_message: last,
      name: name,
      reason: reason,
      state: state
    } = report

    {formatted, reason} = format_reason(reason)
    metadata = [crash_reason: reason] ++ registered_name(name)

    msg =
      [":gen_statem ", inspect(name), " terminating", formatted] ++
        ["\nLast message", format_last_message_from(client), ": ", inspect(last, inspect_opts)]

    if min_level == :debug do
      msg = [msg, "\nState: ", inspect(state, inspect_opts) | format_client_info(client)]
      {:ok, msg, metadata}
    else
      {:ok, msg, metadata}
    end
  end

  # https://github.com/elixir-lang/elixir/blob/d30c5c0185607f08797441ab8af12636ad8dbd7e/lib/logger/lib/logger/translator.ex#L495C1-L497C43
  defp format_last_message_from({_, {name, _}}), do: [" (from ", inspect(name), ")"]
  defp format_last_message_from({from, _}), do: [" (from ", inspect(from), ")"]
  defp format_last_message_from(_), do: []

  # https://github.com/elixir-lang/elixir/blob/d30c5c0185607f08797441ab8af12636ad8dbd7e/lib/logger/lib/logger/translator.ex#L499
  defp format_client_info({from, :dead}),
  do: ["\nClient ", inspect(from), " is dead"]

  defp format_client_info({from, :remote}),
    do: ["\nClient ", inspect(from), " is remote on node ", inspect(node(from))]

  defp format_client_info({_, {name, stacktrace}}),
    do: ["\nClient ", inspect(name), " is alive\n" | format_stacktrace(stacktrace)]

  defp format_client_info(_),
    do: []

  # https://github.com/elixir-lang/elixir/blob/d30c5c0185607f08797441ab8af12636ad8dbd7e/lib/logger/lib/logger/translator.ex#L570
  defp format_stacktrace(stacktrace) do
    for entry <- stacktrace do
      ["\n    " | Exception.format_stacktrace_entry(entry)]
    end
  end

  # https://github.com/elixir-lang/elixir/blob/d30c5c0185607f08797441ab8af12636ad8dbd7e/lib/logger/lib/logger/translator.ex#L576
  defp registered_name(name) when is_atom(name), do: [registered_name: name]
  defp registered_name(_name), do: []

  # https://github.com/elixir-lang/elixir/blob/d30c5c0185607f08797441ab8af12636ad8dbd7e/lib/logger/lib/logger/translator.ex#L524
  defp format_reason(reason) do
    {format_stop(reason), {reason, []}}
  end

  # https://github.com/elixir-lang/elixir/blob/d30c5c0185607f08797441ab8af12636ad8dbd7e/lib/logger/lib/logger/translator.ex#L528
  defp format_stop(reason) do
    ["\n** (stop) " | Exception.format_exit(reason)]
  end
end