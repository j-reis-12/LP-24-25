:- use_module(library(clpfd)). % para poder usar transpose/2
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % ver listas completas
:- [puzzles].
:- [codigoAuxiliar].

% 5.1 Visualização

escreve([]) :- !.
escreve([H|T]) :-
    /** escreve(+List)
        Escreve, por linha, cada elemento da lista.
    */
    writeln(H),
    escreve(T).

visualiza(Lista) :-
    /** visualiza(+List)
        Verdade se Lista é uma lista. Escreve a mesma lista.
    */
    is_list(Lista),
    escreve(Lista).

escreveLinha([], _) :- !.
escreveLinha([H|T], Cont) :-
    /** escreveLinha(+List, +Int)
        Escreve, por linha, cada elemento da lista, aparecendo antes o número da linha em causa,
        um ":" e um espaço.
    */
    write(Cont),
    write(': '),
    writeln(H),
    ContNovo is Cont + 1,
    escreveLinha(T, ContNovo).

visualizaLinha(Lista) :-
    /** visualizaLinha(+List)
        Verdade se Lista é uma lista. Escreve a mesma lista com a marcação das linhas.
    */
    is_list(Lista),
    escreveLinha(Lista, 1).

% 5.2 Inserção de estrelas e pontos

coordenadaValida(Coord, Lista) :-
    /** coordenadaValida(+Term, +List)
        Verdade se Coord são coordenadas da lista Lista.
    */
    length(Lista, Len),
    Coord > 0,
    Coord =< Len.

insereObjecto(_, [], _) :- !.
insereObjecto((L, C), Tabuleiro, Obj) :-
    /** insereObjecto(+Term, +List, +Term)
        Verdade se Tabuleiro é um tabuleiro que passa a ter o objecto Obj nas coordenadas (L, C),
        caso nestas se encontre uma variável, caso contrário não faz nada.
    */
    coordenadaValida(L, Tabuleiro),
    nth1(L, Tabuleiro, Linha),
    coordenadaValida(C, Linha),
    nth1(C, Linha, Elemento),
    var(Elemento),
    !,
    Elemento = Obj.
insereObjecto(_, _, _). % não faz nada se a posição já estiver ocupada

insereVariosObjectos(ListaCoord, _, ListaObjs) :-
    /** insereVariosObjectos(+List, +Term, +List)
        Verdade se ListaCoords for uma lista de coordenadas, ListaObjs uma lista de objectos e
        Tabuleiro um tabuleiro que passa a ter nas coordenadas de ListaCoords os objectos de
        ListaObjs. Falha se ListaCoords e ListaObjs tiverem dimensões diferentes.
    */
    length(ListaCoord, LenCoord),
    length(ListaObjs, LenObjs),
    LenCoord \= LenObjs,
    !,
    fail().

insereVariosObjectos([], _, []).
insereVariosObjectos([(L, C)|TCoord], Tabuleiro, [HObj|TObj]) :-
    insereObjecto((L, C), Tabuleiro, HObj),
    insereVariosObjectos(TCoord, Tabuleiro, TObj).

coordenadasVolta(L, C, [(LCima, C), (LBaixo, C), (L, CEsquerda), (L, CDireita),
                (LCima, CEsquerda), (LCima, CDireita), (LBaixo, CEsquerda), (LBaixo, CDireita)]) :-
    /** coordenadasVolta(+Int, +Int, -List)
        Instancia uma lista de coordenadas à volta das coordendadas (L, C) (cima, baixo, esquerda,
        direita e diagonais).
    */
    LCima is L - 1,
    LBaixo is L + 1,
    CEsquerda is C - 1,
    CDireita is C + 1.

inserePontosListaCoord(_, []) :- !.
inserePontosListaCoord(Tabuleiro, [HVolta|TVolta]) :-
    /** inserePontosListaCoord(+List, +List)
        Insere pontos nas coordenadas da lista no tabuleiro Tabuleiro.
    */
    insereObjecto(HVolta, Tabuleiro, p),
    inserePontosListaCoord(Tabuleiro, TVolta).

inserePontosVolta(Tabuleiro, (L, C)) :-
    /** inserePontosVolta(+List, +Term)
        Verdade se Tabuleiro é um tabuleiro que passa a ter pontos (p) à volta das coordenadas
        (L, C).
    */
    coordenadasVolta(L, C, ListaCoordVolta),
    inserePontosListaCoord(Tabuleiro, ListaCoordVolta).

inserePontos(Tabuleiro, ListaCoord) :-
    /** inserePontos(+List, +List)
        Verdade se Tabuleiro é um tabuleiro que passa a ter pontos (p) em todas as coordenadas de
        ListaCoord.
    */
    inserePontosListaCoord(Tabuleiro, ListaCoord).

% 5.3 Consultas

obtemObjecto(_, [], _) :- !.
obtemObjecto((L, C), Tabuleiro, Obj) :-
    /** obtemObjecto(+Term, +List, +Term)
        Verdade se Obj é o objecto do tabuleiro Tabuleiro nas coordenadas (L, C).
    */
    coordenadaValida(L, Tabuleiro),
    nth1(L, Tabuleiro, Linha),
    coordenadaValida(C, Linha),
    nth1(C, Linha, Obj).

objectosEmCoordenadas([], _, []) :- !.
objectosEmCoordenadas([(L, C)|TCoord], Tabuleiro, [HObj|TObj]) :-
    /** objectosEmCoordenadas(+List, +List, ?List)
        Verdade se o terceiro argumento for a lista de objectos das corrdenadas do primeiro
        argumento no tabuleiro Tabuleiro.
    */
    obtemObjecto((L, C), Tabuleiro, HObj),
    objectosEmCoordenadas(TCoord, Tabuleiro, TObj).

coordObjectos(Objecto, Tabuleiro, ListaCoords, ListaCoordObjs, NumObjectos) :-
    /** coordObjectos(+Term, +List, +List, ?List, ?Term)
        Verdade se Tabuleiro for um tabuleiro, ListaCoords uma lista de coordenadas e
        ListaCoordObjs a sublista de ListaCoords que contém as coordenadas dos objectos do tipo
        Objecto, tal como ocorrem no tabuleiro. Num Objectos é o número de objectos Objecto
        encontrados.
    */
    findall(Coord, (member(Coord, ListaCoords), obtemObjecto(Coord, Tabuleiro, Obj),
            (var(Obj), var(Objecto); Obj == Objecto)), ListaDesordenada),
    sort(ListaDesordenada, ListaCoordObjs),
    length(ListaCoordObjs, NumObjectos).

obtemTodasCoordenadas(Tabuleiro, ListaCoords) :-
    /** obtemTodasCoordenadas(+List, -List)
        Instancia uma lista ListaCoords com todas as coordenadas do tabuleiro Tabuleiro.
    */
    length(Tabuleiro, Linhas),
    nth1(1, Tabuleiro, PrimeiraLinha),
    length(PrimeiraLinha, Colunas),
    findall((L, C), (between(1, Linhas, L), between(1, Colunas, C)), ListaCoords).

coordenadasVars(Tabuleiro, ListaVars) :-
    /** coordenadasVars(+List, ?List)
        Verdade se ListaVars forem as coordenadas das variáveis do tabuleiro Tabuleiro.
    */
    obtemTodasCoordenadas(Tabuleiro, ListaCoords),
    coordObjectos(_, Tabuleiro, ListaCoords, ListaVars, _).

% 5.4 Estratégias

insereEstrelaPontos(Tabuleiro, Coord) :-
    /** insereEstrelaPontos(+List, +Term)
        Insere no tabuleiro Tabuleiro uma estrela nas coordenadas Coord e pontos à sua volta.
    */
    insereObjecto(Coord, Tabuleiro, e),
    inserePontosVolta(Tabuleiro, Coord).

fechaListaCoordenadas(Tabuleiro, ListaCoord) :-
    /** fechaListaCoordenadas(+List, +List)
        Verdade se Tabuleiro for um tabuleiro e ListaCoord for uma lista de coordenadas; as
        coordenadas de ListaCoord passam a ser apenas estrelas e pontos, considerando as hipóteses.
        
        A linha / coluna / região tem:
            h1: 2 estrelas - enche as restantes coordenadas de pontos;
            h2: 1 estrela e 1 posição livre - insere uma estrela na posição livre e pontos à volta
                dessa mesma estrela;
            h3: 0 estrelas e 2 posições livres - insere uma estrela em cada posição livre e pontos
                à volta de cada estrela inserida.
    */
    coordObjectos(e, Tabuleiro, ListaCoord, _, 2), !, % h1
    coordObjectos(_, Tabuleiro, ListaCoord, ListaVar, _),
    inserePontos(Tabuleiro, ListaVar).

fechaListaCoordenadas(Tabuleiro, ListaCoord) :- % h2
    coordObjectos(e, Tabuleiro, ListaCoord, _, 1),
    coordObjectos(_, Tabuleiro, ListaCoord, [PosLivre], 1), !,
    insereObjecto(PosLivre, Tabuleiro, e),
    inserePontosVolta(Tabuleiro, PosLivre).

fechaListaCoordenadas(Tabuleiro, ListaCoord) :- % h3
    coordObjectos(e, Tabuleiro, ListaCoord, [], _),
    coordObjectos(_, Tabuleiro, ListaCoord, PosLivres, 2),
    maplist(insereEstrelaPontos(Tabuleiro), PosLivres).

fechaListaCoordenadas(_, _). % O tabuleiro mantém-se inalterado.

fecha(Tabuleiro, ListaListasCoord) :-
    /** fecha(+List, +List)
        Verdade se Tabuleiro for um tabuleiro e ListaListasCoord uma lista de listas de
        coordenadas; Tabuleiro será o resultado de aplicar fechalistaCoordenadas a cada lista.
    */
    maplist(fechaListaCoordenadas(Tabuleiro), ListaListasCoord).

semEstrelasOuVars(_, []) :- !.
semEstrelasOuVars(Tabuleiro, ListaCoords) :-
    /** semEstrelasOuVars(+List, +List)
        Verdade se Tabuleiro for um tabuleiro e ListaCoords uma lista de coordenadas vazia ou com
        apenas pontos nas coordenadas respectivas.
    */
    coordObjectos(e, Tabuleiro, ListaCoords, [], _),
    coordObjectos(_, Tabuleiro, ListaCoords, [], _).

listaCoordenadasVars(_, []) :- !.
listaCoordenadasVars(Tabuleiro, [(L, C)|T]) :-
    /** listaCoordenadasVars(+List, +List)
        Verdade se o segundo argumento corresponde a uma lista de coordenadas de variáveis no
        tabuleiro Tabuleiro.
    */
    obtemObjecto((L, C), Tabuleiro, Obj),
    var(Obj),
    listaCoordenadasVars(Tabuleiro, T).

coordenadasSeguidas([_]) :- !.
coordenadasSeguidas([(L1, C1), (L2, C2)|T]) :-
    /** coordenadasSeguidas(+List)
        Verdade se o argumento é uma lista de coordenadas seguidas (numa linh, coluna ou região).
    */
    (L1 = L2; C1 = C2; (abs(L1 - L2) =:= 1, abs(C1 - C2) =:= 1)),
    coordenadasSeguidas([(L2, C2)|T]).

encontraSequencia(Tabuleiro, N, ListaCoords, Seq) :-
    /** encontraSequencia(+List, +Int, +List, ?List)
        Verdade se Tabuleiro for um tabuleiro, ListaCoords uma lista de coordenadas e N o tamanho
        de Seq, uma sublista de ListaCoordsm, que verifica:
            1 - as suas coordenadas representam posições seguidas com variáveis;
            2 - pode ser concatenada com duas listas antes e depois (eventualmente vazias ou com
                pontos nas coordenadas respectivas), permitindo obter ListaCoords.
        Falha se houver mais variáveis na sequência que N.
    */
    length(Seq, N), % Associa o tamanho antes para assegurar que Seq cabe entre duas listas.
    append(ListaAntes, SeqListaDepois, ListaCoords), % Gera as sublistas de ListaCoords; _ é a ListaAntes.
    append(Seq, ListaDepois, SeqListaDepois), % Gera as possíveis Seq, _ é a ListaDepois.
    semEstrelasOuVars(Tabuleiro, ListaAntes),
    semEstrelasOuVars(Tabuleiro, ListaDepois),
    listaCoordenadasVars(Tabuleiro, Seq),
    coordenadasSeguidas(Seq),
    coordObjectos(_, Tabuleiro, Seq, _, NumVarsSeq),
    NumVarsSeq =< N, !.

aplicaPadraoI(Tabuleiro, [(L1, C1), _, (L3, C3)]) :-
    /** aplicaPadraoI(+List, +List)
        Verdade se Tabuleiro for um tabuleiro e o segundo argumento uma lista de coordenadas;
        Tabuleiro passará a ter uma estrela (e) em (L1, C1) e (L3, C3), com pontos (p) à volta de
        cada uma delas.
    */
    maplist(insereEstrelaPontos(Tabuleiro), [(L1, C1), (L3, C3)]).

aplicaPadroes(_, []) :- !.
aplicaPadroes(Tabuleiro, [H|T]) :-
    /** aplicaPadroes(+List, +List)
        Verdade se Tabuleiro for um tabuleiro e o segundo argumento uma lista de listas com
        coordenadas; são encontradas sequências de tamanho 3 e aplicado o aplicaPadraoI/2, ou
        sequências de tamanho 4 e aplicado o aplicaPadraoT/2
    */
    encontraSequencia(Tabuleiro, 3, H, Seq),
    aplicaPadraoI(Tabuleiro, Seq), !,
    aplicaPadroes(Tabuleiro, T).

aplicaPadroes(Tabuleiro, [H|T]) :-
    encontraSequencia(Tabuleiro, 4, H, Seq),
    aplicaPadraoT(Tabuleiro, Seq), !,
    aplicaPadroes(Tabuleiro, T).

aplicaPadroes(Tabuleiro, [_|T]) :- aplicaPadroes(Tabuleiro, T).

% 5.5 Apoteose Final

resolveLoop([], Tabuleiro, Tabuleiro) :- !.
resolveLoop([H|T], Tabuleiro, TabuleiroAnt) :-
    /** resolveLoop(+List, +List, +List)
        Aplica os predicados aplicaPadroes/2 e fecha/2 ao tabuleiro Tabuleiro até este ficar igual
        ao seu estado anterior não há mais alterações possíveis ou o desafio ficou resolvido.
    */
    aplicaPadroes(Tabuleiro, H),
    fecha(Tabuleiro, H),
    (Tabuleiro == TabuleiroAnt, !; resolveLoop(T, Tabuleiro, Tabuleiro)).

resolve(Estruturas, Tabuleiro) :-
    /** resolve(+List, +List)
        Verdade se o primeiro argumento for uma estrutura e Tabuleiro um tabuleiro que resulta de
        aplicar os predicados aplicaPadroes/2 e fecha/2 até já não haver mais alterações nas
        variáveis do tabuleiro.
    */
    coordTodas(Estruturas, CoordTodas),
    resolveLoop(CoordTodas, Tabuleiro, Tabuleiro).
