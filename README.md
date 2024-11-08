# Hackney pool metrics collector

Awkward repo name, since elexir projects doing almost the same thing already exists.

Each hackney pool will expose `http_client_pool_size`, `http_client_pool_in_use_count`, `http_client_pool_free_count`, and `http_client_pool_queue_count`. These are the values
returned by `hackney_pool:get_stats(PoolName)`. To find out the pools in existance it uses the internal ets table, which is something that could break in future
updates to hackney.

Just add it to the existing set of collectors for prometheus, in your release `sys.config`.

    {prometheus,
         [{collectors,
           [prometheus_vm_memory_collector,
            prometheus_vm_statistics_collector,
            prometheus_vm_system_info_collector
            prometheus_vm_system_info_collector,
            prometheus_hackney_collector
           ]}
         ]}

