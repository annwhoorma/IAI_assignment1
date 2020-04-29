/*
the following function is used in the A* algorithm only
takes arguements: Record, Opened, Closed, returns NewOpened
adds all the neighbour yards of the Record (that contains its position) to the Opened and binds NewOpened to updated Opened
*/
add_all_neighbours([[X, Y]|Rest], Opened, Closed, NewOpened) :-
    X_p1 is X+1, X_m1 is X-1, 
    Y_p1 is Y+1, Y_m1 is Y-1,
    [Cost, PP, TossFlag] = Rest,
    Cost_p1 is Cost + 1,
    calc_cost(Cost, X_p1, Y, CostRight),
    calc_cost(Cost, X_m1, Y, CostLeft),
    calc_cost(Cost, X, Y_p1, CostUp),
    calc_cost(Cost, X, Y_m1, CostDown),

    ((usable(X_p1, Y, TossFlag, Closed, Opened), append(PP, [[X_p1, Y]], PP_Right),
        (CostRight=:=Cost+1 -> append(Opened, [[[X_p1, Y], CostRight, PP_Right, TossFlag]], NewOpened1) ; append([[[X_p1, Y], CostRight, PP_Right, TossFlag]], Opened, NewOpened1))) ; NewOpened1 = Opened),

    ((usable(X_m1, Y, TossFlag, Closed, Opened), append(PP, [[X_m1, Y]], PP_Left), 
        (CostLeft=:=Cost+1 -> append(NewOpened1, [[[X_m1, Y], CostLeft, PP_Left, TossFlag]], NewOpened2) ; append([[[X_m1, Y], CostLeft, PP_Left, TossFlag]], NewOpened1, NewOpened2))) ; NewOpened2 = NewOpened1),

    ((usable(X, Y_p1, TossFlag, Closed, Opened), append(PP, [[X, Y_p1]], PP_Up), 
        (CostUp=:=Cost+1 -> append(NewOpened2, [[[X, Y_p1], CostUp, PP_Up, TossFlag]], NewOpened3) ; append([[[X, Y_p1], CostUp, PP_Up, TossFlag]], NewOpened2, NewOpened3))) ; NewOpened3 = NewOpened2),

    ((usable(X, Y_m1, TossFlag, Closed, Opened), append(PP, [[X, Y_m1]], PP_Down), 
        (CostDown=:=Cost+1 -> append(NewOpened3, [[[X, Y_m1], CostDown, PP_Down, TossFlag]], NewOpened4) ; append([[[X, Y_m1], CostDown, PP_Down, TossFlag]], NewOpened3, NewOpened4))) ; NewOpened4 = NewOpened3),
    
    ((TossFlag=:=0, human(HumanX, HumanY), possible_to_pass_ball(X, Y, HumanX, HumanY), 
        usable(HumanX, HumanY, TossFlag, Closed, Opened), append(PP, [[HumanX, HumanY]], PP_Human),
        append(Opened, [[[HumanX, HumanY], Cost_p1, PP_Human, 1]], NewOpened5)) ; NewOpened5 = NewOpened4) ,

    NewOpened = NewOpened5.

/*
the following function is used in the A* algorithm only
returns true if yard with position (X, Y) is valid at the current time
*/    
usable(X, Y, TossFlag, Closed, Opened):-
    fits(X, Y), not(orc(X, Y)), not(member([[X, Y], _, _, TossFlag], Closed)), not(member([[X, Y], _, _, TossFlag], Opened)).


/*
returns true if touchdown is within 1 yards from (X, Y)
*/
touchdown_is_around_1(X, Y, Tx, Ty):-
    touchdown(TX, TY), ((abs(TX-X)=:=1, abs(TY-Y)=:=0) ; (abs(TY-Y)=:=1, abs(TX-X)=:=0)),
    Tx = TX, Ty = TY.

/*
returns true if touchdown is within 2 yards from (X, Y)
*/
touchdown_is_around_2(X, Y, Tx, Ty):-
    touchdown_is_around_1(X, Y, Tx, Ty) ; 
    (touchdown(TX, TY), ((abs(TX-X)=:=2, abs(TY-Y)=:=0) ; (abs(TY-Y)=:=2, abs(TX-X)=:=0)), Tx = TX, Ty=TY).

/*
the following function is used in backtracking and random search algorithms
returns true if a yard with position (X, Y) is valid for a visit
*/
go_to(X, Y, Path, NewPath) :-
    fits(X, Y), not(is_visited(Path, X, Y)), not(orc(X, Y)), append(Path, [[X, Y]], NewPath).

/*
returns true is (X, Y) was visited
--wrapper for is_member function for redability--
*/
is_visited(List, X, Y):-
    is_member([X, Y], List).

/*
returns true if the ball can be passed from position (FromX, ToX) to position (ToX, ToY)
also, makes sure that distance between two humans is greater than 1, since it's a different scenario
*/
possible_to_pass_ball(FromX, FromY, ToX, ToY) :-
    ( human(ToX, _), FromX=:=ToX, abs(FromY-ToY)>1, lineX_is_clear(FromY, ToY, ToX) );
    ( human(_, ToY), FromY=:=ToY, abs(FromX-ToX)>1, lineY_is_clear(FromX, ToX, ToY) );
    ( human(ToX, ToY), abs(ToY-FromY)=:=abs(ToX-FromX), diagonal_is_clear(FromX, FromY, ToX, ToY) ).

/*
returns true if (X, Y) is withing borders of the map
*/
fits(X, Y):-
    size(SizeX, SizeY),
    X<SizeX, X>=0, Y<SizeY, Y>=0.

/*
returns true if yard(X, Y) does not have an orc at it
*/
cell_is_clear(X, Y) :-
    not(orc(X, Y)).

/*
returns true if segment between (FromX, ConstY) and (ToX, ConstY) does not contain orcs
*/
lineY_is_clear(ToX, ToX, ConstY):-
    cell_is_clear(ToX, ConstY).
lineY_is_clear(FromX, ToX, ConstY) :-
    FromX_p1 is FromX+1,
    ToX_p1 is ToX+1,
    cell_is_clear(FromX, ConstY),
    (FromX < ToX), lineY_is_clear(FromX_p1, ToX, ConstY),
    (FromX > ToX), lineY_is_clear(FromX, ToX_p1, ConstY).

/*
returns true if segment between (ConstX, FromY) and (ConstX, ToY) does not contain orcs
*/
lineX_is_clear(ToY, ToY, ConstX) :-
    cell_is_clear(ConstX, ToY).
lineX_is_clear(FromY, ToY, ConstX) :-
    FromY_p1 is FromY+1,
    ToY_p1 is ToY+1,
    cell_is_clear(ConstX, FromY),
    (FromY < ToY), lineX_is_clear(FromY_p1, ToY, ConstX),
    (FromY > ToY), lineX_is_clear(FromY, ToY_p1, ConstX).

/*
calculates cost of the move to the yard with position (NewX, NewY)
always returns true
*/
calc_cost(CurPoints, NewX, NewY, NewPoints) :-
    human(NewX, NewY) -> NewPoints is CurPoints ; NewPoints is CurPoints+1.

/*
returns true if diagonal between (X1, Y1) and (X2, Y2) does not contain orcs
*/
diagonal_is_clear(X1, Y1, X2, Y2) :- % accepts only under condition that (X1, Y1)->(X2, Y2) form a diagonal
    ( (Y1>Y2, X1>X2, cell_is_clear(X1, Y1), from_ru_to_ld(X1, Y1, X2, Y2)); %from right-up to left-down
    (Y1>Y2, X1<X2, cell_is_clear(X1, Y1), from_lu_to_rd(X1, Y1, X2, Y2)); %from left-up to right-down
    (Y1<Y2, X1>X2, cell_is_clear(X1, Y1), from_rd_to_lu(X1, Y1, X2, Y2)); %from right-down to left-up
    (Y1<Y2, X1<X2, cell_is_clear(X1, Y1), from_ld_to_ru(X1, Y1, X2, Y2)) ). %from left-fown to right-up
/*
helping recursive function for diagonal_is_clear()
checks diagonal in direction from right-up to left-down
*/
from_ru_to_ld(X1, Y1, X2, Y2) :-
    X1=:=X2, Y1=:=Y2, !.
from_ru_to_ld(X1, Y1, X2, Y2) :-
    X1_m1 is X1-1,
    Y1_m1 is Y1-1,
    % fits(X1_m1, Y1_m1),
    cell_is_clear(X1_m1, Y1_m1),
    from_ru_to_ld(X1_m1, Y1_m1, X2, Y2).
/*
helping recursive function for diagonal_is_clear()
checks diagonal in direction from left-up to right-down
*/
from_lu_to_rd(X1, Y1, X2, Y2) :-
    X1=:=X2, Y1=:=Y2, !.
from_lu_to_rd(X1, Y1, X2, Y2) :-
    X1_p1 is X1+1,
    Y1_m1 is Y1-1,
    % fits(X1_p1, Y1_m1),
    cell_is_clear(X1_p1, Y1_m1),
    from_lu_to_rd(X1_p1, Y1_m1, X2, Y2).
/*
helping recursive function for diagonal_is_clear()
checks diagonal in direction from right-down to left-up
*/
from_rd_to_lu(X1, Y1, X2, Y2) :-
    X1=:=X2, Y1=:=Y2, !.
from_rd_to_lu(X1, Y1, X2, Y2) :-
    X1_m1 is X1-1,
    Y1_p1 is Y1+1,
    % fits(X1_m1, Y1_p1),
    cell_is_clear(X1_m1, Y1_p1),
    from_rd_to_lu(X1_m1, Y1_p1, X2, Y2).
/*
helping recursive function for diagonal_is_clear()
checks diagonal in direction from left-up to right-down
*/
from_ld_to_ru(X1, Y1, X2, Y2) :-
    X1 =:= X2, Y1 =:= Y2, !.
from_ld_to_ru(X1, Y1, X2, Y2) :-
    X1_p1 is X1+1,
    Y1_p1 is Y1+1,
    % fits(X1_p1, Y1_p1),
    cell_is_clear(X1_p1, Y1_p1),
    from_ld_to_ru(X1_p1, Y1_p1, X2, Y2).

/*
return true if element A is a member of list B
*/
is_member(X, [X|_]).
is_member(X, [_|T]) :- 
    is_member(X,T).

/*
returns true when X can be binded to the last element of the passed list
*/
last_elem([Head],X):-
    X = Head.
last_elem([_|Tail],X):-
    last_elem(Tail,X).

/*
returns true when Head can be binded to the first element of the passed
*/
take_first([X|_], Head):-
    Head=X.

/*
returns true after appending the smallest element of List (according to sort) to NewList
*/
keep_the_smallest(List, ListLen, [NewList]) :-
    (ListLen=:=1, NewList=List) ; (sort(List, TempList), take_first(TempList, NewList)).

/*
used in beautiful_output() to print elements of the list
*/
print_records([]).
print_records([A|B]) :-
  write(A), write(' '),
  print_records(B).

/*
the following funciton is used to output the results in a readable way
*/
beautiful_output(Moves, Path, ExeTime) :-
    write('moves: '), writeln(Moves),
    write('path: '), print_records(Path), nl,
    write('execution took '), write(ExeTime), write(' ms.'), nl.

/*
the following funciton is used to output the results for statistical purposes
*/
stat_output(ExeTime) :-
    writeln(ExeTime).

/*
the following funciton is used to output the results for statistical purposes with the score
*/
stat_output_score(Moves, ExeTime) :-
    write(Moves), write(' '), writeln(ExeTime).