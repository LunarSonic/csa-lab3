    .data
n:               .word  0
loop_counter:    .word  1
count_div:       .word  0
const_0:         .word  0
const_1:         .word  1
const_neg_1:     .word  -1
input_addr:      .word  0x80
output_addr:     .word  0x84

    .text
_start:
    load         input_addr
    load_acc
    store        n                           ; mem[n] = acc

check_n:
    load         n                           ; acc = mem[n]
    sub          const_1                     ; acc = acc - mem[const_1]
    ble          error                       ; если n меньше 1 (acc = n - 1 < 0), то переходим к блоку с ошибкой

loop:
    load         loop_counter                ; acc = mem[loop_counter]
    sub          n                           ; acc = acc - mem[n]
    bgt          output                      ; если счётчик больше n, то выводим результат

    load         n                           ; acc = mem[n]
    rem          loop_counter                ; acc = acc % mem[loop_counter]
    bnez         continue                    ; если остаток не равен 0, то продолжаем поиск делителей

    load         count_div                   ; acc = mem[count_div]
    add          const_1                     ; увеличиваем кол-во делителей на 1
    store        count_div                   ; mem[count_div] = acc

continue:
    load         loop_counter                ; acc = mem[loop_counter]
    add          const_1                     ; увеличиваем счётчик на 1
    store        loop_counter                ; mem[loop_counter] = acc
    jmp          loop                        ; возвращаемся к блоку loop

error:
    load         const_neg_1                 ; acc = mem[const_neg_1]
    store        count_div                   ; mem[count_div] = acc

output:
    load         count_div                   ; acc = mem[count_div]
    store_ind    output_addr                 ; mem[mem[output_addr]] = acc
    halt
