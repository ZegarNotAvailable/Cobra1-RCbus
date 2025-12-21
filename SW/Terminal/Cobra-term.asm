;*********************************************************************
        .cr z80                     
        .tf Cbr_term.hex,int   
        .lf Cobra-term.lst
        .sf Cobra-term.sym       
;        .in ca80.inc
;*********************************************************************
        .sm code           ; 
        .or $F000          ;
;**************************************************************************
DATA_8251       .EQ 0E4H                ; Data register on channel A      *
CONTR_8251      .EQ 0E5H                ; Control registers on channel A  *
eos             .equ    $00             ; End of string                   *  
cr              .equ    $0d             ; Carriage return                 *
lf              .equ    $0a             ; Line feed                       *
space           .equ    $20             ; Space                           *
COBRA_HOT       .EQ     0C010H          ; Hot start                       *
COBRA_PUTC      .EQ     0C51AH          ; Print char of Cobra             *
COBRA_CLS       .EQ     0C5D7H          ; CLS of Cobra                    *
;**************************************************************************
ECHO:   
        LD      SP,0BFF0h
        CALL    0C6F7H 
        LD      HL,ECHO1
        LD      (0BFF8H),HL
        CALL    INIT_8251       ; MIK1
    ;    CALL    INIT_BUFFER
        CALL    COBRA_CLS
        LD      hl, hello_msg
        CALL    puts
        CALL    crlf
    ;    CALL    FLUSH_TX
        JP      COBRA_HOT
ECHO1:  CALL    PUTC
        CALL    COBRA_PUTC
    ;    CALL    FLUSH_TX
        RET

;
; Message definitions
;
hello_msg       .DB   "Cobra terminal - for CA80", eos

;
; Send a string to the serial line, HL contains the pointer to the string:
;
puts            push    af
;                push    hl
puts_loop       ld      a, (hl)
                cp      eos             ; End of string reached?
                jr      z, puts_end     ; Yes
                call    putc
                inc     hl              ; Increment character pointer
                jr      puts_loop       ; Transmit next character
puts_end        ;pop     hl
                pop     af
                ret
;
; Send a CR/LF pair:
;
crlf            push    af
                ld      a, cr
                call    putc
                ld      a, lf
                call    putc
                pop     af
                ret

;------------------------------------------------------------------------------
;---
;--- I/O subroutines
;---
;------------------------------------------------------------------------------

;
; Send a single character to the serial line (A contains the character):
;
putc   
    JP  SEND_CHAR        
                ; LD      (SAVE_CHAR),A   ; instead of PUSH AF
                ; CALL    CHECK_TX        ; try to send char from buffer
                ; CALL    write_buffer    ; put new char in buffer
                ; RET
;
; Wait for a single incoming character on the serial line
; and read it, result is in A:
;
; getc    
;                 CALL    CHECK_TX        ; try to send char from buffer
;                 CALL    READ_CHAR       ; is new char?
;                 JR      Z,GETC          ; repeat if not
;                 RET                     ; in A new char
                
;************************************************************************
;*              I8251A INIT                                             *
;*      SEE RADIOELEKTRONIK 1/1994                                      *
;************************************************************************
INIT_8251:
	XOR	A
	OUT	(CONTR_8251),A
	OUT	(CONTR_8251),A
	OUT	(CONTR_8251),A
	LD	A,40H		    ;RESET
	OUT	(CONTR_8251),A
	LD	A,4EH		    ;8 BIT, 1 STOP, X16
	OUT	(CONTR_8251),A
	IN	A,(DATA_8251)   ;FLUSH
	IN	A,(DATA_8251)
	LD	A,07H		    ;RST=1, DTR=0, Rx Tx ON
	OUT	(CONTR_8251),A
	RET

;************************************************************************
;*              I8251A READ CHAR                                        *
;************************************************************************
READ_CHAR:              
	IN	A,(CONTR_8251)
	AND	02H             ; Rx ready? 
	RET	Z               ; return if not
	IN	A,(DATA_8251)   ; read new char
	RET

;************************************************************************
;*              I8251A SEND CHAR                                        *
;************************************************************************
SEND_CHAR:
    PUSH    AF  ; 	LD	(SAVE_CHAR),A
SEND1:
	IN	A,(CONTR_8251)
	AND	01H
	JR	Z,SEND1
    POP AF      ;	LD	A,(SAVE_CHAR)
	OUT	(DATA_8251),A
	RET

; Z80 Ring Buffer with Empty/Full Check Example

; Constants
; BUFFER_START .equ 0D0H   ; Start address of the buffer in memory

; ; Buffer initialization
; init_buffer:
;     XOR     A            ; Initialize the write and read pointers
;     LD      IX,write_ptr
;     LD      (IX+0),A      ; write_ptr
;     LD      (IX+1),A      ; read_ptr
;     ret

; CHECK_TX:
;     IN	    A,(CONTR_8251)
;     AND	    01H
;     RET	    Z               ; return if Tx not ready
;     CALL    read_buffer
;     OR      A
;     RET     Z               ; return if buffer is empty
;     OUT	    (DATA_8251),A   ; send char
; 	RET

; FLUSH_TX:
;     CALL    is_buffer_empty
;     RET     Z               ; return if buffer is empty
;     CALL    CHECK_TX        ; try to send char from buffer
;     JR      FLUSH_TX        ; repeat

; ; Check if the buffer is empty
; is_buffer_empty:
;     LD      A,(IX+0)      ; write_ptr
;     CP      (IX+1)        ; read_ptr
;     ret                   ; Zero flag is set if buffer is empty

; ; Check if the buffer is full
; is_buffer_full:
;     LD      A,(IX+0)      ; Get the current write pointer
;     inc     a             ; Move to the next position
;     CP      (IX+1)        ; read_ptr
;     ret                   ; Zero flag is set if buffer is full

; ; Write data to the buffer with full check
; write_buffer:
;     call    is_buffer_full ; Check if the buffer is full
;     RET     Z           ; buffer_full   ; If the Zero flag is set, the buffer is full

;     ; Write data (assuming SAVE_CHAR holds the data to write)
;     PUSH    HL
;     ld      H, BUFFER_START
;     LD      L,(IX+0)        ; Get the current write pointer
;     LD      A,(SAVE_CHAR)   ; put new char in buffer
;     ld      (hl), a         ; Write the data
;     POP     HL
;     ; Increment the write pointer
;     INC     (IX+0)          ; Move to the next position
;     ret

; buffer_full:
;     ; Handle the error case (e.g., return without writing)
;     ;ret

; ; Read data from the buffer with empty check
; read_buffer:
;     call    is_buffer_empty     ; Check if the buffer is empty
;     JR      Z, buffer_empty     ; If the Zero flag is set, the buffer is empty

;     ; Read data
;     PUSH    HL
;     ld      H, BUFFER_START
;     LD      L,(IX+1)            ; Get the current read pointer
;     ld      A,(hl)              ; Read the data
;     POP     HL
;     ; Increment the read pointer
;     INC     (IX+1)              ; Move to the next position
;     ret

; buffer_empty:
;     ; Handle the empty case (e.g., return without reading)
;     XOR     A
;     ret

   ;################################################
   ;##   po ostatnim bajcie naszego programu wpisujemy 2 x AAAA
   ;.db 0AAh, 0AAh, 0AAh, 0AAh ; po tym markerze /2x AAAA/ nazwa programu
   ;################################################
 .db 0AAh, 0AAh, 0AAh, 0AAh ; marker nazwy
 .db "Cobra-terminal"      ; nazwa programu, max 16 znaków /dla LCD 4x 20 znakow w linii/
 .db 0FFH                   ; koniec tekstu

; Variables
; write_ptr:   .db 0      ; Write pointer (offset from BUFFER_START)
; read_ptr:    .db 0      ; Read pointer (offset from BUFFER_START)
; SAVE_CHAR:
;     .DB 0FFH
; koniec zabawy. :-)

                .end        