%% predicates %%
% objects
monkey(monkey).
banana(banana).
box(box).

% locations of objects
loc(loc_init_monkey).
loc(loc_init_banana).
loc(loc_init_box).
loc(loc_elsewhere).

%%%%% possible actions of monkey %%%%%
valid_possible([]).
valid_possible([Head|Tail]) :-
   valid_possible(Tail),  % must come before
   possible(Head, Tail).  % must come after

%% go
possible(go(Monkey, To), Actions) :-
   monkey(Monkey),
   loc(To),
   loc(From),
   location(Monkey, From, Actions),
   \+ From = To,
   \+ on_top_of_box(Monkey, _, Actions). % not on top of any box

%% push
possible(push(Monkey, Box, To), Actions) :-
   monkey(Monkey),
   box(Box),
   loc(To),
   loc(From),
   \+ To = From,
   \+ on_top_of_box(Monkey, _, Actions), % not on top of any box
   location(Monkey, From, Actions),
   location(Box, From, Actions).
   
%% climb_on
possible(climb_on(Monkey, Box), Actions) :-
   monkey(Monkey),
   box(Box),
   loc(Loc),
   location(Monkey, Loc, Actions),
   location(Box, Loc, Actions),
   \+ on_top_of_box(Monkey, _, Actions). % not on top of any box

%% climb_off
possible(climb_off(Monkey, Box), Actions) :-
   monkey(Monkey),
   box(Box),
   loc(Loc),
   location(Monkey, Loc, Actions),
   location(Box, Loc, Actions),
   on_top_of_box(Monkey, Box, Actions). % on top of the same Box

%% grab
possible(grab(Monkey, Banana), Actions) :-
   monkey(Monkey),
   banana(Banana),
   loc(Loc),
   location(Monkey, Loc, Actions),
   location(Banana, Loc, Actions),
   on_top_of_box(Monkey, _, Actions),  % on top of any box
   \+ has_banana(_, Banana, Actions).  % no monkey has the banana

   
%%% initial state %%%
initial_state([]).

% Initial Locations
location(Object, Loc, []) :-
   loc(Loc),
   (Object = monkey, Loc = loc_init_monkey);
   (Object = banana, Loc = loc_init_banana);
   (Object = box,    Loc = loc_init_box).

   
%%%% possible locations for objects
% Monkey Locations
location(Monkey, Loc, Actions) :-
   monkey(Monkey),
   loc(Loc),
   Actions = [Head | Tail],
   (   Head = go(Monkey, Loc);
       Head = push(Monkey, _, Loc);
       (   (   Head = climb_on(_, _);
               Head = climb_off(_, _);
               Head = grab(_, _)
	   ),
	   location(Monkey, Loc, Tail)
       )
   ).

% Box Locations
location(Box, Loc, Actions) :-
   box(Box),
   loc(Loc),
   Actions = [Head | Tail],
   (   Head = push(_, Box, Loc);
       (   (   Head = go(_, _);
               Head = climb_on(_, _);
               Head = climb_off(_, _);
               Head = grab(_, _)
	   ),
	   location(Box, Loc, Tail)
       )
   ).

% Banana Locations
location(Banana, Loc, Actions) :-
   banana(Banana),
   monkey(Monkey),
   loc(Loc),
   (   (   has_banana(Monkey, Banana, Actions),
           location(Monkey, Loc, Actions)
       );
       (   \+ has_banana(Monkey, Banana, Actions),
	   Actions = [_ | Tail],
           location(Banana, Loc, Tail)
       )
   ).

   
%% needed for goal verification
has_banana(Monkey, Banana, Actions) :-
   monkey(Monkey),
   banana(Banana),
   Actions = [Head | Tail],
   (   Head = grab(Monkey, Banana);
       has_banana(Monkey, Banana, Tail)
   ).
   
%% needed for goal verification
on_top_of_box(Monkey, Box, Actions) :-
   monkey(Monkey),
   box(Box),
   Actions = [Head | Tail],
   (   (   Head = climb_on(Monkey, Box),
           \+ Head = climb_off(Monkey, Box)
       );
       (   Head = grab(_, _),
	   on_top_of_box(Monkey, Box, Tail)
       )
   ).


%%% goal state %%%

goal_state(Actions) :-
   location(monkey, loc_init_monkey, Actions),
   location(box, loc_init_box, Actions),
   has_banana(monkey, banana, Actions).
   
%%%%%%%%%%%% PLAN %%%%%%%%%%%%%
% create list for writing the actions taken to reach the goal
writeList([]).
writeList([Head|Tail]) :-
   write(Head), nl,
   writeList(Tail).
   
   
% iterative deepening to find the shortest plan to get the bananas - print reverse actions taken
monkey_plan :-
   valid_possible(Actions),
   goal_state(Actions),
   reverse(Actions, RevActions),
   writeList(RevActions).
   
   
%%%   TESTING   %%%
% get the plan to the goal
%	monkey_plan.