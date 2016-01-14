%% Copyright (c) 2012-2015 Peter Morgan <peter.james.morgan@gmail.com>
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%% http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(haystack).
-export([ensure_loaded/0]).
-export([get_env/1]).
-export([get_env/2]).
-export([make/0]).
-export([modules/0]).
-export([priv_dir/0]).
-export([priv_file/1]).
-export([priv_read_file/1]).
-export([start/0]).
-export([t/0]).



start() ->
    application:ensure_all_started(?MODULE).


make() ->
    make:all([load]).

get_env(Key, Strategy) ->
    gproc:get_env(l, ?MODULE, Key, Strategy).

get_env(Key) ->
    gproc:get_env(l, ?MODULE, Key).

ensure_loaded() ->
    lists:foreach(fun code:ensure_loaded/1, modules()).

modules() ->
    {ok, Modules} = application:get_key(?MODULE, modules),
    Modules.

t() ->
    Modules = [haystack_query, haystack_update, haystack_docker],
    lists:foreach(fun code:ensure_loaded/1, Modules),
    recon_trace:calls([m(Module) || Module <- Modules], 100, [{scope, local},
                                                              {pid, all}]).

m(Module) ->
    {Module, '_', '_'}.

priv_dir() ->
    code:priv_dir(?MODULE).

priv_file(Filename) ->
    filename:join(priv_dir(), Filename).

priv_read_file(Filename) ->
    file:read_file(priv_file(Filename)).
