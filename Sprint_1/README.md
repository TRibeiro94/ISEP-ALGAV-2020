# Sprint 1

* ## Representação do conhecimento do domínio

À exceção dos horários das viagens, todas as informações relativas aos nodes e linhas, são obtidas a partir de um pedido http à base de dados.

```prolog
:-dynamic node/6.
:-dynamic line/4.
:- json_object
path(pathNodes:list(atom), '_id':atom,key:atom,isEmpty:boolean,'__v':
integer),
paths(paths:list(path)),
pathNode('_id':atom,key:atom, node:atom, duration:integer, distance:
number, '__v':integer),
pathNode('_id':atom,key:atom, node:atom,'__v':integer),
pathNodes(pathNodes:list(pathNode)),
node('_id':atom,key:atom,name:atom,latitude:number,longitude:number,s
hortName:atom,isDepot:boolean,isReliefPoint:boolean,'__v':integer),
nodes(nodes:list(node)).
getLines():-
http_open("http://localhost:6700/paths/complete", SPaths, []),
http_open("http://localhost:6700/pathnodes/complete",SPathNodes,[]),
http_open("http://localhost:6700/nodes/complete", SNodes,[]),
json_read(SPaths, JsonPaths),
json_read(SPathNodes, JsonPathNodes),
json_read(SNodes, JsonNodes),
json_to_prolog(JsonPaths,DataPaths),
json_to_prolog(JsonPathNodes, DataPathNodes),
json_to_prolog(JsonNodes,DataNodes),
retractall(node(_,_,_,_,_,_)),
retractall(line(_,_,_,_)),
assertIndividualLines(DataPaths, DataNodes,DataPathNodes, 0),
assertIndividualNodes(DataNodes).
```

O código acima, obtem as linhas e os nodes, através da stream de data retornada pelo http_open/3 que
é posteriormente lida pelo json_read/2 e convertido para prolog através do predicado json_to_prolog/2
que faz uso dos json object. Toda a informação sobre nodes e linhas é apagada com o retractall/1 e depois
é chamado o assertIndividualLines/3 e o assertIndividualNodes/1, que vão organizar a informação dos
DataPaths, DataNodes, DataPathNodes e fazer assert dessa informação em factos dinâmicos Prolog, como é
o caso do dynamic node/6 e do dynamic line/4. Os nodes, têm como parâmetros, name, short-name,
isDepot, isReliefPoint e as coordenadas geográficas do ponto (latitude e longitude). Os parâmetros das
linhas são, a key, o número da linha, o path da linha e um array de distâncias, em metros. O path da linha é
um array de strings em que cada string corresponde ao nome de cada node do caminho. O array de
distâncias e o path da linha estão relacionados sendo que dado um índice, é possível saber o node
representado no path e saber também a respetiva distância, entre esse node e o node
anterior, acedendo ao array de distâncias.

O excerto abaixo representa alguns dos horários contidos na base de conhecimento:

```prolog
horario('Path:3',[[69300,69780,70080,70300,70920],
[70200,70680,70980,71280,71820],[71100,71580,71880,72180,72720],
[72000,72480,72780,73080,73620],[72900,73380,73680,73980,74520],
[73800,74280,74580,74880,75420]]).
horario('Path:1',[[67500,68040,68340,68640,69120],
[68400,68940,69240,69540,70020],[69300,69840,70140,70440,70920],
[70200,70740,71040,71340,71820],[71100,71640,71940,72240,72720],
[72000,72540,72840,73140,73620],[77400,77940,78240,78540,79020],
[86400,86880,87180,87480,88020]]).
horario('Path:11',[[27420,27900,28140,28380,29160],
[28320,28800,29040,29280,30060],[29220,29700,29940,30180,30960],
[30120,30600,30840,31080,31860],[31020,31500,31740,31980,32760],
[31920,32400,32640,32880,33660],[32820,33300,33540,33780,34560],
[33720,34200,34440,34680,35460],[34620,35100,35340,35580,36360]]).
```

O primeiro parâmetro é a key do path, de uma determinada linha. O segundo parâmetro é uma lista de
listas, em que cada lista representa os horários de passagem em cada node do path representado no
primeiro parâmetro.

-------------------------------------

* ## Estudo da viabilidade e complexidade dos geradores de todas as soluções

Esta
análise é conseguida através do uso do predicado plan_mud_mot. Estes são os
resultados obtidos com o gerador de todas as soluções que minimizem o número de mudanças de linhas
com **findall**:

```prolog
?- plan_mud_mot_menorTrocas('ESTPA','CRIST',Caminho_menos_trocas).
Numero de Solucoes:6033
Tempo de geracao da solucao:1.4465980529785156 s.
Caminho_menos_trocas = [('ESTPA', 'PADFE', 'Path:45'), ('PADFE', 'CRIST',
'Path:88')].
```

A solução acima não é muito eficiente demorando cerca de 1.45 segundos a gerar a
melhor solução. Abaixo é possível ver os resultados dados pelo mesmo método, mas sem **findall**:

```prolog
?- plan_mud_mot_menorTrocas('ESTPA','CRIST',Caminho_menos_trocas).
Numero de Solucoes:6033
Tempo de geracao da solucao:1.3998541831970215 s.
Caminho_menos_trocas = [('ESTPA', 'MOURZ', 'Path:45'), ('MOURZ', 'CRIST',
'Path:20')].
```

Este gerador é ligeiramente mais eficaz que o anterior demorando cerca de 1.4 segundos a gerar a melhor
solução. No entanto esta melhoria na eficácia é praticamente negligível. Após estes resultados nas
gerações de todas as soluções que minimizam o número de mudanças de linhas, abaixo vê-se os resultados
obtidos quando o objetivo é obter as soluções que minimizam o tempo de chegada. Este predicado não
faz uso do findall, mas é um predicado ‘força bruta’.

```prolog
?- plan_mud_mot('ESTPA','CRIST',28000,Caminho,HoraDeChegada).
Numero de Solucoes:6033
Tempo de geracao da solucao:1.4615490436553955 s.
Caminho = [('ESTPA', 'PADFE', 'Path:45'), ('PADFE', 'CRIST', 'Path:88')],
HoraDeChegada = 29100.
```

Analisando o resultado obtido acima, é possível verificar que é obtido um tempo de geração equivalente ao
gerador que minimiza o número de trocas com findall, isto porque, apesar de não utilizar o findall, este
predicado verifica todas as soluções possíveis e tem ainda os horários para calcular. 

Analisando agora um método com o mesmo objetivo do anterior, mas mais eficiente, é possível
ver a melhoria considerável no tempo de geração da solução:

```prolog
?- plan_mud_mot('ESTPA','CRIST',28000,Caminho,HoraDeChegada).
Numero de Solucoes:6033
Tempo de geracao da solucao:0.005999088287353516 s.
Caminho = ['ESTPA', 'PADFE', 'CRIST'],
HoraDeChegada = 29100.
```

Para o mesmo caminho, o algoritmo A*, demora apenas 0,006 segundos. Comparando
este tempo com o tempo de geração do predicado "força bruta", é possível ver que o método é 
significativaente mais eficaz. Para contexto, este predicado (A*) é 24 vezes mais rápido que o predicado força
bruta. Apesar disto, se o objetivo é um tempo rápido de geração da solução ideal, há um
predicado que apesar de não garantir a solução que realmente chega mais cedo, utiliza uma heurística
correta, e há uma boa chance de obter uma solução aceitável. Abaixo, está o tempo de geração do
algoritmo **best first** para a minimização do tempo de chegada com a heurística que segue para o nó que se
encontrar geograficamente mais próximo do nó de destino.

```prolog
?- plan_mud_mot('ESTPA','CRIST',28000,Caminho,HoraDeChegada).
Numero de Solucoes:6033
Tempo de geracao da solucao:0.0010039806365966797 s.
Caminho = ['ESTPA', 'PARED', 'VANDO', 'CDMUS', 'CRIST'],
HoraDeChegada = 31740.
```

Este predicado é praticamente instantâneo, sendo 6 vezes mais rápido que o predicado A*. No entanto,
analisando a solução, vê-se que a hora de chegada do **Best First** é maior do que a hora de
chegada do A*. Sendo assim, é possível optar por  sacrificar a melhor resposta por um tempo de execução mais rápido
com o **Best First**, ou sacrificar o tempo de execução por uma resposta ideal.

| **Nº pontos de rendição e estações de recolha** | **Caminho Testado (Noi - > Nof)** | **Nº de soluções** | **Tempo de resposta da solução com findall (s)** | **Tempo de resposta da solução sem findall (s)** |
|-------------------------------------------------|-----------------------------------|--------------------|--------------------------------------------------|--------------------------------------------------|
| 2                                               | AGUIA -> BALTR                    | 1                  | 0.0                                              | 0.00                                             |
| 7                                               | AGUIA -> BALTR                    | 8                  | 0.0                                              | 0.00                                             |
| 10                                              | AGUIA -> BALTR                    | 7165               | 1.1366381645202637                               | 1.1446387767791748                               |
| 11                                              | AGUIA -> BALTR                    | 30916              | 5.902423143386841                                | 5.949054002761841                                |
| 12                                              | AGUIA -> BALTR                    | 253639             | 68.34100699424744                                | 67.55179286003113                                |
| 13                                              | AGUIA -> BALTR                    | 496110             | Stack Limit(1GB)                                 | 281.5696029663086                                |
| 14                                              | AGUIA -> BALTR                    | 2210889            | Stack Limit(1GB)                                 | 1026.3682579994202                               |


---------------------------------

Durante a realização do estudo acima, foram alterados não só o número de pontos de rendição e estações de
recolha como o número de linhas que estes apresentam. 

--------------------------------

* ## Adaptação do gerador de todas as soluções (sem findall)

```prolog
%ALGORITMO GERADOR DE TODAS AS SOLUçÔES COM BASE NOS HORÁRIOS SEM FINDALL
mais_cedo_sem_findall(A,B,HoraInicio,LCaminho_maiscedo, HoraChegada):-
(melhor_caminho_horario_sem_findall(A,B,HoraInicio);true),
retract(melhor_sol_ntrocas(LCaminho_maiscedo,HoraChegada)).
melhor_caminho_horario_sem_findall(A,B,HoraInicio):-
asserta(melhor_sol_ntrocas(_,86401)),
caminho(A,B,LCaminho),
atualiza_melhor_horario_sem_findall(LCaminho,HoraInicio),
fail.
atualiza_melhor_horario_sem_findall(LCaminho,HoraInicio):-
melhor_sol_ntrocas(_,N),
tempo_de_chegada(LCaminho,HoraInicio,HoraChegada),
HoraChegada<N,retract(melhor_sol_ntrocas(_,_)),
asserta(melhor_sol_ntrocas(LCaminho,HoraChegada)).
tempo_de_chegada([],HoraInicio,HoraInicio):-!.
tempo_de_chegada([(A,B,Line)|T], HoraInicio, HoraChegada):-
line(Line,_,List,_),
nth1(NA,List,A),
nth1(NB,List,B),
horario(Line,LHorarios),
procurarHora(NA,NB,LHorarios,HoraInicio,HoraMudancaLinha),
tempo_de_chegada(T,HoraMudancaLinha,HoraUltimaParagem),
HoraChegada=HoraUltimaParagem.
procurarHora( _, [], _, _):- print("ERRO: Não foi encontrada uma hora de
partida a partir da hora indicada!").
procurarHora(NA,NB, [H|T], HoraInicio,HoraChegada):-
nth1(NA,H,HoraInicial),
((HoraInicio=<HoraInicial,nth1(NB,H,HoraChegada),!);
(procurarHora(NA,NB,T,HoraInicio,HoraChegada))).
```

* ## Adaptação do A* para minimização do horário de chegada ao destino pretendido

O método A* é o método com o melhor balanço de eficiência/viabilidade:

```prolog
aStar(Orig,Dest,HoraInicio,Cam,HoraChegada):-
aStar2(Dest,[(_,HoraInicio,[Orig])],Cam,HoraChegada),
postSolution(Orig,Dest,HoraInicio,HoraChegada,Cam).
aStar2(Dest,[(_,Chegada,[Dest|T])|_],Cam,Chegada):-
reverse([Dest|T],Cam),!.
aStar2(Dest,[(_,HoraInicio,LA)|Outros],Cam,HoraChegada):-
LA=[Act|_],
findall((CEX,CaX,[X|LA]),
(Dest\==Act,edge(Act,X,Path),\+member(X,LA),
calcularTempo(Act,X,Path,HoraInicio,HoraParagem),
CaX is HoraParagem, estimativa(X,Dest,EstX),
CEX is CaX +EstX),Novos),
append(Outros,Novos,Todos),
sort(Todos,TodosOrd),
aStar2(Dest,TodosOrd,Cam,HoraChegada).
estimativa(Nodo1,Nodo2,Estimativa):-
node(_,Nodo1,_,_,X1,Y1),
node(_,Nodo2,_,_,X2,Y2),
Degrees is pi / 180,
Distancia is acos(sin(X1*Degrees)*sin(X2*Degrees) +
cos(X1*Degrees)*cos(X2*Degrees) * cos(Y2*Degrees-Y1*Degrees)) * 6371000,
Estimativa is Distancia / 8.89.
```

* ## Adaptação do Best First com heurística de minimização da distância ao destino

O algoritmo **best first** é extretamente rápido visto que segue uma heurística que não verifica todas as
soluções possíveis. No entanto, o que faz com que ele seja rápido ou por vezes até instantâneo é o que o faz não dar sempre a resposta mais correta:

```prolog
bestfs(Orig,Dest,HoraInicio,Cam,HoraChegada):-
bestfs2(Dest,(HoraInicio,[Orig]),Cam,HoraChegada),!.
bestfs2(Dest,(Chegada,[Dest|T]),Cam,Chegada):-
reverse([Dest|T],Cam),!.
bestfs2(Dest,(HoraInicio,LA),Cam,HoraChegada):-
LA=[Act|_],
findall((EstX,CaX,[X|LA]),
(edge(Act,X,Path),\+member(X,LA),
calcularTempo(Act,X,Path,HoraInicio,HoraParagem),
CaX is HoraParagem, estimativa(X,Dest,EstX))
,Novos),
sort(Novos,NovosOrd),
proximo(NovosOrd,CM,Melhor),
bestfs2(Dest,(CM,Melhor),Cam,HoraChegada).
proximo([(_,CM,Melhor)|_],CM,Melhor).
proximo([_|L],CM,Melhor):-proximo(L,CM,Melhor).
```

