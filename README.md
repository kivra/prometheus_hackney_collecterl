# Hackney pool metrics collector

Awkward repo name, since elexir projects doing almost the same thing already exists. Add it this
way to your rebar.config dependencies (hex release might come later)

    {prometheus_hackney_collector, {git, "https://github.com/kivra/prometheus_hackney_collecterl.git", {branch, "main"}}}

Make sure your application depends on hackney and prometheus in your .app file.  Then use your
application start callback to make prometheus know about this collector when dependencies are
running.

    prometheus_registry:register_collector(prometheus_hackney_collector)

Each hackney pool will expose `http_client_pool_size`, `http_client_pool_in_use_count`,
`http_client_pool_free_count`, and `http_client_pool_queue_count`. These are the values returned by
`hackney_pool:get_stats(PoolName)`. To find out the pools in existance it uses a hackney internal ets
table, which is something that could break in future updates to hackney.

