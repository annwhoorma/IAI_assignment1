/* File that contains random search algorithm */

/*
initial function for random search algorithm
additionally, outputs results at the end
depending on your preference, comment/uncoment line with desired form of output
beautiful_output() will specify score, path and execution time
stat_output() is used for statical purpose
*/

:- [maps/mapSTAT3/map13].
:- [helping].
random_search_w_restart_init() :-
    statistics(walltime, _), 
    % if touchdown is at starting position:
    (touchdown(TempX, TempY), start_position(TempX, TempY), write('Touchdown is at starting position. path: [], moves: 0')) ; 
    % if orc is at starting position:
    (orc(OrcX, OrcY), start_position(OrcX, OrcY), write('not possible'));
    (random_search(100, ResList, _), take_first(ResList, First), !,
    statistics(walltime, [_ | [ExecutionTime]]),
    [Moves|[Path]]=First

    , beautiful_output(Moves, Path, ExecutionTime)
    % , stat_output(Moves, ExecutionTime)
    ).

/*
base case for random_search() described below. returns true when desired number of iterations (100 - by default) were finished
*/
random_search(NumberOfTimes, ResList, VarList) :-
    NumberOfTimes =:= 0, ResList=VarList, !.

/* 
function that runs desired number of iterations (100 - by default) and returns best solution that random search managed to find
*/
random_search(NumberOfTimes, ResList, VarList) :- % - one run
    NumberOfTimes > 0,
    NumberOfTimes_m1 is NumberOfTimes-1,
    start_position(CurX, CurY),
    move(CurX, CurY, [[0, 0]], 0, Path, Score, 0), %halt when orc or touchdown is found
    append(VarList, [[Score, Path]], TempList),
    length(TempList, TempListLen),
    keep_the_smallest(TempList, TempListLen, NewVarList),
    random_search(NumberOfTimes_m1, ResList, NewVarList). 

/*
base case for move() described below, returns true when touchdown is reached
*/
move(CurX, CurY, Path, _, Result, Score, ScoreVar):-
    touchdown(CurX, CurY), 
    Result=Path, Score=ScoreVar, !.

/* 
function that changes state from the current one to the next possible, randomly choosing it
if randomly chosen state is not possible to go to, another random value is used (move() invokes itself with the same args)
*/
move(CurX, CurY, Path, TossFlag, Result, Score, ScoreVar) :-
    not(orc(CurX, CurY)),
    ScoreVar_p1 is ScoreVar+1,
    CurX_p1 is CurX+1,
    CurX_m1 is CurX-1,
    CurY_p1 is CurY+1,
    CurY_m1 is CurY-1,
    %calculate cost for each possible move that doesn't involve a ball toss:
    calc_cost(ScoreVar, CurX_p1, CurY, Points_Right),
    calc_cost(ScoreVar, CurX_m1, CurY, Points_Left),
    calc_cost(ScoreVar, CurX, CurY_p1, Points_Up),
    calc_cost(ScoreVar, CurX, CurY_m1, Points_Down),
    random(0.0, 5.0, R),
    (
    ( touchdown_is_around_1(CurX, CurY, TX, TY), append(Path, [[TX, TY]], NewPath), 
        move(TX, TY, NewPath, TossFlag, Result, Score, ScoreVar_p1) ) ;
    (R<1,        fits(CurX_p1, CurY), append(Path, [[CurX_p1, CurY]], NewPath), move(CurX_p1, CurY, NewPath, TossFlag, Result, Score, Points_Right)) ; %go right
    (R>=1, R<2, fits(CurX, CurY_p1), append(Path, [[CurX, CurY_p1]], NewPath), move(CurX, CurY_p1, NewPath, TossFlag, Result, Score, Points_Up)) ; % go up
    (R>=2, R<3, fits(CurX_m1, CurY), append(Path, [[CurX_m1, CurY]], NewPath), move(CurX_m1, CurY, NewPath, TossFlag, Result, Score, Points_Left)) ; % go left
    (R>=3, R<4, fits(CurX, CurY_m1), append(Path, [[CurX, CurY_m1]], NewPath), move(CurX, CurY_m1, NewPath, TossFlag, Result, Score, Points_Down)) ; %go down
    (R>=4, R<5, TossFlag=:=0, human(HumanX, HumanY), possible_to_pass_ball(CurX, CurY, HumanX, HumanY),
        append(Path, [[HumanX, HumanY]], NewPath), 
        move(HumanX, HumanY, NewPath, 1, Result, Score, ScoreVar_p1) )  ;
    move(CurX, CurY, Path, TossFlag, Result, Score, ScoreVar) % try to move with the same paramters but another random value, because this random value didnt let you move.
    ) .