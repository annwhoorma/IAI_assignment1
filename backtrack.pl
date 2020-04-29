/* File that contains backtracking algorithm */

/*
initial function for backtracking algorithm
additionally, outputs results at the end
depending on your preference, comment/uncoment line with desired form of output
beautiful_output() will specify score, path and execution time
stat_output() is used for statical purpose
*/

:- [maps/mapSTAT3/map13].
:- [helping].
backtracking_init() :-
    statistics(walltime, _),
    (touchdown(TempX, TempY), start_position(TempX, TempY), write('Touchdown is at starting position. path: [], moves: 0')) ; 
    (orc(OrcX, OrcY), start_position(OrcX, OrcY), write('not possible')) ; (
    start_position(X_0, Y_0),
    length(_, PointsLimit), % mention Khaled and Lev
    make_move(X_0, Y_0, 0, [[0, 0]], 0, ResPoints, Path, PointsLimit), !,
    statistics(walltime, [_ | [ExecutionTime]])

    , beautiful_output(ResPoints, Path, ExecutionTime)
    % , stat_output(ExecutionTime)
    ). 

/*
base case for make_move() which is described below, returns true when touchdown is reached
*/
make_move(CurX, CurY, CurPoints, CurPath, _, ResPoints, ResPath, _) :-
    touchdown(CurX, CurY), ResPath=CurPath, ResPoints=CurPoints.

/*
changes state from the current to the next by moving to the next yard
*/
make_move(CurX, CurY, CurPoints, CurPath, TossFlag, ResPoints, ResPath, PointsLimit) :-
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