defmodule Concurrent do
  @moduledoc """
  Documentation for Concurrent.
  """

  @doc """
  Concurrent Tests
  """
  def post(options) do
    {raw_url, raw_headers, raw_body} = options
    HTTPoison.post(raw_url, raw_body, raw_headers)
    |> case do
        {:ok, %{body: raw, status_code: code}} -> {code, raw}
        {:error, %{reason: reason}} -> {:error, reason}
       end
    |> (fn {ok, body} ->
          body
          |> Poison.decode(keys: :atoms)
          |> case do
               {:ok, parsed} -> {ok, parsed}
               _ -> {:error, body}
             end
        end).()
  end

  def get(url) do
    url
    |> HTTPoison.get
    |> case do
        {:ok, %{status_code: code}} -> {code}
      end
  end

  def prepare(n) do
    headers = ["Content-Type": "application/json"]
    body = Poison.encode!(%{})
    url = "url"
    {url,headers,body}
  end


  def call(n) do
    prepare(n)
    |> post
  end

  def iteration(range, qty) do
    range
    |> Enum.map(fn(e) -> Task.async(fn -> process(e, qty) end) end)
    |> Enum.map(&Task.await/1)
  end

  def process(n, qty) do
    receive do
      after
        n * 1000 ->
          run(1..qty)
      end
  end
  def run(range) do
    range
    |> Enum.map(fn(e) -> Task.async(fn -> call(e) end) end)
    |> Enum.map(&Task.await/1)
  end
end
