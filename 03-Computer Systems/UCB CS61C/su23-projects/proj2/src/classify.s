.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:

    # Prologue
    addi sp sp -32
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)
    
    li t0 5
    bne a0 t0 error_argc
    lw s0 4(a1) # points to filepath string of m0, tricky
    lw s1 8(a1) # points to filepath string of m1
    lw s2 12(a1) # points to filepath string of input
    lw s3 16(a1) # points to filepath string of output
    mv s4 a2 # silent mode

    # Read pretrained m0
    addi sp sp -24
    mv a0 s0
    mv a1 sp
    addi a2 sp 4
    jal read_matrix
    mv s0 a0 # s0 points to the m0

    # Read pretrained m1
    mv a0 s1
    addi a1 sp 8
    addi a2 sp 12
    jal read_matrix
    mv s1 a0 # s1 points to the m1

    # Read input matrix
    mv a0 s2
    addi a1 sp 16
    addi a2 sp 20
    jal read_matrix
    mv s2 a0 # s2 points to the input matrix

    # Compute h = matmul(m0, input)
    lw t0 0(sp)
    lw t1 20(sp)
    mul s6 t0 t1 # s6 stores the number of elements of h
    slli a0 s6 2
    jal malloc
    beqz a0 error_malloc
    mv s5 a0 # s5 points to h
    mv a6 a0
    mv a0 s0
    lw a1 0(sp)
    lw a2 4(sp)
    mv a3 s2
    lw a4 16(sp)
    lw a5 20(sp)
    jal matmul

    # Compute h = relu(h)
    mv a0 s5
    mv a1 s6
    ebreak
    jal relu

    # Compute o = matmul(m1, h)
    lw t0 8(sp)
    lw t1 20(sp)
    mul t0 t0 t1
    slli a0 t0 2
    jal malloc
    beqz a0 error_malloc
    mv s6 a0 # s6 points to o
    mv a6 a0
    mv a0 s1
    lw a1 8(sp)
    lw a2 12(sp)
    mv a3 s5
    lw a4 0(sp)
    lw a5 20(sp)
    jal matmul

    # Write output matrix o
    mv a0 s3
    mv a1 s6
    lw a2 8(sp)
    lw a3 20(sp)
    jal write_matrix

    # Compute and return argmax(o)
    mv a0 s6
    lw t0 8(sp)
    lw t1 20(sp)
    mul a1 t0 t1
    ebreak
    jal argmax
    mv s3 a0 # s3 stores the result

    # If enabled, print argmax(o) and newline
    li t0 1
    beq s4 t0 clean_up
    mv a0 s3
    jal print_int
    li a0 '\n'
    jal print_char

clean_up:

    # Free
    addi sp sp 24
    mv a0 s0
    jal free # free m0
    mv a0 s1
    jal free # free m1
    mv a0 s2
    jal free # free input
    mv a0 s5
    jal free # free h
    mv a0 s6
    jal free # free o

    mv a0 s3 # a0 stores the result

    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    addi sp sp 32

    jr ra

error_malloc:

    li a0 26
    j exit

error_argc:
    li a0 31
    j exit
