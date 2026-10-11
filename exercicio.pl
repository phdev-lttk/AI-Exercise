:- dynamic preferencia/1.
:- dynamic objetivo/1.
:- dynamic disponibilidade/1.
:- dynamic modalidade/1.

atividade(caminhada).
atividade(corrida).
atividade(musculacao).
atividade(ciclismo).
atividade(futebol).

local(caminhada, ar_livre).
local(corrida, ar_livre).
local(ciclismo, ar_livre).
local(futebol, ar_livre).
local(musculacao, fechado).

tipo(caminhada, individual).
tipo(corrida, individual).
tipo(musculacao, individual).
tipo(ciclismo, individual).
tipo(futebol, grupo).

indicada_para(corrida, condicionamento).
indicada_para(ciclismo, condicionamento).
indicada_para(caminhada, lazer).
indicada_para(futebol, lazer).
indicada_para(musculacao, fortalecimento).

intensidade(caminhada, leve).
intensidade(corrida, intensa).
intensidade(musculacao, intensa).
intensidade(ciclismo, intensa).
intensidade(futebol, intensa).

recomenda(caminhada) :-
    preferencia(ar_livre),
    disponibilidade(leve).

recomenda(corrida) :-
    preferencia(ar_livre),
    objetivo(condicionamento).

recomenda(musculacao) :-
    preferencia(fechado),
    objetivo(fortalecimento).

recomenda(futebol) :-
    modalidade(grupo),
    objetivo(lazer).

recomenda(ciclismo) :-
    (   preferencia(ar_livre)
    ;   objetivo(condicionamento)
    ).

perguntar_opcao(Pergunta, Opcoes, Resposta) :-
    repeat,
    nl,
    writeln(Pergunta),
    format('Opcoes validas: ~w~n', [Opcoes]),
    writeln('(digite a opcao seguida de ponto final. Exemplo: ar_livre.)'),
    read(Entrada),
    (   memberchk(Entrada, Opcoes)
    ->  Resposta = Entrada,
        !
    ;   writeln('Opcao invalida. Tente novamente.'),
        fail
    ).

perguntar :-
    retractall(preferencia(_)),
    retractall(objetivo(_)),
    retractall(disponibilidade(_)),
    retractall(modalidade(_)),

    perguntar_opcao(
        'Prefere atividade individual ou em grupo?',
        [individual, grupo],
        M
    ),
    assertz(modalidade(M)),

    perguntar_opcao(
        'Prefere atividade ao ar livre ou em ambiente fechado?',
        [ar_livre, fechado],
        L
    ),
    assertz(preferencia(L)),

    perguntar_opcao(
        'Qual o seu objetivo principal?',
        [condicionamento, lazer, fortalecimento],
        O
    ),
    assertz(objetivo(O)),

    perguntar_opcao(
        'Qual a sua disponibilidade: atividade leve ou intensa?',
        [leve, intensa],
        D
    ),
    assertz(disponibilidade(D)).

pontos(Atividade, Total) :-
    atividade(Atividade),
    (local(Atividade, L), preferencia(L)
        -> P1 = 1 ; P1 = 0),
    (tipo(Atividade, T), modalidade(T)
        -> P2 = 1 ; P2 = 0),
    (indicada_para(Atividade, O), objetivo(O)
        -> P3 = 1 ; P3 = 0),
    (intensidade(Atividade, I), disponibilidade(I)
        -> P4 = 1 ; P4 = 0),
    (recomenda(Atividade)
        -> P5 = 2 ; P5 = 0),
    Total is P1 + P2 + P3 + P4 + P5.

mostrar_resultado :-
    findall(Chave-Atividade,
        (atividade(Atividade),
         pontos(Atividade, Total),
         Chave is -Total),
        Lista),
    keysort(Lista, Ordenada),
    (   Ordenada = [_-Melhor | Outras]
    ->  pontos(Melhor, Pontuacao),
        nl,
        writeln('========================================'),
        writeln('       RESULTADO DA RECOMENDACAO'),
        writeln('========================================'),
        format('Atividade mais recomendada: ~w~n', [Melhor]),
        format('Pontuacao: ~w pontos~n', [Pontuacao]),
        (   Outras \== []
        ->  nl,
            writeln('Outras opcoes compativeis:'),
            listar(Outras)
        ;   true
        )
    ;   writeln('Nenhuma atividade cadastrada no sistema.')
    ).

listar([]).
listar([_-Atividade | Resto]) :-
    pontos(Atividade, Pontuacao),
    format(' - ~w (~w pontos)~n', [Atividade, Pontuacao]),
    listar(Resto).

iniciar :-
    writeln('=== Sistema Especialista: Recomendacao de Exercicios ==='),
    perguntar,
    mostrar_resultado.
