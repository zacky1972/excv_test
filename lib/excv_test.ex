defmodule ExcvTest do
  require Logger

  @on_load :load_nif

  def load_nif do
    nif_file = '#{:code.priv_dir(:excv_test)}/libnif'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.warn("Failed to load NIF: #{inspect(reason)}")
    end
  end

  def test(_file, _cuda?, _loop), do: raise "NIF test/3 not implemented"

  def time_test(file, cuda?, loop) do
    {time_elixir, {:ok, time_c}} = :timer.tc(fn -> test(file, cuda?, loop) end)
    %{
      time_elixir: time_elixir, 
      time_c: time_c,
      diff_elixir_c: time_elixir - time_c
    }
  end
end
