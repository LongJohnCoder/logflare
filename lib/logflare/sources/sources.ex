defmodule Logflare.Sources do
  @moduledoc """
  Sources-related context
  """
  alias Logflare.{Repo, Source}
  alias Logflare.Source.RateCounterServer, as: SRC
  require Logger

  def get_by(kw) do
    Source
    |> Repo.get_by(kw)
    |> case do
      nil ->
        nil

      s ->
        preload_defaults(s)
    end
  end

  def get_metrics(source, bucket: :default) do
    # Source bucket metrics
    SRC.get_metrics(source.token, :default)
  end

  def get_api_rate(source, bucket: :default) do
    SRC.get_avg_rate(source.token)
  end

  def get_bq_schema(%Source{} = source) do
    {:ok, table} = Logflare.Google.BigQuery.get_table(source.token)
    {:ok, table.schema}
  end

  def preload_defaults(source) do
    source
    |> Repo.preload(:user)
    |> Repo.preload(:rules)
    |> refresh_source_metrics()
    |> maybe_compile_rule_regexes()
    |> Source.put_bq_table_id()
  end

  # """
  # Compiles regex_struct if it's not present in the source rules.
  # By setting regex_struct to nil if invalid, prevents malformed regex matching during log ingest.
  # """
  defp maybe_compile_rule_regexes(%{rules: rules} = source) do
    rules =
      for rule <- rules do
        if rule.regex_struct do
          rule
        else
          regex_struct =
            case Regex.compile(rule.regex) do
              {:ok, regex} ->
                regex

              {:error, _} ->
                Logger.error(
                  "Rule #{rule.id} for #{source.token} is invalid. Regex string:#{rule.regex}"
                )

                nil
            end

          %{rule | regex_struct: regex_struct}
        end
      end

    %{source | rules: rules}
  end

  def refresh_source_metrics(%Source{token: token} = source) do
    import Logflare.Source.Data
    alias Logflare.Logs.RejectedLogEvents
    alias Number.Delimit

    rejected_count = RejectedLogEvents.count(source)
    inserts_string = Delimit.number_to_delimited(get_total_inserts(token))
    inserts = get_total_inserts(token)
    buffer = get_buffer(token)
    max = get_max_rate(token)
    avg = get_avg_rate(token)
    latest = get_latest_date(token)
    rate = get_rate(token)
    recent = get_ets_count(token)
    fields = 0

    metrics = %Source.Metrics{
      rate: rate,
      latest: latest,
      avg: avg,
      max: max,
      buffer: buffer,
      inserts_string: inserts_string,
      inserts: inserts,
      recent: recent,
      rejected: rejected_count,
      fields: fields
    }

    %{source | metrics: metrics, has_rejected_events?: rejected_count > 0}
  end

  def put_schema_field_count(source) do
    new_metrics = %{source.metrics | fields: Source.Data.get_schema_field_count(source)}

    %{source | metrics: new_metrics}
  end

  def valid_source_token_param?(string) when is_binary(string) do
    case String.length(string) === 36 && Ecto.UUID.cast(string) do
      {:ok, _} -> true
      false -> false
      :error -> false
    end
  end

  def valid_source_token_param?(_), do: false
end
