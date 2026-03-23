    .data
n:               .word  0
loop_counter:    .word  16                 \ счётчик для цикла
high_mask:       .word  0xFFFF0000         \ маска для старших 16 бит
low_mask:        .word  0x0000FFFF         \ маска для младщих 16 бит
bit_mask:        .word  0x80000001         \ маска для 0 и 31 бита
one_mask:        .word  0x7FFFFFFF         \ маска для проверки на 11
input_addr:      .word  0x80
output_addr:     .word  0x84
temp_addr_for_b: .word  0x88               \ адрес для временного хранения младших битов

    .text
    .org 0x150
_start:
    @p input_addr a! @       \ положили на стек значение из ячейки ввода
    dup                      \ дублируем число для разделения на 2 части
    @p high_mask
    and                      \ выделяем старшие 16 бит
    a!                       \ регистр A <- старшие 16 бит

    dup
    @p low_mask
    and                      \ выделяем младшие 16 бит

    @p temp_addr_for_b b!    \ кладём адрес временной ячейки в регистр B
    !b                       \ mem[B] <- младшие 16 бит

loop:
    @p loop_counter
    dup
    if is_palindrome         \ если счётчик = 0, то это палиндром

    lit -1 +                 \ уменьшаем счётчик на 1
    !p loop_counter

    load_two_parts +
    @p bit_mask
    and                      \ выделяем 0 и 31 биты
    dup
    if shift_check           \ если результат and с маской = 0, то крайние биты - 00

    dup
    @p one_mask +
    if shift_check           \ если результат сложения с маской = 0, то крайние биты - 11

    not_palindrome           \ если не 00 и не 11, то это не палиндром

shift_check:
    shift_parts
    loop
    ;

load_two_parts:
    @b
    a
    ;

shift_parts:
    @b 2/                    \ сдвиг младших бит вправо
    !b
    a 2*                     \ сдвиг страших бит влево
    a!
    ;

is_palindrome:
    lit 1
    write_result
    ;

not_palindrome:
    lit 0
    write_result
    ;

write_result:
    @p output_addr           \ кладём адрес ячейки вывода на стек
    a!                       \ регистр A <- 0x84
    !                        \ в mem[A] записываем результат (0 или 1)
    halt
