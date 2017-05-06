defmodule StdJsonIoTest do
  use ExUnit.Case
  doctest StdJsonIo

  setup do
    {:ok, _} = StdJsonIoMock.start_link([])
    {:ok, %{}}
  end

  test "Call to json_call returns correct value" do
    message = %{"hello" => "world"}
    expected = {:ok, %{"response" => message}}
    assert StdJsonIoMock.json_call(message) == expected
  end

  test "Call to json_call! returns correct value" do
    message = %{"hello" => "world"}
    expected = %{"response" => message}
    assert StdJsonIoMock.json_call!(message) == expected
  end

  test "Can handle big response" do
    message = %{"thisishuge" => String.duplicate("Lorem Ipsum Dolor Sit Amet", 10000)}
    expected = {:ok, %{"response" => message}}
    assert StdJsonIoMock.json_call(message) == expected
  end
end
