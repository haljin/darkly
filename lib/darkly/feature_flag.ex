defmodule Darkly.FeatureFlag do
  @moduledoc """
  API for operating on feature flags.
  """

  @spec list(String.t(), String.t()) :: [String.t()]
  def list(project, token) do
    resp = make_request("flags/#{project}", token)

    case resp do
      {:ok, %HTTPoison.Response{status_code: 200} = resp} ->
        resp
        |> (fn r -> r.body end).()
        |> Poison.decode!()
        |> Map.fetch!("items")
        |> Enum.map(fn flag -> Map.get(flag, "key") end)

      {:ok, %HTTPoison.Response{status_code: error}} ->
        raise Darkly.APIError, code: error, message: "API Error"

      error ->
        raise Darkly.APIError, code: 0, message: error
    end
  end

  @spec is_on?(String.t(), String.t(), String.t(), String.t()) :: boolean()
  def is_on?(project, flag, environment, token) do
    resp = make_request("flags/#{project}/#{flag}", token, [{"env", environment}])

    case resp do
      {:ok, %HTTPoison.Response{status_code: 200} = resp} ->
        resp
        |> (fn r -> r.body end).()
        |> Poison.decode!()
        |> Map.get("environments")
        |> Map.get(environment)
        |> Map.get("on")

      {:ok, %HTTPoison.Response{status_code: error}} ->
        raise Darkly.APIError, code: error, message: "API Error"

      error ->
        raise Darkly.APIError, code: 0, message: error
    end
  end

  @spec is_on?(String.t(), String.t(), String.t()) :: boolean()
  def is_on?(project, flag, token) do
    resp = make_request("flags/#{project}/#{flag}", token)

    case resp do
      {:ok, %HTTPoison.Response{status_code: 200} = resp} ->
        resp
        |> (fn r -> r.body end).()
        |> Poison.decode!()
        |> Map.fetch!("environments")
        |> Enum.map(fn {env, vals} -> {env, Map.get(vals, "on")} end)

      {:ok, %HTTPoison.Response{status_code: error}} ->
        raise Darkly.APIError, code: error, message: "API Error"

      error ->
        raise Darkly.APIError, code: 0, message: error
    end
  end

  defp make_request(url, token, params \\ []),
    do:
      HTTPoison.get(
        "https://app.launchdarkly.com/api/v2/#{url}",
        [{"Authorization", token}],
        params: params
      )
end
