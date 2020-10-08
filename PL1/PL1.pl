/* Base de Conhecimento (1)*/
:-consult('DB_1').

/*3 a) */
vizinho(P1,P2):- fronteira(P1,P2);fronteira(P2,P1).

/*3 b) */
contSemPaises(C):- continente(C), not(pais(_,C,_)).

/*3 c) */
semVizinhos(L):- pais(L,_,_), not(vizinho(L,_);vizinho(_,L)).

/*3 d) */
chegoLaFacil(P1,P2):- pais(P1,_,_),pais(P2,_,_),(vizinho(P1,P2);vizinho(P1,X),vizinho(X,P2)).
/* ou apenas: vizinho(P1,P2);(vizinho(P1,X),vizinho(X,P2)). */

/*4 a) */
