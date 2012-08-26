
; Ship
;
; Ships data and logic.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.

; Data
ship_self_1_count   db 4
ship_self_2_count   db 2
ship_self_3_count   db 1
ship_self_4_count   db 0

ship_enemy_1_count  db 0
ship_enemy_2_count  db 1
ship_enemy_3_count  db 2
ship_enemy_4_count  db 4

; 4*10 ships - MAX
ship_self_1_xy_1    dw 10 dup(0) ; xy dword

ship_self_2_xy_1    dw 10 dup(0)
ship_self_2_xy_2    dw 10 dup(0)

ship_self_3_xy_1    dw 10 dup(0)
ship_self_3_xy_2    dw 10 dup(0)
ship_self_3_xy_3    dw 10 dup(0)

ship_self_4_xy_1    dw 10 dup(0)
ship_self_4_xy_2    dw 10 dup(0)
ship_self_4_xy_3    dw 10 dup(0)
ship_self_4_xy_4    dw 10 dup(0)

; Enemy's ship
ship_enemy_1_xy_1    dw 10 dup(0) ; xy dword

ship_enemy_2_xy_1    dw 10 dup(0)
ship_enemy_2_xy_2    dw 10 dup(0)

ship_enemy_3_xy_1    dw 10 dup(0)
ship_enemy_3_xy_2    dw 10 dup(0)
ship_enemy_3_xy_3    dw 10 dup(0)

ship_enemy_4_xy_1    dw 10 dup(0)
ship_enemy_4_xy_2    dw 10 dup(0)
ship_enemy_4_xy_3    dw 10 dup(0)
ship_enemy_4_xy_4    dw 10 dup(0)
