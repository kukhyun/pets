%%%-------------------------------------------------------------------
%%% @author  <errai@bongo>
%%% @copyright (C) 2015, 
%%% @doc
%%%
%%% @end
%%% Created : 15 Oct 2015 by  <errai@bongo>
%%%-------------------------------------------------------------------
-module(pets_core).
-author("kukhyun").

%% API
-export([init_pre/1, init/0]).

%% @doc
%% pets_pre 모듈을 컴파일 해서 로딩하는 함수.
%% Key는 업데이트Key를 입력하면 된다.
%% init_pre 이후에는 pets_pre:new/2, insert/2 등을 사용해서 
%% 데이터를 입력한다.
%% @end
-spec init_pre(list()) -> ok | fail.
init_pre(Key) when is_list(Key) ->
	init_1(pets_pre, Key);
init_pre(_) ->
	io:format("ERROR Key must be string()~n"),
	error.


%% @doc
%% init_pre(Key) 실행 이후 모든 데이터를 저장하였다면, 
%% init()를 실행해서 실제 서비스 데이터로 인식시킨다. 
%% @end
-spec init() -> ok | fail.
init() ->
	case pets_pre:get_key() of
		Key when is_list(Key) ->
			init_1(pets, Key);
		error ->
			io:format("You must call pets_core:init_pre(Key)~n")
	end.

init_1(Module, Key) ->
	Bin = compile(Module, Key),
	code:purge(Module),
	code:load_binary(Module, atom_to_list(Module) ++ ".erl", Bin).

compile(Mod, Key) ->
	{ok, Mod, Bin} = compile:forms(forms(Mod, Key), [verbose, report_errors]),
	Bin.

forms(Mod, Key) ->
	%%Ac = term_to_abstract(Mod, Key),
	%%io:format("~s~n", [erl_prettypr:format(erl_syntax:form_list(Ac))]),
	[erl_syntax:revert(X) || X <- term_to_abstract(Mod, Key)].

term_to_abstract(Mod, Key) ->
	[erl_syntax:attribute(
	   erl_syntax:atom(module),
	   [erl_syntax:atom(Mod)]),
	 erl_syntax:attribute(
	   erl_syntax:atom(export),
	   [erl_syntax:list(
		  [erl_syntax:arity_qualifier(
			 erl_syntax:atom(new),
			 erl_syntax:integer(2)),
		   erl_syntax:arity_qualifier(
			 erl_syntax:atom(get_key),
			 erl_syntax:integer(0)),
		   erl_syntax:arity_qualifier(
			 erl_syntax:atom(insert),
			 erl_syntax:integer(2)),
		   erl_syntax:arity_qualifier(
			 erl_syntax:atom(lookup),
			 erl_syntax:integer(2)),
		   erl_syntax:arity_qualifier(
			 erl_syntax:atom(delete_all_objects),
			 erl_syntax:integer(1)),
		   erl_syntax:arity_qualifier(
			 erl_syntax:atom(tab2list),
			 erl_syntax:integer(1))])]),
	 erl_syntax:function(
	   erl_syntax:atom(new),
	   [erl_syntax:clause(
		  [erl_syntax:variable("T"), erl_syntax:variable("Opt")],
		  [],
		  [erl_syntax:match_expr(erl_syntax:variable("T1"),
								 erl_syntax:infix_expr(
								   erl_syntax:string(Key),
								   erl_syntax:operator("++"),
								   erl_syntax:application(
									 erl_syntax:atom("atom_to_list"),
									 [erl_syntax:variable("T")]))),
		   erl_syntax:match_expr(erl_syntax:variable("T2"),
								 erl_syntax:application(
								   erl_syntax:atom("list_to_atom"),
								   [erl_syntax:variable("T1")])),
		   erl_syntax:application(
			 erl_syntax:module_qualifier(erl_syntax:atom("ets"), erl_syntax:atom("new")),
			 [erl_syntax:variable("T2"), erl_syntax:variable("Opt")])])]),
	 erl_syntax:function(
	   erl_syntax:atom(get_key),
	   [erl_syntax:clause(
		  [],
		  [],
		  [erl_syntax:string(Key)])]),
	 erl_syntax:function(
	   erl_syntax:atom(insert),
	   [erl_syntax:clause(
		  [erl_syntax:variable("T"), erl_syntax:variable("Obj")],
		  [],
		  [erl_syntax:match_expr(erl_syntax:variable("T1"),
								 erl_syntax:infix_expr(
								   erl_syntax:string(Key),
								   erl_syntax:operator("++"),
								   erl_syntax:application(
									 erl_syntax:atom("atom_to_list"),
									 [erl_syntax:variable("T")]))),
		   erl_syntax:match_expr(erl_syntax:variable("T2"),
								 erl_syntax:application(
								   erl_syntax:atom("list_to_atom"),
								   [erl_syntax:variable("T1")])),
		   erl_syntax:application(
			 erl_syntax:module_qualifier(erl_syntax:atom("ets"), erl_syntax:atom("insert")),
			 [erl_syntax:variable("T2"), erl_syntax:variable("Obj")])])]),
	 erl_syntax:function(
	   erl_syntax:atom(lookup),
	   [erl_syntax:clause(
		  [erl_syntax:variable("T"), erl_syntax:variable("Key")],
		  [],
		  [erl_syntax:match_expr(erl_syntax:variable("T1"),
								 erl_syntax:infix_expr(
								   erl_syntax:string(Key),
								   erl_syntax:operator("++"),
								   erl_syntax:application(
									 erl_syntax:atom("atom_to_list"),
									 [erl_syntax:variable("T")]))),
		   erl_syntax:match_expr(erl_syntax:variable("T2"),
								 erl_syntax:application(
								   erl_syntax:atom("list_to_atom"),
								   [erl_syntax:variable("T1")])),
		   erl_syntax:application(
			 erl_syntax:module_qualifier(erl_syntax:atom("ets"), erl_syntax:atom("lookup")),
			 [erl_syntax:variable("T2"), erl_syntax:variable("Key")])])]),
	 erl_syntax:function(
	   erl_syntax:atom(delete_all_objects),
	   [erl_syntax:clause(
		  [erl_syntax:variable("T")],
		  [],
		  [erl_syntax:match_expr(erl_syntax:variable("T1"),
                                 erl_syntax:infix_expr(
                                   erl_syntax:string(Key),
                                   erl_syntax:operator("++"),
                                   erl_syntax:application(
                                     erl_syntax:atom("atom_to_list"),
                                     [erl_syntax:variable("T")]))),
           erl_syntax:match_expr(erl_syntax:variable("T2"),
                                 erl_syntax:application(
                                   erl_syntax:atom("list_to_atom"),
                                   [erl_syntax:variable("T1")])),
           erl_syntax:application(
             erl_syntax:module_qualifier(erl_syntax:atom("ets"), erl_syntax:atom("delete_all_objects")),
             [erl_syntax:variable("T2")])])]),
	 erl_syntax:function(
	   erl_syntax:atom(tab2list),
       [erl_syntax:clause(
          [erl_syntax:variable("T")],
          [],
          [erl_syntax:match_expr(erl_syntax:variable("T1"),
                                 erl_syntax:infix_expr(
                                   erl_syntax:string(Key),
                                   erl_syntax:operator("++"),
                                   erl_syntax:application(
                                     erl_syntax:atom("atom_to_list"),
                                     [erl_syntax:variable("T")]))),
           erl_syntax:match_expr(erl_syntax:variable("T2"),
                                 erl_syntax:application(
                                   erl_syntax:atom("list_to_atom"),
                                   [erl_syntax:variable("T1")])),
           erl_syntax:application(
             erl_syntax:module_qualifier(erl_syntax:atom("ets"), erl_syntax:atom("tab2list")),
             [erl_syntax:variable("T2")])])])
	].


%% 테스트코드
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-ifdef(TEST).
simple_test() ->
	?assert(pets_core:init_pre("ver1") == {module,pets_pre}),
	?assert(pets_pre:new(montest, [named_table]) == ver1montest),
	?assert(pets_pre:insert(montest, {100, apple}) == true),
	?assert(pets_pre:insert(montest, {200, apple}) == true),
	?assert(pets_pre:lookup(montest, 200) == [{200,apple}]),
	?assert(pets_core:init() == {module, pets}),
	?assert(pets:lookup(montest, 100) == [{100, apple}]),
	?assert(pets_core:init_pre("ver2") == {module,pets_pre}),
	?assert(pets_pre:new(montest, [named_table]) == ver2montest),
	?assert(pets_pre:insert(montest, {100, orange}) == true),
	?assert(pets_core:init() == {module, pets}),
	?assert(pets:lookup(montest, 100) == [{100, orange}]),
	?assert(pets:tab2list(montest) == [{100,orange}]),
	?assert(pets:delete_all_objects(montest) == true).

-endif.
