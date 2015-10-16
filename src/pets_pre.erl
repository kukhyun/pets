%%%-------------------------------------------------------------------
%%% @author  <errai@bongo>
%%% @copyright (C) 2015, 
%%% @doc
%%%
%%% @end
%%% Created : 15 Oct 2015 by  <errai@bongo>
%%%-------------------------------------------------------------------
-module(pets_pre).
-author("kukhyun").

%% API
-export([new/2, lookup/2, get_key/0]).

%% @doc
%% @end
-spec new(atom(), list()) -> term().
new(_, _) ->
	usage().

%% @doc
%% @end
-spec lookup(atom(), term()) -> list().
lookup(_,_) ->
	usage().

%% @doc
%% @end
-spec get_key() -> list().
get_key() ->
	error.


usage() ->
	io:format("You must call pets_core:init_pre(Key)~n").
