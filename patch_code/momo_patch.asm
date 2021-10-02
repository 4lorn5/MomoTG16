	.list
	.mlist
	.incbin	"momobase.pce"
	.bank $0

;
; Wonder Momo Patches to print function
;


;
PRTCALL		EQU	$F7C8	; print function used in the game
				; when calling, the next bytes should be the pointer to the data
				; followed by the next instruction

LVL1INTPTR	EQU	$E5A7	; original call to PRTCALL for this message
LVL1INT		EQU	$E626	; original location of text
LVL1INT_NEW	EQU	$4000	; new memory location of text

LVL4INTPTR	EQU	$E792
LVL4INT		EQU	$E8A3
LVL4INT_NEW	EQU	$4200

LVL8INTPTR	EQU	$E690
LVL8INT		EQU	$E72C
LVL8INT_NEW	EQU	$4400

BLKCONPTR	EQU	$FE21
BLKCON		EQU	$FE4E
BLKCON_NEW	EQU	$4600

END1PTR		EQU	$E196
END1		EQU	$E35D
END1_NEW	EQU	$4800

END2PTR		EQU	$E1BD
END2		EQU	$E38D
END2_NEW	EQU	$4A00

END3PTR		EQU	$E1E4
END3		EQU	$E3C4
END3_NEW	EQU	$4C00

END4PTR		EQU	$E20B
END4		EQU	$E3FE
END4_NEW	EQU	$4E00

END5PTR		EQU	$E232
END5		EQU	$E439
END5_NEW	EQU	$5000

END6PTR		EQU	$E259
END6		EQU	$E48E
END6_NEW	EQU	$5200

END7PTR		EQU	$E280
END7		EQU	$E4E2
END7_NEW	EQU	$5400

END8PTR		EQU	$E2A7
END8		EQU	$E538
END8_NEW	EQU	$5600


;
; INT1 vector
;
	.ORG	$FFF8	; interrupt vector needs to point to ne interrupt handler
	.dw	INT1

;
; patch to force wait for VBlank-type IRQ1
;
; The game has a behaviour of storing a '1' in ZP locaton <$11
; then waiting until it is zero (cleared by interrupt handler)
;
; In this example (the first such call of the game at the title screen),
; we use the value #$20 to signify that <$11 should only be cleared
; at VBLANK, not RCR
	.ORG	$E965
	LDA	#$20

;
; Level 1 Intermission message
;
;
; this is a pattern of code which is repeated for each message
; the comments would be the same for each
;
	.ORG	LVL1INTPTR
	JMP	LVL1INT		; jump to replacement routine instead of call to PRTCALL

	.ORG	LVL1INT
	TMA	#2		; save this MMR value for later
	PHA
	LDA	#$20		; new text is in BANK #$20
	TAM	#2		; and will be referenced in memory between $4000 and $5FFF
	JSR	PRTCALL		; same call as in the past
	.dw	LVL1INT_NEW	; new pointer
	PLA			; restore MMR value
	TAM	#2
	JMP	LVL1INTPTR+5	; go back to original code stream

;
; interrupt handler for video interrupts
;
INT1	TST	#$20, <$11	; check if this is a 'special VBLANK' check interval
	BNE	VBLTST		; if yes, go to new code
				; otherwise, continue with original code
	BIT	$0000		; original IRQ handler is only these three lines (BIT/STZ/RTI)
INT1OUT	STZ	<$11		; when <$11 is zero, the main program knows a video interrupt occurred
	RTI
VBLTST	TST	#$20,$0000	; in this new code, we check whether the video register
				; has the VBLANK flag set (bit at $20 of the video register)
	BNE	INT1OUT		; if not VBLANK, don't clear <$11; otherwise clear it as normal
	RTI

;
; Level 4 Intermission message
;
	.ORG	LVL4INTPTR
	JMP	LVL4INT

	.ORG	LVL4INT
	TMA	#2
	PHA
	LDA	#$20
	TAM	#2
	JSR	PRTCALL
	.dw	LVL4INT_NEW
	PLA
	TAM	#2
	JMP	LVL4INTPTR+5
 
;
; Level 8 Intermission message
;
	.ORG	LVL8INTPTR
	JMP	LVL8INT

	.ORG	LVL8INT
	TMA	#2
	PHA
	LDA	#$20
	TAM	#2
	JSR	PRTCALL
	.dw	LVL8INT_NEW
	PLA
	TAM	#2
	JMP	LVL8INTPTR+5

;
; Black Congratulatory Intermission message
;
	.ORG	BLKCONPTR
	JMP	BLKCON

	.ORG	BLKCON
	TMA	#2
	PHA
	LDA	#$20
	TAM	#2
	JSR	PRTCALL
	.dw	BLKCON_NEW
	PLA
	TAM	#2
	JMP	BLKCONPTR+5

;
; End Card 1 message
;
	.ORG	END1PTR
	JMP	END1

	.ORG	END1
	TMA	#2
	PHA
	LDA	#$20
	TAM	#2
	JSR	PRTCALL
	.dw	END1_NEW
	PLA
	TAM	#2
	JMP	END1PTR+5

;
; End Card 2 message
;
	.ORG	END2PTR
	JMP	END2

	.ORG	END2
	TMA	#2
	PHA
	LDA	#$20
	TAM	#2
	JSR	PRTCALL
	.dw	END2_NEW
	PLA
	TAM	#2
	JMP	END2PTR+5

;
; End Card 3 message
;
	.ORG	END3PTR
	JMP	END3

	.ORG	END3
	TMA	#2
	PHA
	LDA	#$20
	TAM	#2
	JSR	PRTCALL
	.dw	END3_NEW
	PLA
	TAM	#2
	JMP	END3PTR+5

;
; End Card 4 message
;
	.ORG	END4PTR
	JMP	END4

	.ORG	END4
	TMA	#2
	PHA
	LDA	#$20
	TAM	#2
	JSR	PRTCALL
	.dw	END4_NEW
	PLA
	TAM	#2
	JMP	END4PTR+5

;
; End Card 5 message
;
	.ORG	END5PTR
	JMP	END5

	.ORG	END5
	TMA	#2
	PHA
	LDA	#$20
	TAM	#2
	JSR	PRTCALL
	.dw	END5_NEW
	PLA
	TAM	#2
	JMP	END5PTR+5

;
; End Card 6 message
;
	.ORG	END6PTR
	JMP	END6

	.ORG	END6
	TMA	#2
	PHA
	LDA	#$20
	TAM	#2
	JSR	PRTCALL
	.dw	END6_NEW
	PLA
	TAM	#2
	JMP	END6PTR+5

;
; End Card 7 message
;
	.ORG	END7PTR
	JMP	END7

	.ORG	END7
	TMA	#2
	PHA
	LDA	#$20
	TAM	#2
	JSR	PRTCALL
	.dw	END7_NEW
	PLA
	TAM	#2
	JMP	END7PTR+5

;
; End Card 8 message
;
	.ORG	END8PTR
	JMP	END8

	.ORG	END8
	TMA	#2
	PHA
	LDA	#$20
	TAM	#2
	JSR	PRTCALL
	.dw	END8_NEW
	PLA
	TAM	#2
	JMP	END8PTR+5


