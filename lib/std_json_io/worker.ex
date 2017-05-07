defmodule StdJsonIo.Worker do
  use GenServer
  alias Porcelain.Process, as: Proc
  alias Porcelain.Result

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts[:script], opts)
  end

  def init(script) do
    :erlang.process_flag(:trap_exit, true)
    {:ok, %{js_proc: start_io_server(script)}}
  end

  def handle_call({:json, blob}, _from, state) do
    case Poison.encode(blob) do
      nil -> {:error, :json_error}
      {:error, reason} -> {:error, reason}
      {:ok, json} ->
	receiver = fn f, data ->
	  receive do
	    {_pid, :data, :out, msg} ->
	      new_data = data <> msg
	      case Poison.decode(new_data) do
		{:ok, _} ->
		  # All chunks received
		  {:reply, {:ok, new_data}, state}
		_ ->
		  # Couldn't decode JSON, there are more chunks
		  # to receive and concat with
		  f.(f, new_data)
	      end
	    other ->
	      {:reply, {:error, other}, state}
	  end
	end
	Proc.send_input(state.js_proc, json <> "\n")
	receiver.(receiver, "")
    end
  end

  def handle_call(:stop, _from, state), do: {:stop, :normal, :ok, state}

  # The js server has stopped
  def handle_info({_js_pid, :result, %Result{err: _, status: _status}}, state) do
    {:stop, :normal, state}
  end

  def terminate(_reason, %{js_proc: server}) do
    Proc.signal(server, :kill)
    Proc.stop(server)
    :ok
  end

  def terminate(_reason, _state), do: :ok

  defp start_io_server(script) do
    Porcelain.spawn_shell(script, in: :receive, out: {:send, self()})
  end
end
