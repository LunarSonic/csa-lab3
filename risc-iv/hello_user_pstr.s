    .data
buffer:          .byte  '________________________________'
hello_message:   .byte  7, 'Hello, '
question:        .byte  19, 'What is your name?\n'

byte_mask:       .word  0x000000FF
overflow_val:    .word  0xCCCCCCCC
input_addr:      .word  0x80
output_addr:     .word  0x84

check_line_break: .word  -10
buffer_limit:     .word  29

    .text
    .org     0x88
_start:
    lui      sp, %hi(0x900)
    addi     sp, sp, %lo(0x900)
    jal      ra, main
    halt

output_string:
    lw       t5, 0(a0)
    and      t5, t5, a2
    mv       t6, a0

output_loop:
    beqz     t5, end_output
    addi     t6, t6, 1
    lw       a3, 0(t6)
    sb       a3, 0(a1)
    addi     t5, t5, -1
    j        output_loop

end_output:
    jr       ra

main:
    addi     sp, sp, -4
    sw       ra, 0(sp)

    lui      s0, %hi(input_addr)
    addi     s0, s0, %lo(input_addr)
    lw       s0, 0(s0)

    lui      s1, %hi(output_addr)
    addi     s1, s1, %lo(output_addr)
    lw       s1, 0(s1)

    lui      s2, %hi(byte_mask)
    addi     s2, s2, %lo(byte_mask)
    lw       s2, 0(s2)
    mv       a2, s2

    lui      t0, %hi(check_line_break)
    addi     t0, t0, %lo(check_line_break)
    lw       s5, 0(t0)

    lui      t0, %hi(buffer_limit)
    addi     t0, t0, %lo(buffer_limit)
    lw       s6, 0(t0)

print_question:
    lui      a0, %hi(question)
    addi     a0, a0, %lo(question)
    mv       a1, s1
    jal      ra, output_string

prepare_hello:
    lui      s3, %hi(buffer)
    addi     s3, s3, %lo(buffer)
    mv       s4, s3

    lui      t3, %hi(hello_message)
    addi     t3, t3, %lo(hello_message)
    lw       t1, 0(t3)
    and      t1, t1, s2

    addi     t3, t3, 1
    addi     s3, s3, 1

copy_hello:
    lw       t2, 0(t3)
    sb       t2, 0(s3)
    addi     t3, t3, 1
    addi     s3, s3, 1
    addi     t1, t1, -1
    bnez     t1, copy_hello

read_name:
    lw       t1, 0(s0)
    and      t1, t1, s2

    add      t2, t1, s5
    beqz     t2, end_input

    bgt      s3, s6, handle_overflow

    sb       t1, 0(s3)
    addi     s3, s3, 1
    j        read_name

end_input:
    addi     t1, zero, '!'
    sb       t1, 0(s3)
    addi     s3, s3, 1

    sub      t4, s3, s4
    addi     t4, t4, -1
    sb       t4, 0(s4)

    mv       a0, s4
    mv       a1, s1
    jal      ra, output_string
    j        exit

handle_overflow:
    lui      t1, %hi(overflow_val)
    addi     t1, t1, %lo(overflow_val)
    lw       t1, 0(t1)
    sw       t1, 0(s1)
    j        exit

exit:
    lw       ra, 0(sp)
    addi     sp, sp, 4
    jr       ra
