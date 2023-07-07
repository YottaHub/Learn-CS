.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    li t0 1
    blt a1 t0 error_dim
    blt a2 t0 error_dim
    blt a4 t0 error_dim
    blt a5 t0 error_dim
    bne a2 a4 error_dim

    # Prologue
    addi sp sp -40
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)
    sw s7 32(sp)
    sw s8 36(sp)

    mv s0 a0 # s0 points to m0[i][0]
    mv s1 a3 # s1 points to m1[0][0]
    mv s2 a1 # s2 is n
    mv s3 a5 # s3 is k
    mv s4 a2 # s4 is m
    mv s5 a6 # s5 points to d[i][j]
    mv s6 zero # s6 is the outer loop index, say i

outer_loop_start:

    bge s6 s2 outer_loop_end # check i < a1/s2 (n)
    mv s7 zero # s7 is the inner loop index, say j
    mv s8 s1 # let s8 points to m1[0][j]

inner_loop_start:

    bge s7 s3 inner_loop_end # check j < s3/a5 (k)

    # Set up for dot
    mv a0 s0
    mv a1 s8 # arr1 is m1[0][j]
    mv a2 s4 # num of elems is a2/a4 (m)
    li a3 1  # stride 0 is 1
    mv a4 s3 # stride 1 is k

    jal dot
    sw a0 0(s5)

    addi s7 s7 1 # j++
    addi s8 s8 4 # s8 points to m1[0][j]
    addi s5 s5 4 # s5 points to d[i][j]
    j inner_loop_start

inner_loop_end:

    addi s6 s6 1 # i++
    mv t0 s4
    slli t0 t0 2 # gap is 4 * m
    add s0 s0 t0 # from m0[i] to m0[i+1]
    j outer_loop_start

outer_loop_end:


    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    lw s7 32(sp)
    lw s8 36(sp)
    addi sp sp 40

    jr ra

error_dim:
    li a0 38
    j exit
