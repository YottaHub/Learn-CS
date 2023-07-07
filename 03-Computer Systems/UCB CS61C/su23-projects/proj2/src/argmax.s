.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:

    # Prologue
    li t0 1
    bge a1 t0 loop_start # if a1 < 1
    li a0 36
    j exit

loop_start:
    mv t0 a0 # t0 stores the address of curr elem
    lw t1 0(t0) # t1 is the max value
    li t2 0 # t2 is index of max arg
    addi t0 t0 4
    li t3 1 # t3 is loop index

loop_continue:

    bge t3 a1 loop_end # if t3 < a1
    lw t4 0(t0) # t4 is the curr elem
    bge t1 t4 update_index
    mv t1 t4
    mv t2 t3

update_index:
    addi t0 t0 4
    addi t3 t3 1
    j loop_continue

loop_end:
    # Epilogue
    mv a0 t2
    jr ra
