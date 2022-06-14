globals[
  ;número de jugadores con cada estrategia
  num-siempre-cooperar
  num-siempre-delatar
  num-tit-for-tat
  num-pavlov
  num-aleatorio
  num-friedman

  ;número de interacciones por cada estrategia
  num-juegos-cooperar
  num-juegos-delatar
  num-juegos-tit-for-tat
  num-juegos-pavlov
  num-juegos-aleatorio
  num-juegos-propia
  num-juegos-friedman

  ;puntuación total de todos los jugadores de cada estrategia
  puntuacion-siempre-cooperar
  puntuacion-siempre-delatar
  puntuacion-tit-for-tat
  puntuacion-pavlov
  puntuacion-aleatorio
  puntuacion-propia
  puntuacion-friedman

  puntuacion-propia-ronda-actual

  group-sites

  lista
]

turtles-own[
  estrategia
  puntuacion
  delatar-ahora?
  compañero-delató?
  tengo-compañero?
  compañero
  historial-compañero
  misma-jugada?
  misma-jugada-compañero

  my-group-site
]


;;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to setup
  clear-all
  ifelse S >= P
    [user-message "Matriz de pagos no válida. Compruebe que T > R > P > S" stop]
    [ifelse S >= R
      [user-message "Matriz de pagos no válida. Compruebe que T > R > P > S" stop]
      [ifelse S >= T
        [user-message "Matriz de pagos no válida. Compruebe que T > R > P > S" stop]
        [ifelse P >= R
          [user-message "Matriz de pagos no válida. Compruebe que T > R > P > S" stop]
          [ifelse P >= T
            [user-message "Matriz de pagos no válida. Compruebe que T > R > P > S" stop]
            [ifelse R >= T
              [user-message "Matriz de pagos no válida. Compruebe que T > R > P > S" stop]
              []
            ]
          ]
        ]
      ]
    ]
  registrar-numero-de-jugadores-con-cada-estrategia
  mostrar-totaljugadores
  if (num-siempre-cooperar + num-siempre-delatar + num-tit-for-tat + num-pavlov + num-aleatorio + num-friedman + 1) < 2 [
    user-message "Tiene que haber como mínimo 2 jugadores. Revise la configuración de oponentes"
    stop
  ]
  if int((num-siempre-cooperar + num-siempre-delatar + num-tit-for-tat + num-pavlov + num-aleatorio + num-friedman + 1) / 2) < ((num-siempre-cooperar + num-siempre-delatar + num-tit-for-tat + num-pavlov + num-aleatorio + num-friedman + 1) / 2) [
    user-message "Tiene que haber un número par de jugadores. Revise la configuración de oponentes."
    stop
  ]
  ifelse ronda-a-ronda
     [ifelse fijar-estrategia-para-las-n-rondas
        [user-message "Seleccione un único modo de juego" stop]
        []
     ]
     [ifelse fijar-estrategia-para-las-n-rondas
        []
        [user-message "Seleccione un modo de juego" stop]
     ]
  crear-y-configurar-jugadores
  set lista []
  reset-ticks
end

to registrar-numero-de-jugadores-con-cada-estrategia
  set num-siempre-cooperar Siempre-cooperar
  set num-siempre-delatar Siempre-delatar
  set num-tit-for-tat Tit-for-tat
  set num-pavlov Pavlov
  set num-aleatorio Aleatorio
  set num-friedman Friedman
end

to mostrar-totaljugadores
  output-print "Número de"
  output-print "jugadores"
  output-print "totales"
  output-print "(incluido"
  output-print "el usuario):"
  output-print num-siempre-cooperar + num-siempre-delatar + num-tit-for-tat + num-pavlov + num-aleatorio + num-friedman + 1
end

to crear-y-configurar-jugadores
  set group-sites patches with [group-site?]
  ask group-sites [ set plabel "VS" ]
  set-default-shape turtles "person"
  create-turtles num-siempre-cooperar [ set estrategia "siempre-cooperar" set color grey set size 6 loop [set my-group-site one-of group-sites move-to my-group-site if count turtles-here <= 2 [stop]]]
  create-turtles num-siempre-delatar [ set estrategia "siempre-delatar" set color grey set size 6 loop [set my-group-site one-of group-sites move-to my-group-site if count turtles-here <= 2 [stop]]]
  create-turtles num-tit-for-tat [ set estrategia "tit-for-tat" set color grey set size 6 loop [set my-group-site one-of group-sites move-to my-group-site if count turtles-here <= 2 [stop]]]
  create-turtles num-pavlov [ set estrategia "pavlov" set color grey set size 6 loop [set my-group-site one-of group-sites move-to my-group-site if count turtles-here <= 2 [stop]]]
  create-turtles num-aleatorio [ set estrategia "aleatorio" set color grey set size 6 loop [set my-group-site one-of group-sites move-to my-group-site if count turtles-here <= 2 [stop]]]
  create-turtles num-friedman [ set estrategia "friedman" set color grey set size 6 loop [set my-group-site one-of group-sites move-to my-group-site if count turtles-here <= 2 [stop]]]
  create-turtles 1 [set estrategia "propia" set color grey set size 6 loop [set my-group-site one-of group-sites move-to my-group-site if count turtles-here <= 2 [stop]]]
  ask turtles [ spread-out-vertically ]
  ask turtles [
    set puntuacion 0
    set tengo-compañero? false
    set compañero nobody
  ]
  let num-jugadores count turtles
  let historial []
  repeat num-jugadores [ set historial (fput false historial) ]
  ask turtles [ set historial-compañero historial ]
  let misma-jugada []
  repeat num-jugadores [ set misma-jugada (fput true misma-jugada) ]
  ask turtles [ set misma-jugada-compañero misma-jugada ]
end

to-report group-site? ; ver Ref[1]
  let group-interval floor (world-width / ((num-siempre-cooperar + num-siempre-delatar + num-tit-for-tat + num-pavlov + num-aleatorio + num-friedman + 1) / 2))
  report
    (pycor = 0) and
    (pxcor <= 0) and
    (pxcor mod group-interval = 0) and
    (floor ((- pxcor) / group-interval) < ((num-siempre-cooperar + num-siempre-delatar + num-tit-for-tat + num-pavlov + num-aleatorio + num-friedman + 1) / 2))
end

to spread-out-vertically ; ver Ref[1]
  ifelse any? other turtles-here
    [ set heading 180 ]
    [ set heading   0 ]
  fd 4
end


;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


to go
  ifelse ticks < n-rondas [
    ask turtles [
      set tengo-compañero? false
      set compañero nobody
      set label ""
    ]
    ask turtles [distribuirse]
    ask turtles [spread-out-vertically]
    ask turtles [seleccionar-compañero]
    ask turtles [color-segun-estrategia]
    ask turtles [seleccionar-accion]
    ask turtles [jugar-una-ronda]
    ask turtles [mi-puntuacion-en-ronda-actual]
    puntuacion-total
    tick
  ]
  [user-message "Se han completado todas las rondas. Juego finalizado."]
end

to distribuirse
  loop [set my-group-site one-of group-sites move-to my-group-site if count turtles-here <= 2 [stop]]
end

to seleccionar-compañero
  if (not tengo-compañero?)[
    set compañero one-of (turtles-at 0 8) with [ not tengo-compañero? ]
    if compañero != nobody [
      set tengo-compañero? true
      ask compañero [
        set tengo-compañero? true
        set compañero myself
      ]
    ]
  ]
end

to color-segun-estrategia
  if estrategia = "siempre-cooperar" [ set color blue ]
  if estrategia = "siempre-delatar" [ set color red ]
  if estrategia = "tit-for-tat" [ set color green ]
  if estrategia = "pavlov" [ set color yellow ]
  if estrategia = "aleatorio" [ set color magenta ]
  if estrategia = "propia" [ set color cyan ]
  if estrategia = "friedman" [ set color pink ]
end

to seleccionar-accion
  if estrategia = "siempre-cooperar" [ accion-cooperar ]
  if estrategia = "siempre-delatar" [ accion-delatar ]
  if estrategia = "tit-for-tat" [ accion-tit-for-tat ]
  if estrategia = "pavlov" [ accion-pavlov ]
  if estrategia = "aleatorio" [ accion-aleatorio ]
  if estrategia = "friedman" [ accion-friedman ]
  if estrategia = "propia" [ accion-propia ]
end

to jugar-una-ronda
  ganancia
  actualizar-historial
end

to ganancia
  set compañero-delató? [delatar-ahora?] of compañero
  ifelse compañero-delató? [
    ifelse delatar-ahora? [
      set puntuacion (puntuacion + P) set label "delata" set lista lput P lista set misma-jugada? true
    ] [
      set puntuacion (puntuacion + S) set label "coopera" set lista lput S lista set misma-jugada? false
    ]
  ] [
    ifelse delatar-ahora? [
      set puntuacion (puntuacion + T) set label "delata" set lista lput T lista set misma-jugada? false
    ] [
      set puntuacion (puntuacion + R) set label "coopera" set lista lput R lista set misma-jugada? true
    ]
  ]
end

to actualizar-historial
  if estrategia = "siempre-cooperar" [ siempre-cooperar-actualizacion-historial ]
  if estrategia = "siempre-delatar" [ siempre-delatar-actualizacion-historial ]
  if estrategia = "tit-for-tat" [ tit-for-tat-actualizacion-historial ]
  if estrategia = "pavlov" [ pavlov-actualizacion-historial ]
  if estrategia = "aleatorio" [ aleatorio-actualizacion-historial ]
  if estrategia = "friedman" [ friedman-actualizacion-historial ]
  if estrategia = "propia" [ propia-actualizacion-historial ]
end

to mi-puntuacion-en-ronda-actual
  if estrategia = "propia"[
    ifelse compañero-delató? [
      ifelse delatar-ahora? [
        set puntuacion-propia-ronda-actual P
      ] [
        set puntuacion-propia-ronda-actual S
      ]
    ] [
      ifelse delatar-ahora? [
        set puntuacion-propia-ronda-actual T
      ] [
        set puntuacion-propia-ronda-actual R
      ]
    ]
  ]
end

to accion-cooperar
  set num-juegos-cooperar num-juegos-cooperar + 1
  set delatar-ahora? false
end

to siempre-cooperar-actualizacion-historial
  ; no usa historial
end

to accion-delatar
  set num-juegos-delatar num-juegos-delatar + 1
  set delatar-ahora? true
end

to siempre-delatar-actualizacion-historial
  ; no usa historial
end

to accion-tit-for-tat  ; ver Ref[2]
  set num-juegos-tit-for-tat num-juegos-tit-for-tat + 1
  set compañero-delató? item ([who] of compañero) historial-compañero
  ifelse (compañero-delató?)
    [set delatar-ahora? true]
    [set delatar-ahora? false]
end

to tit-for-tat-actualizacion-historial  ; ver Ref[2]
  set historial-compañero
    (replace-item ([who] of compañero) historial-compañero compañero-delató?)
end

to accion-pavlov
  set num-juegos-pavlov num-juegos-pavlov + 1
  set misma-jugada? item ([who] of compañero) misma-jugada-compañero
  ifelse (misma-jugada?)
    [set delatar-ahora? false]
    [set delatar-ahora? true]
end

to pavlov-actualizacion-historial
  set misma-jugada-compañero
    (replace-item ([who] of compañero) misma-jugada-compañero misma-jugada?)
end

to accion-aleatorio
  set num-juegos-aleatorio num-juegos-aleatorio + 1
  ifelse (random-float 1.0 < 0.5) [
    set delatar-ahora? false
  ] [
    set delatar-ahora? true
  ]
end

to aleatorio-actualizacion-historial
  ; no usa historial
end


to accion-friedman  ; ver Ref[2]
  set num-juegos-friedman num-juegos-friedman + 1
  set compañero-delató? item ([who] of compañero) historial-compañero
  ifelse (compañero-delató?)
    [set delatar-ahora? true]
    [set delatar-ahora? false]
end

to friedman-actualizacion-historial ; ver Ref[2]
  if compañero-delató? [
    set historial-compañero
      (replace-item ([who] of compañero) historial-compañero compañero-delató?)
  ]
end


to accion-propia
  set num-juegos-propia num-juegos-propia + 1
  if ronda-a-ronda [
    ifelse mi-estrategia-para-ronda-actual = "Cooperar" [set delatar-ahora? false] [set delatar-ahora? true]
  ]
  if fijar-estrategia-para-las-n-rondas [
    if mi-estrategia-para-las-n-rondas = "Siempre cooperar" [set delatar-ahora? false]
    if mi-estrategia-para-las-n-rondas = "Siempre delatar" [set delatar-ahora? true]
    if mi-estrategia-para-las-n-rondas = "Tit for tat" [set compañero-delató? item ([who] of compañero) historial-compañero ifelse (compañero-delató?) [set delatar-ahora? true] [set delatar-ahora? false]]
    if mi-estrategia-para-las-n-rondas = "Pavlov" [set misma-jugada? item ([who] of compañero) misma-jugada-compañero ifelse (misma-jugada?) [set delatar-ahora? false] [set delatar-ahora? true]]
    if mi-estrategia-para-las-n-rondas = "Friedman" [set compañero-delató? item ([who] of compañero) historial-compañero ifelse (compañero-delató?) [set delatar-ahora? true] [set delatar-ahora? false]]
  ]
end

to propia-actualizacion-historial
  if fijar-estrategia-para-las-n-rondas [
    if mi-estrategia-para-las-n-rondas = "Tit for tat" [set historial-compañero (replace-item ([who] of compañero) historial-compañero compañero-delató?)]
    if mi-estrategia-para-las-n-rondas = "Pavlov" [set misma-jugada-compañero (replace-item ([who] of compañero) misma-jugada-compañero misma-jugada?)]
    if mi-estrategia-para-las-n-rondas = "Friedman" [if compañero-delató? [set historial-compañero (replace-item ([who] of compañero) historial-compañero compañero-delató?)]]
  ]
end


to puntuacion-total ; ver Ref[2]
  set puntuacion-siempre-cooperar (calc-score "siempre-cooperar" num-siempre-cooperar)
  set puntuacion-siempre-delatar (calc-score "siempre-delatar" num-siempre-delatar)
  set puntuacion-tit-for-tat (calc-score "tit-for-tat" num-tit-for-tat)
  set puntuacion-pavlov (calc-score "pavlov" num-pavlov)
  set puntuacion-aleatorio (calc-score "aleatorio" num-aleatorio)
  set puntuacion-friedman (calc-score "friedman" num-friedman)
  set puntuacion-propia (calc-score "propia" 1)
end


to-report calc-score [strategy-type num-with-strategy] ; ver Ref[2]
  ifelse num-with-strategy > 0 [
    report (sum [ puntuacion ] of (turtles with [ estrategia = strategy-type ]))
  ] [
    report 0
  ]
end



;******************************************************************************************************************************************************
;
; Referencias y atribución. Los fragmentos de código referenciados como "ver Ref[i]" proceden de las siguientes obras:
;
; [1] Wilensky, U. (1997). NetLogo Party model. http://ccl.northwestern.edu/netlogo/models/Party. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
; [2] Wilensky, U. (2002). NetLogo PD N-Person Iterated model. http://ccl.northwestern.edu/netlogo/models/PDN-PersonIterated. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
;
@#$#@#$#@
GRAPHICS-WINDOW
250
10
1240
97
-1
-1
4.613
1
10
1
1
1
0
1
0
1
-208
4
-8
8
1
1
1
ticks
30.0

TEXTBOX
54
142
175
176
Matriz de pagos:
15
103.0
1

SLIDER
210
167
314
200
R
R
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
210
200
314
233
S
S
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
210
232
314
265
T
T
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
210
265
314
298
P
P
0
10
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
63
165
213
291
                         Prisionero 2   \nPrisionero 1         C          D\n----------------------------------\n    C                    R,R      S,T  \n----------------------------------\n    D                    T,S      P,P\n----------------------------------\n\n(C = Cooperar, D = Delatar)
10
0.0
1

TEXTBOX
52
439
257
473
Modo de juego:
15
103.0
1

SWITCH
170
443
384
476
ronda-a-ronda
ronda-a-ronda
0
1
-1000

SWITCH
170
476
384
509
fijar-estrategia-para-las-n-rondas
fijar-estrategia-para-las-n-rondas
1
1
-1000

CHOOSER
601
158
891
203
mi-estrategia-para-ronda-actual
mi-estrategia-para-ronda-actual
"Cooperar" "Delatar"
0

CHOOSER
927
160
1217
205
mi-estrategia-para-las-n-rondas
mi-estrategia-para-las-n-rondas
"Siempre cooperar" "Siempre delatar" "Friedman" "Tit for tat" "Pavlov"
2

TEXTBOX
53
304
143
342
Oponentes:\n\n
15
103.0
1

SLIDER
65
327
185
360
Siempre-cooperar
Siempre-cooperar
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
185
327
305
360
Siempre-delatar
Siempre-delatar
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
65
393
185
426
Tit-for-tat
Tit-for-tat
0
10
9.0
1
1
NIL
HORIZONTAL

SLIDER
185
393
305
426
Pavlov
Pavlov
0
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
65
360
185
393
Aleatorio
Aleatorio
0
10
6.0
1
1
NIL
HORIZONTAL

OUTPUT
319
327
439
426
11

TEXTBOX
332
142
460
196
Número de rondas:
15
103.0
1

BUTTON
78
47
234
88
SETUP
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
601
203
891
236
JUGAR RONDA ACTUAL
go\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
927
205
1217
238
JUGAR LAS N RONDAS
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
79
10
222
56
Antes de comenzar a jugar, se recomienda leer la pestaña \"Información\"
9
16.0
1

PLOT
688
323
1065
507
Ganancia media 
Iteraciones
Ganancia media
0.0
10.0
4.0
5.0
true
true
"" ""
PENS
"Siempre cooperar" 1.0 0 -13345367 true "" "if num-juegos-cooperar > 0 [ plot puntuacion-siempre-cooperar / (num-juegos-cooperar) ]"
"Siempre delatar" 1.0 0 -2674135 true "" "if num-juegos-delatar > 0 [ plot puntuacion-siempre-delatar / (num-juegos-delatar) ]"
"Aleatorio" 1.0 0 -5825686 true "" "if num-juegos-aleatorio > 0 [ plot puntuacion-aleatorio / (num-juegos-aleatorio) ]"
"Friedman" 1.0 0 -2064490 true "" "if num-juegos-friedman > 0 [ plot puntuacion-friedman / (num-juegos-friedman) ]"
"Tit-for-tat" 1.0 0 -10899396 true "" "if num-juegos-tit-for-tat > 0 [ plot puntuacion-tit-for-tat / (num-juegos-tit-for-tat) ]"
"Pavlov" 1.0 0 -1184463 true "" "if num-juegos-pavlov > 0 [ plot puntuacion-pavlov / (num-juegos-pavlov) ]"
"Estrategia usuario" 1.0 0 -11221820 true "" "if num-juegos-propia > 0 [ plot puntuacion-propia / (num-juegos-propia) ]"
"Ganancia media total" 1.0 0 -16777216 true "" "if num-juegos-propia > 0 [plot (puntuacion-siempre-cooperar + puntuacion-siempre-delatar + puntuacion-tit-for-tat + puntuacion-pavlov + puntuacion-aleatorio + puntuacion-propia) / (num-juegos-cooperar + num-juegos-delatar + num-juegos-tit-for-tat + num-juegos-pavlov + num-juegos-aleatorio + num-juegos-propia)]"

BUTTON
601
235
891
268
JUGAR RONDAS RESTANTES CON ESTRATEGIA ACTUAL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
525
324
681
369
Mi ganancia en la última ronda
puntuacion-propia-ronda-actual
17
1
11

MONITOR
525
371
681
416
Mi ganancia acumulada
puntuacion-propia
17
1
11

PLOT
1069
323
1304
507
Distribución ganancia población
Ganancia 
Frecuencia
0.0
11.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -5298144 true "" "histogram lista"

INPUTBOX
371
169
429
229
n-rondas
100.0
1
0
Number

TEXTBOX
836
106
1034
140
MI ESTRATEGIA:
17
103.0
1

TEXTBOX
586
140
798
170
Si modo de juego = ronda-a-ronda:
12
93.0
1

TEXTBOX
916
141
1227
164
Si modo de juego = fijar-estrategia-para-las-n-rondas:
12
93.0
1

TEXTBOX
133
109
388
132
CONFIGURACIÓN DEL JUEGO:
17
14.0
1

TEXTBOX
824
288
1019
308
EVOLUCIÓN DEL JUEGO:
17
74.0
1

SLIDER
185
360
305
393
Friedman
Friedman
0
10
4.0
1
1
NIL
HORIZONTAL

TEXTBOX
42
123
493
148
--------------------------------------------------------------
20
14.0
1

TEXTBOX
472
138
493
578
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
18
14.0
1

TEXTBOX
43
503
520
521
--------------------------------------------------------------
20
14.0
1

TEXTBOX
37
137
52
511
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
18
14.0
1

TEXTBOX
579
119
1237
140
--------------------------------------------------------------------------------------------
20
103.0
1

TEXTBOX
579
266
1227
286
--------------------------------------------------------------------------------------------
20
103.0
1

TEXTBOX
1223
128
1241
284
|\n|\n|\n|\n|\n|\n|
18
103.0
1

TEXTBOX
572
128
587
282
|\n|\n|\n|\n|\n|\n|
18
103.0
1

TEXTBOX
516
301
1321
326
------------------------------------------------------------------------------------------------------------------
20
74.0
1

TEXTBOX
516
502
1323
521
------------------------------------------------------------------------------------------------------------------
20
74.0
1

TEXTBOX
1310
315
1325
513
|\n|\n|\n|\n|\n|\n|\n|\n|\n
18
74.0
1

TEXTBOX
512
315
527
513
|\n|\n|\n|\n|\n|\n|\n|\n|\n
18
74.0
1

@#$#@#$#@
## DE QUÉ SE TRATA

Este modelo es una implementación del juego del Dilema del Prisionero Iterado. El Dilema del Prisionero Iterado es el juego del Dilema del Prisionero jugado en repetidas ocasiones.

El modelo permitirá al usuario jugar durante varias rondas al juego del Dilema del Prisionero, enfrentándose a un grupo de personas virtuales (u oponentes). El juego se juega en parejas, pero no siempre con la misma pareja. En cada ronda se formarán nuevas parejas al azar.

## QUÉ ES EL DILEMA DEL PRISIONERO

El Dilema del Prisionero es un problema fundamental de la Teoría de Juegos que analiza la cooperación humana. Para ello, muestra los años de reducción de una condena que pueden conseguir dos prisioneros en función de si permanecen callados (cooperan con el compañero) o confiesan (delatan al compañero). Se puede representar mediante la siguiente matriz de pagos:

```text
             |  Prisionero 2
Prisionero 1 |
             |   C       D
-------------|-----------------
       C     |  R,R     S,T
-------------|-----------------
       D     |  T,S     P,P
-------------|-----------------
  (C = Cooperar, D = Delatar)
```

La definición del Dilema del Prisionero exige que se cumpla que T > R > P > S. Pongamos el caso de que T = 4, R = 3, P = 1 y S = 0:

- Si uno delata y el otro coopera, el que ha delatado consigue una reducción de 4 años (T=4), mientras que el que ha cooperado no obtiene ninguna reducción en su condena (S=0).
- Si ambos delatan, ambos consiguen una reducción de tan solo 1 año (P=1).
- Si ambos cooperan, ambos consiguen una reducción de 3 años en su condena (R=3).

El dilema del prisionero gira en torno a una idea: ninguno de los dos prisioneros sabe qué decisión va a tomar el compañero. 

Nos referiremos a los años de reducción de la condena como "ganancia", ya que el objetivo de cada jugador es conseguir el máximo número de años de reducción posible, o lo que es lo mismo, la mayor "ganancia" posible.

## CÓMO JUGAR

Para jugar, el usuario deberá seguir los siguientes pasos:

1. Realizar la configuración del juego.
2. Pulsar el botón SETUP.
3. Definir su estrategia y comenzar a jugar.

### 1. Realizar la configuración del juego

#### Matriz de pagos

Definir la matriz de pagos del juego, es decir, los valores de R, S, T y P. 

#### Oponentes

Definir el número de oponentes que juegan cada estrategia. Las estrategias que pueden jugar los oponentes son las siguientes:

- SIEMPRE COOPERAR: Coopera en todas las rondas. 

- SIEMPRE DELATAR: Delata en todas las rondas.

- ALEATORIO: Coopera o delata aleatoriamente.

- FRIEDMAN: Aplica el principio de la represalia permanente. Empieza cooperando en todas las rondas, pero en cuanto su oponente no lo hace, aunque sólo sea una vez, nunca vuelve a cooperar con él.

- TIT FOR TAT: Si su oponente coopera en esta ronda, cooperará en la próxima ronda que se enfrente a él. Si su oponente delata en esta ronda, delatará en la próxima ronda que se enfrente a él. Inicialmente coopera.

- PAVLOV: Coopera si tanto su oponente como él hicieron lo mismo (ambos cooperaron o ambos delataron) en la anterior vez que se enfrentaron. De lo contrario delata. Inicialmente coopera.

#### Número de rondas

Definir el número de rondas del juego.

#### Modo de juego

Existen dos posibles modos de juego. El usuario deberá seleccionar uno de ellos:

- Jugar ronda a ronda.
- Fijar una estrategia para las N rondas del juego.

### 2. Pulsar el botón SETUP

Una vez realizada la configuración del juego, el usuario deberá pulsar el botón SETUP para que el modelo guarde los parámetros configurados y compruebe que son válidos. El modelo comprobará que T > R > P > S; que haya un número par de jugadores (incluido el usuario) para poder formar parejas en cada ronda; y que únicamente esté seleccionado (en "ON") un modo de juego. Si algo de esto no se cumple, arrojará un aviso para que el usuario lo modifique.

### 3. Definir su estrategia y comenzar a jugar

#### En caso de haber elegido como modo de juego "jugar-ronda-a-ronda": 
El usuario deberá definir su estrategia (cooperar o delatar) para la ronda actual, y a continuación pulsar el botón "JUGAR RONDA ACTUAL". Esto lo deberá hacer tantas veces como rondas haya definido en la configuración del juego. También tiene la opción de jugar las rondas restantes con la estrategia actual, pulsando el botón "JUGAR RONDAS RESTANTES CON ESTRATEGIA ACTUAL".

#### En caso de haber elegido como modo de juego "fijar-estrategia-para-las-n-rondas": 
El usuario deberá fijar su estrategia para las N rondas del juego, seleccionando de un menú desplegable la estrategia que va a querer jugar durante las N rondas (Siempre Cooperar, Siempre Delatar, Friedman, Tit for Tat o Pavlov). A continuación deberá pulsar el botón "JUGAR LAS N RONDAS".

## EVOLUCIÓN DEL JUEGO

Durante la ejecución del juego, el usuario podrá ver la evolución del mismo a través de:

#### "MI GANANCIA EN LA ÚLTIMA RONDA" Y "MI GANANCIA ACUMULADA":
El usuario recibirá un feedback de su ganancia en la ronda anterior y de su ganancia acumulada.

#### GRÁFICO "GANANCIA MEDIA":
Muestra la evolución temporal de la ganancia media de los jugadores que juegan cada estrategia, así como de la ganancia media total de toda la población.

#### HISTOGRAMA "DISTRIBUCIÓN GANANCIA POBLACIÓN":
Muestra la distribución de la ganancia acumulada de la población, a través de un histograma.

## VENTANA DEL JUEGO
La ventana del juego (rectángulo negro) muestra las parejas que se van formando en cada ronda y qué está haciendo cada jugador en cada una de ellas (cooperar o delatar). El color de cada jugador representa el tipo de jugador que es:

- Azul: siempre cooperar
- Rojo: siempre delatar
- Magenta: aleatorio
- Rosa: Friedman
- Verde: Tit for tat
- Amarillo: Pavlov
- Azul celeste: usuario

## CASOS PRÁCTICOS

Pruebe los siguientes casos y observe los resultados:

- Jugar contra todo cooperadores
- Jugar contra todo defectores (los que siempre eligen delatar)
- Jugar contra una población variada
- Jugar con la estrategia Tit for Tat contra otros Tit for Tat
- Jugar un número de rondas bajo vs un número de rondas alto
- Jugar contra pocos oponentes vs contra muchos oponentes
- Etc...

## COPYRIGHT Y LICENCIA

Copyright 2022 Pablo Lorente y María Pereda.

![CC BY-NC-SA 4.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

Este trabajo está licenciado bajo una licencia Creative Commons Attribution-NonCommercial-ShareAlike 4.0. Para ver una copia de esta licencia, visita https://creativecommons.org/licenses/by-nc-sa/4.0/ or envía una carta a Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
