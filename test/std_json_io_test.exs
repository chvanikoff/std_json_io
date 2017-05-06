defmodule StdJsonIoTest do
  use ExUnit.Case
  doctest StdJsonIo

  setup do
    {:ok, _} = StdJsonIoMock.start_link([])
    {:ok, %{}}
  end
end
