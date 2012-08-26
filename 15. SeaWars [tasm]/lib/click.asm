
; Click
;
; Click events.
; It's part of SeaWars game.
;
; Tasm file.
; Charset cp1251.
;
; Copyright (C) 2012, Georgy Bazhukov.
;
; This program is free software, you can redistribute it and/or modify it under
; the terms of the Artistic License version 2.0.


; Select - which of action
; will runs on this click.

click_route proc
    
    ; Which zone was clicked?
    ; Zones:
    ;   - Self game field;
    ;   - Enemy's game field;
    ;   - My ships.
    
    ; get click pos
    mov dl, mouse_status_position_x
    mov dh, mouse_status_position_y
    
    click_route_exit:
    
    ret
click_route endp
