defmodule StdJsonIo.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    config = Application.get_all_env(:std_json_io)
    pool_options = [
      name: {:local, StdJsonIo.Pool},
      worker_module: StdJsonIo.Worker,
      size: Keyword.get(config, :pool_size, 15),
      max_overflow: Keyword.get(config, :pool_max_overflow, 10),
      strategy: :fifo
    ]
    children = [
      :poolboy.child_spec(StdJsonIo.Pool, pool_options, [script: Keyword.fetch!(config, :script)])
    ]
    opts = [strategy: :one_for_one, name: StdJsonIo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
