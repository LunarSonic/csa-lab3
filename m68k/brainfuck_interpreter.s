    .data
bf_code_addr:    .word  0x500
bf_mem_addr:     .word  0x600
stack_top:       .word  0x700

input_addr:      .word  0x80
output_addr:     .word  0x84

code_limit:      .word  64
mem_cell_count:  .word  30
mem_byte_limit:  .word  120

    .text
    .org     0x90
_start:
    movea.l  stack_top, A7
    movea.l  (A7), A7

    movea.l  input_addr, A0
    movea.l  (A0), A0
    movea.l  output_addr, A1
    movea.l  (A1), A1

    movea.l  bf_code_addr, A3
    movea.l  (A3), A3
    movea.l  bf_mem_addr, A5
    movea.l  (A5), A5

read_code:
    movea.l  code_limit, A2
    move.l   (A2), D0
    cmp.l    D0, D7
    bge      handle_overflow
    move.b   (A0), D0
    beq      init_bf_mem
    cmp.b    10, D0
    beq      init_bf_mem
    move.b   D0, 0(A3, D7)
    add.l    1, D7
    jmp      read_code

init_bf_mem:
    movea.l  bf_mem_addr, A2
    movea.l  (A2), A2
    movea.l  mem_cell_count, A4
    move.l   (A4), D0

init_loop:
    move.l   0, (A2)+
    sub.l    1, D0
    bne      init_loop

interpret:
    cmp.l    D7, D2
    bge      check_exit
    move.b   0(A3, D2), D0

    cmp.b    '+' , D0
    beq      inc_cell
    cmp.b    '-' , D0
    beq      dec_cell
    cmp.b    '>' , D0
    beq      inc_ptr
    cmp.b    '<' , D0
    beq      dec_ptr
    cmp.b    '[' , D0
    beq      loop_start
    cmp.b    ']' , D0
    beq      loop_end
    cmp.b    '.' , D0
    beq      output
    cmp.b    ',' , D0
    beq      input

inc_ptr:
    move.l   4, D0
    jsr      move_pointer
    jmp      step

dec_ptr:
    move.l   -4, D0
    jsr      move_pointer
    jmp      step

inc_cell:
    move.l   1, D0
    jsr      update_cell
    jmp      step

dec_cell:
    move.l   -1, D0
    jsr      update_cell
    jmp      step

step:
    add.l    1, D2
    jmp      interpret

move_pointer:
    add.l    D0, D1
    blt      error
    movea.l  mem_byte_limit, A2
    move.l   (A2), D3
    cmp.l    D3, D1
    bge      error
    rts

update_cell:
    move.l   0(A5, D1), D3
    add.l    D0, D3
    move.l   D3, 0(A5, D1)
    rts

output:
    move.l   0(A5, D1), D0
    move.b   D0, (A1)
    jmp      step

input:
    move.l   0(A5, D1), D3
    move.b   (A0), D3
    move.l   D3, 0(A5, D1)
    jmp      step

loop_start:
    move.b   0(A5, D1), D3
    beq      skip_loop

    move.l   D2, -(A7)
    add.l    1, D4
    jmp      step

skip_loop:
    move.l   1, D3

find_fwd:
    add.l    1, D2
    cmp.l    D7, D2
    bge      error
    move.b   0(A3, D2), D0
    cmp.b    '[' , D0
    beq      fwd_inc
    cmp.b    ']' , D0
    beq      fwd_back
    jmp      find_fwd

fwd_inc:
    add.l    1, D3
    jmp      find_fwd

fwd_back:
    sub.l    1, D3
    bne      find_fwd
    jmp      step

loop_end:
    cmp.l    0, D4
    beq      error

    move.b   0(A5, D1), D3
    beq      pop_stack

    move.l   (A7), D2
    add.l    1, D2
    jmp      interpret

pop_stack:
    move.l   (A7)+, D3
    sub.l    1, D4
    jmp      step

handle_overflow:
    move.l   0xCCCCCCCC, (A1)
    jmp      exit

check_exit:
    cmp.l    0, D4
    bne      error
    jmp      exit

error:
    move.l   0xFFFFFFFF, (A1)

exit:
    halt