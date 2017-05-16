# StdJsonIo

Starts a pool of workers that communicate with an external script via JSON over
STDIN/STDOUT.

Originally written to use [react-stdio](https://github.com/mjackson/react-stdio)
but can be used with any process that reads a JSON object from STDIN and outputs
JSON on STDOUT.

## Installation

1. Add `std_json_io` to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [{:std_json_io, "~> 0.1.0"}]
end
```
2. Ensure `std_json_io` is started before your application:
```elixir
def application do
  [applications: [:std_json_io]]
end
```
### Configuration

You can either configure as additional arguments of the use statement, or in your config file.

```elixir
config :std_json_io,
  pool_size: 5,
  pool_max_overflow: 10,
  script: "node_modules/.bin/react-stdio"
```

* `pool_size` - see [Poolboy options](https://github.com/devinus/poolboy#options), option "size"
* `pool_max_overflow` - See [Poolboy options](https://github.com/devinus/poolboy#options), option "max_overflow"
* `script` - the script to run for the IO server

### Usage example
```elixir
{:ok, data} = StdJsonIo.json_call(%{"component" => "my/component.js"}
# or
data = StdJsonIo.json_call!(%{"component" => "my/component.js"}
```

### Development
There are some tests taking long to run (testing timeouts, long replies, etc.) with tag `long: true` which are excluded by default. To run all the tests including long, you have to run `mix test --include long:true`
