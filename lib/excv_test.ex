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

  def test(_file1, _file2, _cuda?, _loop), do: raise("NIF test/4 not implemented")

  def test_p(file1, file2, cuda?, loop) do
    Excv.start_link([file1, file2, cuda?, loop])
    receive_get()
  end

  def receive_get() do
    ret = Excv.get()

    case ret do
      {:ok, result} -> {:ok, result}

      :not_yet ->
        Process.sleep(50) 
        receive_get()

      :error -> :error
    end
  end

  def time_test(file1, file2, cuda?, loop) do
    {time_elixir, {:ok, time_c}} = :timer.tc(fn -> test(file1, file2, cuda?, loop) end)

    %{
      time_elixir: time_elixir,
      time_c: time_c,
      diff_elixir_c: time_elixir - time_c
    }
  end

  def test_img(cuda?) do
    test(
      "#{:code.priv_dir(:excv_test)}/img/img3_1.png",
      "#{:code.priv_dir(:excv_test)}/img/img3_2.png",
      cuda?,
      1
    )
  end

  def test_img_p(cuda?) do
    test_p(
      "#{:code.priv_dir(:excv_test)}/img/img3_1.png",
      "#{:code.priv_dir(:excv_test)}/img/img3_2.png",
      cuda?,
      1
    )
  end

  def enum_test_img(cuda?, loop) when loop >= 1 do
    1..loop
    |> Enum.map(fn _ -> test_img(cuda?) end)
  end

  def flow_test_img(cuda?, loop) when loop >= 1 do
    1..loop
    |> Flow.from_enumerable(max_demand: 1)
    |> Flow.map(fn _ -> test_img(cuda?) end)
    |> Flow.map(fn {status, _} -> status end)
    |> Enum.to_list()
  end

  def pelemay_fp_test_img(cuda?, loop) when loop >= 1 do
    1..loop
    |> PelemayFp.map(fn _ -> test_img(cuda?) end, 1)
  end

  def enum_test_img_p(cuda?, loop) when loop >= 1 do
    1..loop
    |> Enum.map(fn _ -> test_img_p(cuda?) end)
  end

  def flow_test_img_p(cuda?, loop) when loop >= 1 do
    1..loop
    |> Flow.from_enumerable(max_demand: 1)
    |> Flow.map(fn _ -> test_img_p(cuda?) end)
    |> Flow.map(fn {status, _} -> status end)
    |> Enum.to_list()
  end

  def pelemay_fp_test_img_p(cuda?, loop) when loop >= 1 do
    1..loop
    |> PelemayFp.map(fn _ -> test_img_p(cuda?) end, 1)
  end
end
