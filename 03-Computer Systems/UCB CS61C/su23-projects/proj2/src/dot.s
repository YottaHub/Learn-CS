.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    # ebreak
    li t0 1
    blt a2 t0 error_size
    blt a3 t0 error_stride
    slli a3 a3 2 # converte stride into mem offset
    blt a4 t0 error_stride
    slli a4 a4 2

    # Prologue

loop_start:

    li t0 0 # t0 is the loop index
    mv t1 a0 # t1 is the address of elem in arr0
    mv t2 a1 # t2 is the address of elem in arr1
    li t3 0 # t3 is the sum of dot product

loop_continue:

    bge t0 a2 loop_end
    lw t4 0(t1) # load elem
    lw t5 0(t2)
    mul t4 t4 t5
    add t3 t3 t4
    addi t0 t0 1 # update loop index
    add t1 t1 a3 # update address
    add t2 t2 a4
    j loop_continue

loop_end:

    mv a0 t3
    # Epilogue


    jr ra

error_size:
    li a0 36
    j exit

error_stride:
    li a0 37
    j exit
