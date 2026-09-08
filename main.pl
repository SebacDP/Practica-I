:- use_module(library(readutil)).
:- use_module(library(lists)).

/* Entry point.
   Run:
   ?- main('../curva_binaria_P4.pbm').
   Or, from the project root:
   swipl -q -s Prolog/main.pl -g "main('curva_binaria_P4.pbm')" -t halt
*/
main(File) :-
    read_pbm(File, Width, Height, BytesPerRow, Data),
    heights(Width, Height, BytesPerRow, Data, M),
    sum_list(M, Area),

    format('==============================================~n'),
    format(' PRACTICE I - FROM PIXELS TO THE INTEGRAL~n'),
    format(' PROLOG~n'),
    format('==============================================~n'),
    format('Dimensions: ~w x ~w~n', [Width, Height]),
    format('Bytes per row: ~w~n', [BytesPerRow]),

    format('~n1. Compact visualization of the PBM image~n'),
    draw_image(Width, Height, BytesPerRow, Data, 100, 35),

    format('~n2. Height function M[x] = f(x)~n'),
    draw_heights(M, 100, 25),

    format('~n3. Sample values~n'),
    show_samples(M, 10),

    format('~n4. Riemann sum~n'),
    format('Area = sum(M) = ~w square pixels~n', [Area]).

/* -----------------------------------------------------------------
   PBM P4 reading
   ----------------------------------------------------------------- */

read_pbm(File, Width, Height, BytesPerRow, Data) :-
    read_file_to_codes(File, Codes, [type(binary)]),
    parse_header(Codes, Width, Height, RasterCodes),
    BytesPerRow is (Width + 7) // 8,
    Expected is BytesPerRow * Height,
    length(Data, Expected),
    append(Data, _, RasterCodes).

parse_header(Codes0, Width, Height, Raster) :-
    read_token(Codes0, Magic, Codes1),
    Magic = "P4",
    read_token(Codes1, WidthCodes, Codes2),
    read_token(Codes2, HeightCodes, Codes3),
    number_codes(Width, WidthCodes),
    number_codes(Height, HeightCodes),
    skip_one_separator(Codes3, Raster).

read_token(Codes0, Token, Rest) :-
    skip_spaces_comments(Codes0, Codes),
    Codes = [C|_],
    C =\= 35,
    take_token(Codes, Token, Rest0),
    Rest = Rest0.

take_token([], [], []).
take_token([C|Cs], [], [C|Cs]) :-
    ( code_type(C, space) ; C =:= 35 ), !.
take_token([C|Cs], [C|Token], Rest) :-
    take_token(Cs, Token, Rest).

skip_spaces_comments([], []).
skip_spaces_comments([35|Cs], Rest) :- !,
    skip_comment(Cs, AfterComment),
    skip_spaces_comments(AfterComment, Rest).
skip_spaces_comments([C|Cs], Rest) :-
    code_type(C, space), !,
    skip_spaces_comments(Cs, Rest).
skip_spaces_comments(Codes, Codes).

skip_comment([], []).
skip_comment([10|Cs], Cs) :- !.
skip_comment([_|Cs], Rest) :-
    skip_comment(Cs, Rest).

/* Remove exactly one header separator after the dimensions. */
skip_one_separator([C|Cs], Cs) :-
    code_type(C, space), !.
skip_one_separator(Codes, Codes).

/* -----------------------------------------------------------------
   Pixel relation
   ----------------------------------------------------------------- */

pixel(X, Y, Width, Height, BytesPerRow, Data, Pixel) :-
    MaxX is Width - 1,
    between(0, MaxX, X)
    MaxY is Height - 1,
    between(0, MaxY, Y)
    ByteIndex is Y * BytesPerRow + X // 8,
    nth0(ByteIndex, Data, Byte),
    Bit is 7 - (X mod 8),
    Pixel is (Byte >> Bit) /\ 1.

/* -----------------------------------------------------------------
   f(X): number of consecutive black pixels from the bottom
   ----------------------------------------------------------------- */

f(X, Width, Height, BytesPerRow, Data, Altura) :-
    X >= 0,
    X < Width,
    Bottom is Height - 1,
    consecutive_black(X, Bottom, Width, Height, BytesPerRow, Data, Altura).

consecutive_black(_, Y, _, _, _, _, 0) :-
    Y < 0, !.
consecutive_black(X, Y, Width, Height, BytesPerRow, Data, Altura) :-
    pixel(X, Y, Width, Height, BytesPerRow, Data, 0), !,
    Altura = 0.
consecutive_black(X, Y, Width, Height, BytesPerRow, Data, Altura) :-
    pixel(X, Y, Width, Height, BytesPerRow, Data, 1),
    NextY is Y - 1,
    consecutive_black(X, NextY, Width, Height, BytesPerRow, Data, Rest),
    Altura is Rest + 1.

/* Declarative construction of M */
heights(Width, Height, BytesPerRow, Data, M) :-
    MaxX is Width - 1,
    findall(
        Altura,
        ( between(0, MaxX, X),
          f(X, Width, Height, BytesPerRow, Data, Altura)
        ),
        M
    ).

/* -----------------------------------------------------------------
   Console visualization
   ----------------------------------------------------------------- */

draw_image(Width, Height, BytesPerRow, Data, MaxW, MaxH) :-
    SX is max(1, (Width + MaxW - 1) // MaxW),
    SY is max(1, (Height + MaxH - 1) // MaxH),
    MaxY is Height - 1,
    between_step(0, MaxY, SY, Y),
    draw_image_row(0, Width, SX, Y, SY, Width, Height, BytesPerRow, Data),
    nl,
    fail.
draw_image(_, _, _, _, _, _) :- true.

draw_image_row(X, Width, _, _, _, _, _, _, _) :-
    X >= Width, !.
draw_image_row(X, Width, SX, Y, SY, ImgW, ImgH, BytesPerRow, Data) :-
    block_black(X, Y, SX, SY, ImgW, ImgH, BytesPerRow, Data),
    write('█'),
    X2 is X + SX,
    draw_image_row(X2, Width, SX, Y, SY, ImgW, ImgH, BytesPerRow, Data).
draw_image_row(X, Width, SX, Y, SY, ImgW, ImgH, BytesPerRow, Data) :-
    write(' '),
    X2 is X + SX,
    draw_image_row(X2, Width, SX, Y, SY, ImgW, ImgH, BytesPerRow, Data).

block_black(X, Y, SX, SY, Width, Height, BytesPerRow, Data) :-
    XEnd is min(Width - 1, X + SX - 1),
    YEnd is min(Height - 1, Y + SY - 1),
    between(X, XEnd, PX),
    between(Y, YEnd, PY),
    pixel(PX, PY, Width, Height, BytesPerRow, Data, 1),
    !.

between_step(Current, Max, _, Current) :-
    Current =< Max.
between_step(Current, Max, Step, Value) :-
    Current =< Max,
    Next is Current + Step,
    between_step(Next, Max, Step, Value).

draw_heights(M, MaxW, MaxH) :-
    length(M, N),
    SX is max(1, (N + MaxW - 1) // MaxW),
    compact_maxima(M, SX, Compact),
    max_list([1|Compact], MaxValue),
    scale_heights(Compact, MaxValue, MaxH, Scaled),
    draw_height_rows(MaxH, Scaled),
    length(Scaled, Len),
    draw_line(Len),
    nl.

compact_maxima([], _, []).
compact_maxima(List, Size, [Max|Rest]) :-
    take(Size, List, Group, Remaining),
    max_list(Group, Max),
    compact_maxima(Remaining, Size, Rest).

take(0, List, [], List) :- !.
take(_, [], [], []).
take(N, [X|Xs], [X|Taken], Rest) :-
    N > 0,
    N1 is N - 1,
    take(N1, Xs, Taken, Rest).

scale_heights([], _, _, []).
scale_heights([V|Vs], MaxValue, MaxH, [S|Ss]) :-
    S is (V * MaxH + MaxValue - 1) // MaxValue,
    scale_heights(Vs, MaxValue, MaxH, Ss).

draw_height_rows(0, _) :- !.
draw_height_rows(Row, Values) :-
    draw_height_row(Row, Values),
    nl,
    Next is Row - 1,
    draw_height_rows(Next, Values).

draw_height_row(_, []).
draw_height_row(Row, [V|Vs]) :-
    ( V >= Row -> write('█') ; write(' ') ),
    draw_height_row(Row, Vs).

draw_line(0) :- !.
draw_line(N) :-
    write('─'),
    N1 is N - 1,
    draw_line(N1).

show_samples(M, Count) :-
    length(M, N),
    Step is max(1, (N + Count - 1) // Count),
    show_samples_from(0, Step, Count, N, M).

show_samples_from(_, _, 0, _, _) :- !.
show_samples_from(X, _, _, N, _) :-
    X >= N, !.
show_samples_from(X, Step, Remaining, N, M) :-
    nth0(X, M, HeightValue),
    format('x = ~w -> f(x) = ~w pixels~n', [X, HeightValue]),
    NextX is X + Step,
    NextRemaining is Remaining - 1,
    show_samples_from(NextX, Step, NextRemaining, N, M).
