defmodule StdJsonIo.Worker do
  use GenServer
  alias Porcelain.Process, as: PProc
  alias Porcelain.Result

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts[:script], opts)
  end

  def init(script) do
    Process.flag(:trap_exit, true)
    pproc = Porcelain.spawn_shell(script, in: :receive, out: {:send, self()})
    {:ok, %{pproc: pproc, buffer: "", reply_to: nil}}
  end

  def handle_cast({:json, data, reply_to}, %{pproc: pproc} = state) do
    {:ok, json} = Poison.encode(data)
    PProc.send_input(pproc, json <> "\n")
    {:noreply, %{state | reply_to: reply_to}}
  end

  def handle_info({pproc_pid, :data, :out, data}, %{pproc: %PProc{pid: pproc_pid}, buffer: buffer} = state) do
    new_buffer = buffer <> data
    case Poison.decode(new_buffer) do
      {:ok, decoded} ->
	Process.send(state[:reply_to], {:std_json_io_response, decoded}, [])
	{:noreply, %{state | buffer: ""}}
      _ ->
	{:noreply, %{state | buffer: new_buffer}}
    end
  end
  # The js server has stopped
  def handle_info({pproc_pid, :result, %Result{err: _, status: _status}}, %{pproc: %PProc{pid: pproc_pid}} = state) do
    {:stop, :normal, state}
  end

  def terminate(_reason, %{pproc: pproc}) do
    PProc.signal(pproc, :kill)
    PProc.stop(pproc)
    :ok
  end
end
