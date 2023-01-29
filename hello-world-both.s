PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E = %10000000
RW = %01000000
RS = %00100000

  .org $8000

reset:
  cli
  ldx #$ff
  txs

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction

  ldx #0
print:
  lda message,x
  beq loop
  jsr print_char
  jsr safedelay
  inx
  jmp print

loop:
  jmp loop

message: .asciiz "Hello, world!"

lcd_wait:
  pha
  lda #%00000000 ; Port B is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne lcdbusy

  lda #RW
  sta PORTA
  lda #%11111111 ; Port B is output
  sta DDRB
  pla
  rts

lcd_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0 ; Clear RS/RW/E bits
  sta PORTA
  lda #E ; Set E bit to send instruction
  sta PORTA
  lda #0 ; Clear RS/RW/E bits
  sta PORTA
  rts

print_char:
  jsr lcd_wait
  sta PORTB
  lda #RS ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E) ; Set E bit to send instruction
  sta PORTA
  lda #RS ; Clear E bits
  sta PORTA
  rts

safedelay:
  phy
  phx
  ldy #$ff
  ldx #$ff
  jsr delay
  plx
  ply
  rts

delay:
  dex
  bne delay
  dey
  bne delay
  rts

  .org $9c40
  
inter:
  ldx #$ff
  txs

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB

  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction2

  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction2

  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction2

  lda #%00000001 ; Clear Display
  jsr lcd_instruction2

  lda #"H"
  jsr print_char2
  lda #"e"
  jsr print_char2
  lda #"l"
  jsr print_char2
  lda #"l"
  jsr print_char2
  lda #"o"
  jsr print_char2
  lda #","
  jsr print_char2
  lda #" "
  jsr print_char2
  lda #"w"
  jsr print_char2
  lda #"o"
  jsr print_char2
  lda #"r"
  jsr print_char2
  lda #"l"
  jsr print_char2
  lda #"d"
  jsr print_char2
  lda #"!"
  jsr print_char2

loop2:
  jmp loop2

lcd_instruction2:
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to send instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  rts

print_char2:
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set E bit to send instruction
  sta PORTA
  lda #RS         ; Clear E bits
  sta PORTA
  rts


  .org $c350
irq:
  ldx #$ff
  txs

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction

  ldx #0
  
print2:
  lda message2,x
  beq loop3
  jsr print_char
  jsr safedelay
  inx
  jmp print2

loop3:
  jmp loop3

message2: .asciiz "An Interrupt!"

  
  .org $fffa
  .word inter
  .word reset
  .word irq
  .word $0000
