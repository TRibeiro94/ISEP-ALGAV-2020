##### PL2
===============================================================

```Prolog

/*--------------- 1 a)--------------- */

sum([], 0).
sum([H|T], S):-
	sum(T, S1),
	S is S1 + H.

size([], 0).
size([_|T], L):-
	size(T, L1),
	L is L1 + 1.

average(L, A):-
	sum(L ,S),
	size(L ,S1),
	A is S / S1.

/*--------------- 1 b)--------------- */

smallest([X],X).
smallest([H|T],M):-
	smallest(T,M),
	H > M,!.
smallest([H|_],H).

/*--------------- 1 c)--------------- */

pairOdd([],0,0).
pairOdd([H|T],P,I):-
	0 is mod(H,2),!,
	pairOdd(T,P1,I),
	P is P1+1.
pairOdd([_|T],P,I):-
	pairOdd(T,P,I1),
	I is I1+1.

/*--------------- 1 d)--------------- */

repeatedNums([]).
repeatedNums([H|T]):-
	member(H,T),!.
repeatedNums([_|T]):-
	repeatedNums(T).

/*--------------- 1 e)--------------- */

smallestToHead(L,[R|R2]):-
	smallest(L,R),
	deleteFirst(R,L,R2).


/*--------------- 1 f--------------- )*/

conc([],L,L).
conc([H|T],L1,[H|L]):-
	conc(T,L1,L).

/*--------------- 1 g)--------------- */

flattenList([],[]).
flattenList([[H|T]|L], LF):-
	append([H|T],L,L1),
	flattenList(L1,LF),!.
flattenList([X|L],[X|LF]):-
	flattenList(L,LF).

/*--------------- 1 h)--------------- */

deleteFirst(_,[],[]):-!.
deleteFirst(X,[X|T],T):-!.
deleteFirst(X,[H|T],[H|R]):-
	deleteFirst(X,T,R).

/*--------------- 1 i)--------------- */

deleteAll(_,[],[]):-!.
deleteAll(X,[X|T],R):-
	deleteAll(X,T,R),!.
deleteAll(X,[H|T],[H|R]):-
	deleteAll(X,T,R).

/*--------------- 1 j)--------------- */

replaceElem(_,_,[],[]):-!.
replaceElem(X,Y,[X|L],[Y|L2]):-
	replaceElem(X,Y,L,L2),!.
replaceElem(X,Y,[Z|L],[Z|L2]):-
	replaceElem(X,Y,L,L2).

/*--------------- 1 k)--------------- */

insert(E,0,L,L1):-
	append([E],L,L1),!.
insert(E,I,[H|L],[H|L1]):-
	I1 is I-1,
	insert(E,I1,L,L1).

/*--------------- 1 l)--------------- */

invertList([X],[X]):-!.
invertList([H|T], L):-
	invertList(T,[H|L]).

/*--------------- 1 m)--------------- */
/*--------------- 1 n)--------------- */
/*--------------- 1 o)--------------- */

```
===============================================================
