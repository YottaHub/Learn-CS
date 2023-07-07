.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp sp -28 # not optimized to use the fewest registers
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    
    mv s0 a0 # s0 is filename
    mv s1 a1 # a1 is the addr of rows
    mv s2 a2 # a2 is the addr of cols

    # open the file and store the descriptor in s3
    li a1 0 # read-only mode
    jal fopen
    li t0 -1
    beq a0 t0 error_fopen
    mv s3 a0

    # read num of rows and store in s4
    mv a1 s1
    li a2 4
    jal fread
    li t0 4
    bne a0 t0 error_fread
    lw s4 0(s1)

    # read num of cols and store in s5
    mv a0 s3
    mv a1 s2
    li a2 4
    jal fread
    li t0 4
    bne a0 t0 error_fread
    lw s5 0(s2)

    # malloc space for the matrix
    mul s4 s4 s5
    slli s4 s4 2 # s4 = r4 * rows * cols (bytes)
    mv a0 s4
    jal malloc
    beqz a0 error_malloc
    mv s5 a0 # let s5 points to the matrix

    # read elems into s5
    mv a0 s3
    mv a1 s5
    mv a2 s4
    jal fread
    bne a0 s4 error_fread

    # close the file
    mv a0 s3
    jal fclose
    bnez a0 error_fclose
    mv a0 s5 # let a0 points to the matrix in mem

    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    addi sp sp 28

    jr ra

error_malloc:

    li a0 26
    j exit

error_fopen:

    li a0 27
    j exit

error_fclose:

    li a0 28
    j exit

error_fread:

    li a0 29
    j exit
