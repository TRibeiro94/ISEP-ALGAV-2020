/*Base de Conhecimento(1)*/
:-consult('DB_1').

/*3 a)*/
vizinho(P1,P2):-
    fronteira(P1,P2);
    fronteira(P2,P1).

/*3 b)*/
contSemPaises(C):-
    continente(C),
    not(pais(_,C,_)).

/*3 c)*/
semVizinhos(L):-
    pais(L,_,_),
    not(vizinho(L,_);vizinho(_,L)).

/*3 d)*/
chegoLaFacil(P1,P2):-
    pais(P1,_,_),
    pais(P2,_,_),
    (vizinho(P1,P2);vizinho(P1,X),vizinho(X,P2)).
/* ou apenas: vizinho(P1,P2);(vizinho(P1,X),vizinho(X,P2)). */

/*4 a)*/
/* B-Base,E-Expoente,R-Resultado */
potencia(_,0,1):-!.
potencia(B,E,R):-
    E>0,
    E1 is E-1,
    potencia(B,E1,R1),
    R is B*R1,!.
potencia(B,E,R):-
    E1 is E+1,
    potencia(B,E1,R1),
    R is (1/B)*R1.

/*4 b)*/
/*N-Número,R-Resultado*/
fatorial(0,1):-!.
fatorial(N,R):-
    N1 is N-1,
    fatorial(N1,R1),
    R is N*R1.

/*4 c)*/
/*J-Primeiro Número, K-Segundo Número, R-Resultado*/
somatorio(K,K,K):-!.
somatorio(J,K,R):-
    J < K,
    J1 is J+1,
    somatorio(J1,K,R1),
    R is R1+J,!.
somatorio(J,K,R):-
    J1 is J-1,
    somatorio(J1,K,R1),
    R is J+R1.

/*4 d)*/
/*X-Divisor,Y-Dividendo,R-Resto,I-Divisão Inteira*/
divisao(X,Y,X,0):- X < Y,!.
divisao(X,Y,R,I):-
    X1 is X-Y,
    divisao(X1,Y,R,I1),
    I is I1+1.

