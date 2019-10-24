defmodule Logflare.Logs do
  @moduledoc false
  require Logger
  use Publicist

  alias Logflare.LogEvent, as: LE
  alias Logflare.Logs.{RejectedLogEvents}
  alias Logflare.{SystemMetrics, Source, Sources}
  alias Logflare.Source.{BigQuery.Buffer, RecentLogsServer}
  alias Logflare.Sources.ClusterStore
  alias Logflare.Rule
  alias Logflare.Sources

  @spec ingest_logs(list(map), Source.t()) :: :ok | {:error, term}
  def ingest_logs(log_params_batch, %Source{} = source) do
    log_params_batch
    |> Enum.map(&LE.make(&1, %{source: source}))
    |> Enum.map(fn %LE{} = le ->
      if le.valid? do
        ingest_by_source_rules(le)
        ingest_and_broadcast(le)
      else
        RejectedLogEvents.ingest(le)
      end

      le
    end)
    |> Enum.reduce([], fn log, acc ->
      if log.valid? do
        acc
      else
        [log.validation_error | acc]
      end
    end)
    |> case do
      [] -> :ok
      errors when is_list(errors) -> {:error, errors}
    end
  end

  @spec ingest_by_source_rules(LE.t()) :: term | :noop
  defp ingest_by_source_rules(%LE{via_rule: %Rule{} = rule} = le) when not is_nil(rule) do
    Logger.error(
      "LogEvent #{le.id} has already been routed using the rule #{rule.id}, can't proceed!"
    )

    :noop
  end

  defp ingest_by_source_rules(%LE{source: %Source{} = source, via_rule: nil} = le) do
    for rule <- source.rules, rule_match?(rule, le.body.message) do
      sink_source = Sources.Cache.get_by(token: rule.sink)

      if sink_source do
        ingest_and_broadcast(%{le | source: sink_source, via_rule: rule})
      else
        Logger.error("Sink source for UUID #{rule.sink} doesn't exist")
      end
    end
  end

  def rule_match?(%{regex_struct: nil}, _), do: false

  def rule_match?(rule, message), do: Regex.match?(rule.regex_struct, message)

  defp ingest_and_broadcast(%LE{source: %Source{type: :telemetry} = source} = le) do
    source_table_string = Atom.to_string(source.token)

    # indvididual source genservers
    Buffer.push(source_table_string, le)
    Source.ChannelTopics.broadcast_new(le)
    RecentLogsServer.push(source.token, le)
  end

  defp ingest_and_broadcast(%LE{source: %Source{} = source} = le) do
    source_table_string = Atom.to_string(source.token)

    # indvididual source genservers
    Buffer.push(source_table_string, le)
    RecentLogsServer.push(source.token, le)

    ClusterStore.increment_local_counter(source)

    # all sources genservers
    # SystemMetrics.AllLogsLogged.incriment(:total_logs_logged)

    # broadcasters
    Source.ChannelTopics.broadcast_new(le)
  end
end
