-module(rabbit_mqtt_retained_msg_store_khepri).

-behaviour(rabbit_mqtt_retained_msg_store).

%% API exports
-export([
    new/2,
    recover/2,
    insert/3,
    lookup/2,
    delete/2,
    terminate/1
]).

-include_lib("rabbit_common/include/rabbit.hrl").
-include_lib("rabbitmq_mqtt/include/rabbit_mqtt_packet.hrl").

safe_create_path([]) -> ok;
safe_create_path(Path) ->
    case khepri:put(Path, undefined) of
        ok -> ok;
        {error, already_exists} -> ok;
        {error, _} = Err ->
            logger:error("Failed to create path ~p: ~p", [Path, Err]),
            Err
    end.

%% Called when no state exists yet
-spec new(file:name_all(), binary()) -> binary().
new(_Dir, VHost) ->
    logger:info("initializing rabbimq-mqtt-retained-msg-khepri"),
    _ = khepri:put([retained_messages, VHost], initialized),
    VHost.

%% Called to restore existing state on broker restart
-spec recover(file:name_all(), binary()) ->
    {ok, binary(), #{}} | {error, uninitialized}.
recover(_Dir, VHost) ->
    case khepri:get([retained_messages, VHost]) of
        {ok, _} ->
            %% No expiration data persisted yet, return empty map
            {ok, VHost, #{}};
        {error, _Reason} ->
            logger:info("Retained store not initialized for ~p", [VHost]),
            {error, uninitialized}
    end.

%% Save a retained message
-spec insert(binary(), mqtt_msg(), binary()) -> ok.
insert(Topic, Msg, VHost) ->
    Path = [retained_messages, VHost, Topic],
    case khepri:put(Path, Msg) of
        ok -> ok;
        {error, {khepri, node_not_found, _Details}} ->
            % Try to create the path root first, then retry
            Root = [retained_messages, VHost],
            _ = safe_create_path(Root),
            khepri:put(Path, Msg);
        {error, Reason} ->
            logger:error("Failed to retain message on topic ~p: ~p", [Topic, Reason]),
            ok
    end.

%% Retrieve a retained message
-spec lookup(binary(), binary()) -> mqtt_msg() | undefined.
lookup(Topic, VHost) ->
    case khepri:get([retained_messages, VHost, Topic]) of
        {ok, Msg} ->
            Msg;
        {error, {khepri, node_not_found, _}} ->
            undefined;
        {error, Reason} ->
            logger:warning("Khepri lookup failed for topic ~p: ~p", [Topic, Reason]),
            undefined
    end.

%% Remove a retained message
-spec delete(binary(), binary()) -> ok.
delete(Topic, VHost) ->
    case khepri:delete([retained_messages, VHost, Topic]) of
        ok -> ok;
        {error, {khepri, node_not_found, _}} -> ok;
        {error, Reason} ->
            logger:warning("Failed to delete retained topic ~p: ~p", [Topic, Reason]),
            ok
    end.

%% Clean shutdown
-spec terminate(binary()) -> ok.
terminate(_VHost) ->
    logger:info("terminating rabbimq-mqtt-retained-msg-khepri"),
    ok.