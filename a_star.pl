/* File that contains A* algorithm */

/*
initial function for the A* algorithm
additionally, outputs results at the end
depending on your preference, comment/uncoment line with desired form of output
beautiful_output() will specify score, path and execution time
stat_output() is used for statical purpose
*/


:- [maps/mapSTAT3/map13].
:- [helping].
a_star_init() :-
    statistics(walltime, _),
    (touchdown(TempX, TempY), start_position(TempX, TempY), write('Touchdown is at starting position. path: [], moves: 0')) ; 
    (orc(OrcX, OrcY), start_position(OrcX, OrcY), write('not possible')) ; 
    (
    start_position(X_0, Y_0),
    a_star([[[X_0, Y_0], 0, [[X_0, Y_0]], 0]], [], ResPath, Score), !,
    statistics(walltime, [_ | [ExecutionTime]])

    , beautiful_output(Score, ResPath, ExecutionTime)
    % , stat_output(ExecutionTime)
    ).

/*
base case for a_star() explained below. returns true first touchdown is found
*/
a_star([], Closed, ResPath, Score) :- %base case
    member([[X, Y], Score, ResPath, _], Closed), touchdown(X, Y), !. %first touchdown found cuts the search

/*
function that changes current state to the next best one of all possible ones
*/
a_star(Opened, Closed, ResPath, Score) :-
    [Current|TailOpened]=Opened, 
    append([Current], Closed, NewClosed),
    add_all_neighbours(Current, TailOpened, NewClosed, NewOpened),
    a_star(NewOpened, NewClosed, ResPath, Score).
