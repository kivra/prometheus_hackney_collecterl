-module(prometheus_hackney_collector).

-behavior(prometheus_collector).

-export([deregister_cleanup/1]).
-export([collect_mf/2]).

%%% API

deregister_cleanup(_Registry) ->
    ok.

collect_mf(_Registry, Callback) ->
    case application:ensure_started(hackney) of
        ok ->
            PoolNames = [Name || {Name, _Pid} <- ets:tab2list(hackney_pool)],
            PoolStats = group_pool_metrics([pool_stats(PoolName) || PoolName <- PoolNames]),
            [
                add_metrics(metric_name(Item), Counters, Callback)
             || {Item, Counters} <- maps:to_list(PoolStats)
            ],
            ok;
        {error, _} ->
            ok
    end.

%%%% Internal

%% erlfmt:ignore so retain a clear tabular listing
metric_name(max)          -> {http_client_pool_size,         gauge, "max pool size"};
metric_name(in_use_count) -> {http_client_pool_in_use_count, gauge, "pool connections in-use"};
metric_name(free_count)   -> {http_client_pool_free_count,   gauge, "pool connections idle"};
metric_name(queue_count)  -> {http_client_pool_queue_count,  gauge, "clients waiting in checkout"}.

pool_stats(PoolName) ->
    try
        KnownTypes = [max, in_use_count, free_count, queue_count],
        [
            [Type, PoolName, Value]
         || {Type, Value} <- hackney_pool:get_stats(PoolName), lists:member(Type, KnownTypes)
        ]
    catch
        exit:{noproc, _} ->
            []
    end.

group_pool_metrics(PoolStats0) ->
    PoolStats = lists:append(PoolStats0),
    maps:groups_from_list(fun hd/1, fun tl/1, PoolStats).

add_metrics({Name, Type, Help}, Counters, Callback) ->
    LabelValues = [{[{pool, PoolName}], Value} || [PoolName, Value] <- Counters],
    Callback(prometheus_model_helpers:create_mf(Name, Help, Type, LabelValues)).
