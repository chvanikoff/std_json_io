ExUnit.start()

defmodule StdJsonIoMock do
  use StdJsonIo, otp_app: :std_json_io, script: "python -u test/fixtures/echo.py"
end
