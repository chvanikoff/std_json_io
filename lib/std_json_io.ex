defmodule StdJsonIo do
  def json_call!(map, timeout \\ 10000) do
    case json_call(map, timeout) do
      {:ok, data} -> data
      {:error, reason } -> raise "Failed to call to json service #{__MODULE__} #{to_string(reason)}"
    end
  end

  def json_call(map, timeout \\ 10000) do
    result = :poolboy.transaction(StdJsonIo.Pool, fn worker ->
      GenServer.call(worker, {:json, map}, timeout)
    end)
    case result do
      {:ok, json} ->
        {:ok, data} = Poison.decode(json)
        if data["error"] do
          {:error, Map.get(data, "error")}
        else
          {:ok, data}
        end
      other -> other
    end
  end
end
