defmodule StdJsonIo do
  def json_call!(map, timeout \\ 10000) do
    case json_call(map, timeout) do
      {:ok, data} -> data
      {:error, reason } -> raise "Failed to call to json service #{__MODULE__} #{to_string(reason)}"
    end
  end

  def json_call(data, timeout \\ 10000) do
    result = :poolboy.transaction(StdJsonIo.Pool, fn worker ->
      GenServer.cast(worker, {:json, data, self()})
      receive do
        {:std_json_io_response, response} ->
	  response
      after
	timeout ->
	  %{"error" => "timeout"}
      end
    end)
    if result["error"] do
      {:error, Map.get(result, "error")}
    else
      {:ok, result}
    end
  end
end
