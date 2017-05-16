defmodule StdJsonIo.Worker do
  use GenServer
  alias Porcelain.Process, as: PProc
  alias Porcelain.Result

  @initial_state %{
    pproc: nil,
    buffer: "",
    from: nil,
    timer: false,
    stop_reason: nil
  }

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts[:script], opts)
  end

  def init(script) do
    Process.flag(:trap_exit, true)
    pproc = Porcelain.spawn_shell(script, in: :receive, out: {:send, self()})
    {:ok, %{@initial_state | pproc: pproc}}
  end

  def handle_call({:json, data, timeout}, from, %{pproc: pproc} = state) do
    {:ok, json} = Poison.encode(data)
    PProc.send_input(pproc, json <> "\n")
    timer = Process.send_after(self(), :timeout, timeout)
    {:noreply, %{state | from: from, timer: timer}}
  end

  def handle_info({pproc_pid, :data, :out, data}, %{pproc: %PProc{pid: pproc_pid}, buffer: buffer} = state) do
    new_buffer = buffer <> data
    case Poison.decode(new_buffer) do
      {:ok, decoded} ->
        Process.cancel_timer(state[:timer])
        GenServer.reply(state[:from], decoded)
	{:noreply, %{state | buffer: "", timer: false}}
      _ ->
	{:noreply, %{state | buffer: new_buffer}}
    end
  end
  # The js server has stopped
  def handle_info({pproc_pid, :result, %Result{err: _, status: _status}}, %{pproc: %PProc{pid: pproc_pid}} = state) do
    {:stop, :normal, %{state | stop_reason: "Server have been terminated"}}
  end
  # Complete response was not received within given timeout
  # Stop the server with appropriate reason
  def handle_info(:timeout, state) do
    {:stop, :normal, %{state | stop_reason: "timeout"}}
  end

  def terminate(_reason, %{pproc: pproc, timer: timer, from: from, buffer: buffer, stop_reason: stop_reason}) do
    unless timer == false do
      # Process is being terminated while client is awaiting response
      error = %{
        "message" => stop_reason,
        "buffer" => buffer
      }
      GenServer.reply(from, %{"error" => error})
      Process.cancel_timer(timer)
    end
    PProc.stop(pproc)
    PProc.signal(pproc, :kill)
    :ok
  end
end
