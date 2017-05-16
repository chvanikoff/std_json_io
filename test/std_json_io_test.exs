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

  @tag long: true
  test "Can handle reply taking 3s" do
    message = %{"test" => "sleep3s"}
    expected = {:ok, %{"response" => message}}
    assert StdJsonIo.json_call(message) == expected
  end

  @tag long: true
  test "Proper timeout error is returned in case of timeout" do
    message = %{"test" => "sleep3s"}
    expected = {:error, %{"message" => "timeout", "buffer" => ""}}
    assert StdJsonIo.json_call(message, 1000) == expected
  end

  test "Can handle error key in program response" do
    message = %{"test" => "error"}
    expected = {:error, message}
    assert StdJsonIo.json_call(message) == expected
  end

  test "Can handle program crash" do
    message = %{"test" => "crash"}
    expected = {:error, %{"message" => "Server have been terminated", "buffer" => ""}}
    assert StdJsonIo.json_call(message) == expected
  end

  test "Can handle incorrect response from program" do
    message = %{"test" => "not_json"}
    expected = {:error, %{"message" => "timeout", "buffer" => "plaintext"}}
    assert StdJsonIo.json_call(message) == expected
  end
end
