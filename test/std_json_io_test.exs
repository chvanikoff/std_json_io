defmodule StdJsonIoTest do
  use ExUnit.Case
  doctest StdJsonIo

  test "Call to json_call returns correct value" do
    message = %{"hello" => "world"}
    expected = {:ok, %{"response" => message}}
    assert StdJsonIo.json_call(message) == expected
  end

  test "Call to json_call! returns correct value" do
    message = %{"hello" => "world"}
    expected = %{"response" => message}
    assert StdJsonIo.json_call!(message) == expected
  end

  test "Can handle big response" do
    message = %{"thisishuge" => String.duplicate("Lorem Ipsum Dolor Sit Amet", 10000)}
    expected = {:ok, %{"response" => message}}
    assert StdJsonIo.json_call(message) == expected
  end
end
