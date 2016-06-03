%% Copyright (c) 2016 Peter Morgan <peter.james.morgan@gmail.com>
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

-module(haystack_api_networks_resource).

-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([init/2]).
-export([options/2]).
-export([to_json/2]).


init(Req, _) ->
    {cowboy_rest, cors:allow_origin(Req), #{}}.

allowed_methods(Req, State) ->
    {allowed(), Req, State}.

options(Req, State) ->
    cors:options(Req, State, allowed()).

content_types_provided(Req, State) ->
    {[{{<<"application">>, <<"json">>, '*'}, to_json}], Req, State}.

allowed() ->
    [<<"GET">>,
     <<"HEAD">>,
     <<"OPTIONS">>].

to_json(Req, State) ->
    {jsx:encode(
       lists:foldl(
         fun
             (#{id := Id, subnet := #{address := Address, mask := Mask}} = Network, A) ->
                 A#{Id => drop_undefined(
                            maps:without(
                              [id],
                              Network#{subnet := <<(any:to_binary(inet:ntoa(Address)))/bytes,
                                                   "/",
                                                   (any:to_binary(Mask))/bytes>>}))};
                        
             (#{id := Id} = Network, A) ->
                 A#{Id => drop_undefined(maps:without([id], Network))}
         end,
         #{},
         haystack_docker_network:all())),
     Req,
     State}.


drop_undefined(M) ->
    maps:filter(
      fun
          (_, undefined) ->
              false;
          (_, _) ->
              true
      end,
      M).

