size(4, 4).
human(2, 0).
human(2, 3).
orc(-1, -1).
touchdown(3, 3).
start_position(0, 0).
start_path([]).
start_points(0).

%----------------------------- random restart-1.1

random_search_w_restart_init() :-
    statistics(walltime, _),
    (touchdown(TempX, TempY), start_position(TempX, TempY), writeln('Touchdown is at starting position. path: []'), writeln('moves: 0')) ; 
    (orc(OrcX, OrcY), start_position(OrcX, OrcY), write('not possible'));
    ((random_search(1, ResList, _), take_first(ResList, First),
    statistics(walltime, [_ | [ExecutionTime]]),
    [Moves|[Path]]=First,

    write('moves: '), writeln(Moves),
    write('path: '), print_records(Path), nl,
    write('execution took '), write(ExecutionTime), write(' ms.'), nl)) ; 
    (writeln('not possible')).

random_search(NumberOfTimes, ResList, VarList) :-
    NumberOfTimes =:= 0, ResList=VarList, !.

random_search(NumberOfTimes, ResList, VarList) :- % - one run
    NumberOfTimes > 0,
    NumberOfTimes_m1 is NumberOfTimes-1,
    start_position(CurX, CurY),
    move(CurX, CurY, [[0, 0]], 0, Path, Score, 0), %halt when orc or touchdown is found
    append(VarList, [[Score, Path]], TempList),
    length(TempList, TempListLen),
    keep_the_smallest(TempList, TempListLen, NewVarList),
    random_search(NumberOfTimes_m1, ResList, NewVarList). 

move(CurX, CurY, Path, _, Result, Score, ScoreVar):-
    touchdown(CurX, CurY), 
    Result=Path, Score=ScoreVar, !.

move(CurX, CurY, Path, TossFlag, Result, Score, ScoreVar) :-
    not(orc(CurX, CurY)),
    ScoreVar_p1 is ScoreVar+1,
    CurX_p1 is CurX+1,
    CurX_m1 is CurX-1,
    CurY_p1 is CurY+1,
    CurY_m1 is CurY-1,
    calc_cost(ScoreVar, CurX_p1, CurY, Points_Right),
    calc_cost(ScoreVar, CurX_m1, CurY, Points_Left),
    calc_cost(ScoreVar, CurX, CurY_p1, Points_Up),
    calc_cost(ScoreVar, CurX, CurY_m1, Points_Down),
    random(0.0, 5.0, R),
    (
    (R<1,        fits(CurX_p1, CurY), append(Path, [[CurX_p1, CurY]], NewPath), move(CurX_p1, CurY, NewPath, TossFlag, Result, Score, Points_Right)) ; %go right
    (R>=1, R<2, fits(CurX, CurY_p1), append(Path, [[CurX, CurY_p1]], NewPath), move(CurX, CurY_p1, NewPath, TossFlag, Result, Score, Points_Up)) ; % go up
    (R>=2, R<3, fits(CurX_m1, CurY), append(Path, [[CurX_m1, CurY]], NewPath), move(CurX_m1, CurY, NewPath, TossFlag, Result, Score, Points_Left)) ; % go left
    (R>=3, R<4, fits(CurX, CurY_m1), append(Path, [[CurX, CurY_m1]], NewPath), move(CurX, CurY_m1, NewPath, TossFlag, Result, Score, Points_Down)) ; %go down
    (R>=4, R<5, TossFlag=:=0, human(HumanX, HumanY), possible_to_pass_ball(CurX, CurY, HumanX, HumanY),
        append(Path, [[HumanX, HumanY]], NewPath), 
        move(HumanX, HumanY, NewPath, 1, Result, Score, ScoreVar_p1) )  ;
    move(CurX, CurY, Path, TossFlag, Result, Score, ScoreVar) % try to move with the same paramters but another random value, because this random value didnt let you move.
    ) .

%----------------------------- backtracking search-1.2

backtracking_init() :-
    statistics(walltime, _),
    (touchdown(TempX, TempY), start_position(TempX, TempY), write('Touchdown is at starting position. path: [], moves: 0')) ; 
    (orc(OrcX, OrcY), start_position(OrcX, OrcY), write('not possible')) ; (
    start_position(X_0, Y_0),
    length(_, PointsLimit), % mention Khaled and Lev
    make_move(X_0, Y_0, 0, [[0, 0]], 0, PP, Path, PointsLimit), !,
    statistics(walltime, [_ | [ExecutionTime]]), 

    write('moves: '), writeln(PP),
    write('path: '), print_records(Path), nl, 
    write('execution took '), write(ExecutionTime), write(' ms.'), nl). 

calc_cost(CurPoints, NewX, NewY, NewPoints) :-
    human(NewX, NewY) -> NewPoints is CurPoints ; NewPoints is CurPoints+1.

make_move(CurX, CurY, CurPoints, CurPath, _, ResPoints, ResPath, _) :-
    touchdown(CurX, CurY), ResPath=CurPath, ResPoints=CurPoints.

make_move(CurX, CurY, CurPoints, CurPath, TossFlag, ResPoints, ResPath, PointsLimit) :-
    % TossFlag > 0 if tossing a ball was attempted, TossFlag = 0 otherwise
    CurPoints < PointsLimit,
    CurPoints_p1 is CurPoints+1,
    CurX_p1 is CurX+1,
    CurX_m1 is CurX-1,
    CurY_p1 is CurY+1,
    CurY_m1 is CurY-1,
    calc_cost(CurPoints, CurX_p1, CurY, Points_Right),
    calc_cost(CurPoints, CurX_m1, CurY, Points_Left),
    calc_cost(CurPoints, CurX, CurY_p1, Points_Up),
    calc_cost(CurPoints, CurX, CurY_m1, Points_Down),
    ( 
        ( touchdown_is_around_1(CurX, CurY, TX, TY), append(CurPath, [[TX, TY]], NewPath), 
            make_move(TX, TY, CurPoints_p1, NewPath, TossFlag, ResPoints, ResPath, PointsLimit) ) ;
        ( go_to(CurX_p1, CurY, CurPath, NewPath), make_move(CurX_p1, CurY, Points_Right, NewPath, TossFlag, ResPoints, ResPath, PointsLimit) ) ;
        ( go_to(CurX_m1, CurY, CurPath, NewPath), make_move(CurX_m1, CurY, Points_Left, NewPath, TossFlag, ResPoints, ResPath, PointsLimit) ) ;
        ( go_to(CurX, CurY_p1, CurPath, NewPath), make_move(CurX, CurY_p1, Points_Up, NewPath, TossFlag, ResPoints, ResPath, PointsLimit) ) ;
        ( go_to(CurX, CurY_m1, CurPath, NewPath), make_move(CurX, CurY_m1, Points_Down, NewPath, TossFlag, ResPoints, ResPath, PointsLimit) ) ;
        ( TossFlag =:= 0, human(HumanX, HumanY), possible_to_pass_ball(CurX, CurY, HumanX, HumanY),
            not(is_visited(CurPath, HumanX, HumanY)), 
            append(CurPath, [[HumanX, HumanY]], NewPath), 
            make_move(HumanX, HumanY, CurPoints_p1, NewPath, 1, ResPoints, ResPath, PointsLimit) 
        )
    ).

%------------------------------------------ 

a_star_init() :-
    statistics(walltime, _),
    (touchdown(TempX, TempY), start_position(TempX, TempY), write('Touchdown is at starting position. path: [], moves: 0')) ; 
    (orc(OrcX, OrcY), start_position(OrcX, OrcY), write('not possible')) ; 
    (
    start_position(X_0, Y_0),
    a_star([[[X_0, Y_0], 0, [[X_0, Y_0]], 0]], [], ResPath, Score), !,
    statistics(walltime, [_ | [ExecutionTime]]), 

    write('moves: '), writeln(Score), 
    write('path: '), print_records(ResPath), nl,
    write('execution took '), write(ExecutionTime), write(' ms.'), nl
    ).

a_star([], Closed, ResPath, Score) :- %base case
    member([[X, Y], Score, ResPath, _], Closed), touchdown(X, Y), !. %first touchdown found cuts the search

a_star(Opened, Closed, ResPath, Score) :-
    [Current|TailOpened]=Opened, 
    append([Current], Closed, NewClosed),
    add_all_neighbours(Current, TailOpened, NewClosed, NewOpened),
    a_star(NewOpened, NewClosed, ResPath, Score).

%------------------------------------------

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
    
usable(X, Y, TossFlag, Closed, Opened):-
    fits(X, Y), not(orc(X, Y)), not(member([[X, Y], _, _, TossFlag], Closed)), not(member([[X, Y], _, _, TossFlag], Opened)).

touchdown_is_around_1(X, Y, Tx, Ty):-
    touchdown(TX, TY), ((abs(TX-X)=:=1, abs(TY-Y)=:=0) ; (abs(TY-Y)=:=1, abs(TX-X)=:=0)),
    Tx = TX, Ty = TY.

touchdown_is_around_2(X, Y, Tx, Ty):-
    touchdown_is_around_1(X, Y, Tx, Ty) ; 
    (touchdown(TX, TY), ((abs(TX-X)=:=2, abs(TY-Y)=:=0) ; (abs(TY-Y)=:=2, abs(TX-X)=:=0)), Tx = TX, Ty=TY).

go_to(X, Y, Path, NewPath) :-
    fits(X, Y), not(is_visited(Path, X, Y)), not(orc(X, Y)), append(Path, [[X, Y]], NewPath).

is_visited(List, X, Y):-
    is_member([X, Y], List).

possible_to_pass_ball(FromX, FromY, ToX, ToY) :-
    ( human(ToX, _), FromX=:=ToX, abs(FromY-ToY)>1, lineX_is_clear(FromY, ToY, ToX) );
    ( human(_, ToY), FromY=:=ToY, abs(FromX-ToX)>1, lineY_is_clear(FromX, ToX, ToY) );
    ( human(ToX, ToY), abs(ToY-FromY)=:=abs(ToX-FromX), diagonal_is_clear(FromX, FromY, ToX, ToY) ).

fits(X, Y):-
    size(SizeX, SizeY),
    X<SizeX, X>=0, Y<SizeY, Y>=0.

cell_is_clear(X, Y) :-
    not(orc(X, Y)).

lineY_is_clear(FromX, ToX, ConstY) :-
    orc(OrcX, OrcY),
    XLeftBound is min(FromX, ToX), XrightBound is max(FromX, ToX),
    (OrcY\=ConstY ; (OrcX < XLeftBound ; OrcX > XrightBound)).

lineX_is_clear(FromY, ToY, ConstX) :-
    orc(OrcX, OrcY),
    YLowerBound is min(FromY, ToY), YUpperBound is max(FromY, ToY),
    (OrcX\=ConstX ; (OrcY < YLowerBound ; OrcY > YUpperBound)).

%------------------------ diagonals-start

diagonal_is_clear(X1, Y1, X2, Y2) :- % accepts only under condition that (X1, Y1)->(X2, Y2) form a diagonal
    ( (Y1>Y2, X1>X2, cell_is_clear(X1, Y1), from_ru_to_ld(X1, Y1, X2, Y2)); %from right-up to left-down
    (Y1>Y2, X1<X2, cell_is_clear(X1, Y1), from_lu_to_rd(X1, Y1, X2, Y2)); %from left-up to right-down
    (Y1<Y2, X1>X2, cell_is_clear(X1, Y1), from_rd_to_lu(X1, Y1, X2, Y2)); %from right-down to left-up
    (Y1<Y2, X1<X2, cell_is_clear(X1, Y1), from_ld_to_ru(X1, Y1, X2, Y2)) ). %from left-fown to right-up

from_ru_to_ld(X1, Y1, X2, Y2) :-
    X1=:=X2, Y1=:=Y2, !.
from_ru_to_ld(X1, Y1, X2, Y2) :-
    X1_m1 is X1-1,
    Y1_m1 is Y1-1,
    % fits(X1_m1, Y1_m1),
    cell_is_clear(X1_m1, Y1_m1),
    from_ru_to_ld(X1_m1, Y1_m1, X2, Y2).

from_lu_to_rd(X1, Y1, X2, Y2) :-
    X1=:=X2, Y1=:=Y2, !.
from_lu_to_rd(X1, Y1, X2, Y2) :-
    X1_p1 is X1+1,
    Y1_m1 is Y1-1,
    % fits(X1_p1, Y1_m1),
    cell_is_clear(X1_p1, Y1_m1),
    from_lu_to_rd(X1_p1, Y1_m1, X2, Y2).

from_rd_to_lu(X1, Y1, X2, Y2) :-
    X1=:=X2, Y1=:=Y2, !.
from_rd_to_lu(X1, Y1, X2, Y2) :-
    X1_m1 is X1-1,
    Y1_p1 is Y1+1,
    % fits(X1_m1, Y1_p1),
    cell_is_clear(X1_m1, Y1_p1),
    from_rd_to_lu(X1_m1, Y1_p1, X2, Y2).

from_ld_to_ru(X1, Y1, X2, Y2) :-
    X1 =:= X2, Y1 =:= Y2, !.
from_ld_to_ru(X1, Y1, X2, Y2) :-
    X1_p1 is X1+1,
    Y1_p1 is Y1+1,
    % fits(X1_p1, Y1_p1),
    cell_is_clear(X1_p1, Y1_p1),
    from_ld_to_ru(X1_p1, Y1_p1, X2, Y2).

%---------------------------------diagonals-end

%is_member(A, B) checks if element A is a member of list B
is_member(X, [X|_]).
is_member(X, [_|T]) :- 
    is_member(X,T).

%X - last element of the list [_|Tail]
last_elem([Head],X):-
    X = Head.
last_elem([_|Tail],X):-
    last_elem(Tail,X).

%find length of the list
list_len([], X) :-
    X=0.
list_len([_|Tail], Len):-
    list_len(Tail, Prev),
    Len = Prev + 1.

take_first([X|_], Head):-
    Head=X.

keep_the_smallest(List, ListLen, [NewList]) :-
    (ListLen=:=1, NewList=List) ; (sort(List, TempList), take_first(TempList, NewList)).

print_records([]).

print_records([A|B]) :-
  write(A), write(' '),
  print_records(B).


%references:
%https://www.codepoc.io/blog/prolog/5063/prolog-program-to-find-last-item-of-the-list