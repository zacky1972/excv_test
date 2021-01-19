defmodule Excv do
  use GenServer

  @command "#{:code.priv_dir(:excv_test)}/excv"

  def start_link(args \\ [], opts \\ [name: Excv]) do
  	GenServer.start_link(__MODULE__, args, opts)
  end

  def init(args \\ []) do
  	port = Port.open({:spawn, "#{@command} #{Enum.join(args, " ")}"}, [:binary, :exit_status])

  	{:ok, %{latest_output: "", exit_status: nil}}
  end

  def handle_info({port, {:data, text_line}}, state) do
 	latest_output = text_line |> String.trim
 	{:noreply, %{state | latest_output: latest_output}}
  end

  def handle_info({port, {:exit_status, status}}, state) do
  	{:noreply, %{state | exit_status: status}}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  def handle_call(:get, _from, state) do
  	exit_status = Map.get(state, :exit_status)
  	if is_nil(exit_status) do
  	  {:reply, :not_yet, state}
  	else
  	  result = Map.get(state, :latest_output) |> String.to_float()

  	  if exit_status == 0 do
	  	{:reply, {:ok, result}, state}
	  else
	  	{:reply, :error, state}  	
  	  end
  	end
  end

  def get(pid) do
  	GenServer.call(pid, :get)
  end

  def get() do
  	GenServer.call(Excv, :get)
  end
end
