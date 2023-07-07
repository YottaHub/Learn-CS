.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # ebreak
    # Prologue
    li t0 1
    bge a1 t0 loop_start # if a1 < 1
    li a0 36
    j exit

loop_start:

    mv t0 a0 # t0 stores the address of curr elem
    li t1 0 # t1 is loop index

loop_continue:

    bge t1 a1 loop_end # while t1 < a1
    lw t2 0(t0)
    bge t2 zero geq_zero
    sw zero 0(t0)

geq_zero:
    addi t0 t0 4 # update index
    addi t1 t1 1
    j loop_continue

loop_end:


    # Epilogue


    jr ra
