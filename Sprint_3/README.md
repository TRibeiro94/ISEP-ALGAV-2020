# Sprint 3

* ## Representação do conhecimento do domínio

Factos usados:

```prolog
:-dynamic node/6.
:-dynamic line/4.
:-dynamic edge/3.
:-dynamic melhor_sol_ntrocas/2.
:-dynamic tuple/4.
:-dynamic driver_backup/1.
:-dynamic lista_motoristas_nworkblocks/2.
:-dynamic melhor_individuo/2.
:-dynamic geracoes/1.
:-dynamic populacao/1.
:-dynamic prob_cruzamento/1.
:-dynamic prob_mutacao/1.
:-dynamic tempo_limite/1.
:-dynamic avaliacao_especifica/1.
:-dynamic estabilizacao/1.
:-dynamic numero_worblocks/1.
:-dynamic vd/1.
:-dynamic fittest/1.
:-dynamic horasLimiteContratuais/2.
:-dynamic driver_duty/2.
:-dynamic hard_constraint/4.
horario/3.
workblock/4.
vehicleduty/2.
preferenciaHorarios/1.
rangevd/3.
horariomotorista/5.
```

Dos factos acima, de realçar os **vehicleduty/2** que em contraste ao sprint anterior, vê-se neste sprint
um aumento do número de vehicle duties declarados (visto que agora estamos a atribuir motoristas a vários
vehicle duties). Os **rangevd/3** são também um facto importante visto conterem informação do início e fim de um
vehicle duty. No **horariomotorista**, é guardado o horário de cada motorista bem como os seus blocos de
trabalho. Pode por exemplo fazer 6h num vehicle duty e 2h noutro. Nas **horasLimiteContratuais** é guardado de que horas a que horas um motorista pode trabalhar num determinado vehicle duty. O **driver_duty**
guarda as soluções retornadas pelo algoritmo genético, compilando a lista de workblocks que o motorista
vai fazer em todos os vehicle duties para os quais este foi selecionado. No facto **hard_constraint** vão ser colocadas todas as hard constraints que estão a ser violadas, bem como o motorista que a está a
violar, podendo deste modo atribuir um outro motorista ao workblock em questão. E por último, os **tuple/4** e os **driver_backup/1**. Sendo os **tuples** o facto onde são guardados os
blocos de trabalho que cada motorista tem disponível para ocupar e os **driver_backup**, o facto onde vão ser
armazenados os motoristas que vão ficar em backup.

---------------------

* ## Associação dos motoristas aos Vehicle Duties

Para ser conseguida uma associação de motoristas a vehicle duties, vários detalhes tiveram que ser tidos em
conta. Esta é a sequência de acontecimentos no algoritmo:
* Cálculo da carga
* Cálculo da capacidade
* Cálculo da margem
* Geração de motoristas backup até ser atingida uma determinada margem
* Geração dos tuples de todos os motoristas menos os que estão em driver_backup
* Atribuição dos drivers a partir dos tuples gerados

Conceitos:

* A carga representa a quantidade de trabalho que os motoristas têm a fazer.
* A capacidade é definida como a quantidade de trabalho que os motoristas conseguem realizar.
* A margem é a diferença percentual entre a capacidade e a carga.
* Um tuple é um bloco de trabalho de um motorista, podendo haver vários tuples para o mesmo motorista

Deste modo, obtendo a margem, são atribuídos motoristas backup de forma random até ser atingida uma
margem de 20%. Isto, caso a margem seja maior do que 20%. No caso de não ser, não é criado nenhum
motorista de backup. Após isto, são criados os tuples para os motoristas que não estão presentes no facto
**driver_backup**. De seguida são atribuídos a partir dos tuples criados anteriormente, os motoristas aos Vehicle Duties. A forma como isto é conseguido, é verificando se o tuple está dentro do range do vehicle duty e se
sim, atribui tantos workblocks quanto pode. Isto é calculado multiplicando o tempo que o motorista tem
dentro do vehicle duty pela duração workblock do workblock do vehicle duty. No caso de não haver tuples
para atribuir a vehicle duties, obtem-se o melhor motorista de backup para preencher o vehicle duty em
questão. Neste caso é sempre escolhido o motorista que consegue preencher o restante dos workblocks em falta mas
com a menor margem de tempo de sobra possível. Outra coisa a referir é que todo o tempo
que um motorista não usa para trabalhar, é utilizado para criar um novo tuple, não havendo assim
desperdícios de tempo.
Finalmente, é obtida uma atribuição de motoristas a vehicle duties no seguinte formato:

```prolog
lista_motoristas_nworkblocks(VD,[(Mot,NWorkblocks)]).
```

Onde **VD** é a key do vehicle duty correspondente, **Mot** é a key de um motorista e **NWorkblocks** é o número
de workblocks que o motorista vai fazer.

-------------------

* ## Chamada adequada do escalonador de motoristas para cada Vehicle Duty

Após a obtenção das **lista_motoristas_nworkblocks** para cada vehicle duty, é chamado o Algoritmo genético
escalonador de motoristas, para cada um dos Vehicle duties. Nesse algoritmo é criado um facto:
**melhor_individuo/2** em que no primeiro parâmetro é guardado a key do Vehicle duty e no segundo, a melhor
solução gerada pelo AG. Após a chamada do algoritmo para todos os vehicle duties, existe informação
suficiente para verificar hard constraints que possam estar a ser violadas e posteriormente corrigi-las.

-------------------

* ## Chamada adequada do algoritmo de cálculo do tempo de mudança de motoristas entre um ponto de rendição/recolha e outro

O algoritmo de cálcula de tempo de mudança de motorista é chamado durante a verificação de possíveis
hard constraints que estejam a ser quebradas. Deste modo, é feita uma verificação viagem a viagem se o
motorista tem tempo para chegar da última paragem de uma viagem, à primeira paragem da viagem
seguinte. Se isto não for garantido, é criada uma hard constraint para a segunda viagem, isto querendo dizer
que essa viagem vai ser realizada por outro motorista. O cálculo de tempo que o motorista demora a chegar de uma
paragem a outra é feito a partir do algoritmo A* desenvolvido no **sprint 1**.

----------

* ## Deteção automática de hard constraints nos driver duties gerados depois do escalonamento

Hard constraints que foram consideradas:

* Restrição de oito horas máximas de trabalho.
* O motorista deve ter pelo menos 1 hora para almoçar e para jantar.
* O motorista não deve trabalhar mais que 4 horas seguidas.
* Após um bloco de trabalho de 4 horas ou mais o motoristas deve ter uma pausa de pelo menos 1 hora.
* O motorista deve trabalhar apenas dentro das suas horas contratuais.
* O motorista não pode trabalhar em dois autocarros simultaneamente.
* O motorista tem que ter tempo para mudar de paragem entre viagens, se necessário.

Grande parte destas restrições foram já aplicadas no algoritmo genético mas precisam ser verificadas
novamente após a geração das soluções para todos os vehicle duties do **AG**, visto que estas podem ser
quebradas ao juntar orkblocks de vários vehicle duties num só driver duty.
Sempre que é encontrada uma hard constraint a ser quebrada, é gerado um facto do seguinte formato:

```prolog
hard_constraint(Inicio,Fim,Duracao,Mot).
```

Onde **Inicio** é o ínicio da violação da hard constraint, **Fim** é o fim da violação dessa mesma hard constraint,
**Duracao** é a duração da mesma e **Mot** é o motorista que está a quebrar a hard constraint.

------------------

* ## Correção automática de hard constraints nos driver duties gerados depois do escalonamento

Após a verificação de hard constraints, estas são corrigidas. Todas as hard constraints mencionadas na secção
anterior são corrigidas de forma automática, não havendo necessidade de avisos para trocas manuais. Visto
que não é feita a distinção entre as hard constraints guardadas no facto **hard_constraint/4**, vão ser percorridas todas as hard constraints que estão a ser quebradas e vai ser atribuido o workblock que diz respeito a
essa hard constraint a outro motorista. São usados primeiro os tuples que sobraram da atribuição de motoristas
a vehicle duties e posteriormente, ao verificar-se a falta de tuples para corrigir as restantes hard constraints,
são atribuídos motoristas de backup. Esta correção é feita driver duty a driver duty. Utilizando o motorista de um
driver duty para pesquisar as hard constraints que lhe dizem respeito. Todas as alterações de workblocks são
mostradas no ecrã para o utilizador tenha acesso a tudo o que foi feito.