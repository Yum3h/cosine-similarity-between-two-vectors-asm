.data
    welcome_msg: .asciiz "Welcome to MIPS Assembly using MARS Simulator\nAn assembly program to compute the cosine similarity between two variables\nWritten by: Student Name; Student ID\n"
    size_prompt: .asciiz "Enter the vector size (between 5 and 10): "
    size_error: .asciiz "Error: Vector size must be between 5 and 10. Please try again.\n"
    invalid_input_msg: .asciiz "Error: Invalid input. Please enter a valid number.\n"
    vector_a_prompt: .asciiz "Enter elements for vector a:\n"
    vector_b_prompt: .asciiz "Enter elements for vector b:\n"
    element_prompt: .asciiz "Element "
    colon: .asciiz ": "
    result_msg: .asciiz "The Cosine Similarity between vector a and b is: "
    newline: .asciiz "\n"
    input_buffer: .space 32    # Buffer for string input
    
.text
.globl main

main:
    # Print welcome message
    li $v0, 4
    la $a0, welcome_msg
    syscall
    
    # Ask for vector size with validation
size_input_loop:
    li $v0, 4
    la $a0, size_prompt
    syscall
    
    # Read vector size as string first for better validation
    li $v0, 8
    la $a0, input_buffer
    li $a1, 32
    syscall
    
    # Parse the string to integer
    la $t5, input_buffer
    jal parse_integer
    # Check if parsing was successful (result in $v1)
    beq $v1, 0, invalid_size_input_error
    # Integer result is now in $v0
    move $s0, $v0  # Store size in $s0 as required
    
    # Check if size is between 5 and 10 (5 <= size <= 10)
    li $t5, 5      # Use only t5 for integer temp operations
    blt $s0, $t5, size_error_msg  # If size < 5, show error
    li $t5, 10     # Reuse t5
    bgt $s0, $t5, size_error_msg  # If size > 10, show error
    j size_valid   # Size is valid, continue

invalid_size_input_error:
    li $v0, 4
    la $a0, invalid_input_msg
    syscall
    j size_input_loop  # Ask again
    
size_error_msg:
    li $v0, 4
    la $a0, size_error
    syscall
    j size_input_loop  # Ask again
    
size_valid:
    
    # Initialize base addresses for vectors a and b as specified
    # Save base addresses in a0 and a1 as required by specifications
    li $a0, 0x10010000  # Base address for vector a - save in a0
    li $a1, 0x10010040  # Base address for vector b - save in a1
    
    # Input vector a
    li $v0, 4
    la $t5, vector_a_prompt
    move $t6, $a0            # Save a0 (base address of vector a)
    move $a0, $t5
    syscall
    
    move $a0, $t6            # Restore base address for vector a
    move $a1, $s0            # Vector size
    jal input_vector
    
    # Input vector b
    li $v0, 4
    la $t5, vector_b_prompt
    move $a0, $t5
    syscall
    
    li $a0, 0x10010040       # Base address for vector b
    move $a1, $s0            # Vector size
    jal input_vector
    
    # Call CosineSimilarity procedure
    li $a0, 0x10010000       # Base address for vector a
    li $a1, 0x10010040       # Base address for vector b
    move $a2, $s0            # Vector size
    jal CosineSimilarity
    
    # Store result in memory at address 0x10010080 as specified
    li $t5, 0x10010080
    swc1 $f30, 0($t5)
    
    # Print result
    li $v0, 4
    la $a0, result_msg
    syscall
    
    li $v0, 2
    mov.s $f12, $f30
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    # Exit program
    li $v0, 10
    syscall

# Procedure to parse string and convert to integer
# Input: $t5 = address of string
# Output: result in $v0, success flag in $v1 (1 = success, 0 = failure)
parse_integer:
    # Save registers
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s1, $t5      # String address
    li $s2, 0          # Sign flag (0 = positive, 1 = negative)
    li $s3, 0          # Integer accumulator
    li $v1, 1          # Success flag (assume success initially)
    li $v0, 0          # Initialize result
    
    # Skip leading whitespace
skip_int_whitespace:
    lb $t5, 0($s1)
    beq $t5, 32, skip_int_next_char  # space
    beq $t5, 9, skip_int_next_char   # tab
    j check_int_sign
skip_int_next_char:
    addi $s1, $s1, 1
    j skip_int_whitespace
    
check_int_sign:
    # Check for negative sign
    lb $t5, 0($s1)
    li $t6, 45         # ASCII for '-'
    bne $t5, $t6, check_int_positive_sign
    li $s2, 1          # Set negative flag
    addi $s1, $s1, 1   # Skip the '-' sign
    j parse_int_digits
    
check_int_positive_sign:
    li $t6, 43         # ASCII for '+'
    bne $t5, $t6, parse_int_digits
    addi $s1, $s1, 1   # Skip the '+' sign
    
parse_int_digits:
    # Parse integer digits
    move $s3, $zero    # Clear integer accumulator
    li $t6, 0          # Flag to check if we found at least one digit
    
parse_int_digit_loop:
    lb $t5, 0($s1)
    
    # Check for end of string, newline, or space
    beq $t5, 0, check_int_valid_number
    beq $t5, 10, check_int_valid_number  # newline
    beq $t5, 13, check_int_valid_number  # carriage return
    beq $t5, 32, check_int_valid_number  # space
    
    # Check if it's a digit
    li $t6, 48         # ASCII for '0'
    blt $t5, $t6, parse_int_error
    li $t6, 57         # ASCII for '9'
    bgt $t5, $t6, parse_int_error
    
    # Convert digit and accumulate
    sub $t5, $t5, 48   # Convert ASCII to digit
    li $t6, 10
    mul $s3, $s3, $t6  # Multiply previous result by 10
    add $s3, $s3, $t5  # Add new digit
    li $t6, 1          # Set flag that we found a digit
    
    addi $s1, $s1, 1   # Move to next character
    j parse_int_digit_loop

check_int_valid_number:
    # Check if we found at least one digit
    beq $t6, 0, parse_int_error
    # Apply sign if negative
    beq $s2, 0, int_parse_success
    sub $s3, $zero, $s3  # Negate the result
    j int_parse_success
    
parse_int_error:
    li $v1, 0          # Set failure flag
    j int_parse_done
    
int_parse_success:
    move $v0, $s3      # Store result in $v0
    
int_parse_done:
    # Restore registers
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra

# Procedure to input vector elements (accepts both integers and floats)
input_vector:
    # $a0 = base address, $a1 = size
    # Save registers
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s1, $a0  # Base address
    move $s2, $a1  # Size
    li $s3, 0      # Counter
    
input_loop:
    beq $s3, $s2, input_done
    
input_element_loop:
    # Print element prompt
    li $v0, 4
    la $a0, element_prompt
    syscall
    
    li $v0, 1
    addi $a0, $s3, 1
    syscall
    
    li $v0, 4
    la $a0, colon
    syscall
    
    # Read input as string to detect type
    li $v0, 8
    la $a0, input_buffer
    li $a1, 32
    syscall
    
    # Parse the string to detect if it's integer or float
    la $t5, input_buffer
    jal parse_number
    # Check if parsing was successful (result in $v1)
    beq $v1, 0, invalid_input_error
    # Result is now in $f0 as specified
    
    # Calculate address and store
    sll $t5, $s3, 2    # Multiply counter by 4 (size of float)
    add $t5, $s1, $t5  # Add to base address
    swc1 $f0, 0($t5)   # Store at calculated address
    
    addi $s3, $s3, 1
    j input_loop

invalid_input_error:
    li $v0, 4
    la $a0, invalid_input_msg
    syscall
    j input_element_loop  # Ask for the same element again
    
input_done:
    # Restore registers
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra

# Procedure to parse string and convert to float
# Input: $t5 = address of string
# Output: result in $f0 as specified, success flag in $v1 (1 = success, 0 = failure)
parse_number:
    # Save registers
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s1, $t5      # String address
    li $s2, 0          # Sign flag (0 = positive, 1 = negative)
    li $s3, 0          # Integer accumulator
    li $v1, 1          # Success flag (assume success initially)
    
    # Initialize result to 0
    li $t5, 0
    mtc1 $t5, $f0
    cvt.s.w $f0, $f0
    
    # Skip leading whitespace
skip_whitespace:
    lb $t5, 0($s1)
    beq $t5, 32, skip_next_char  # space
    beq $t5, 9, skip_next_char   # tab
    j check_sign
skip_next_char:
    addi $s1, $s1, 1
    j skip_whitespace
    
check_sign:
    # Check for negative sign
    lb $t5, 0($s1)
    li $t6, 45         # ASCII for '-'
    bne $t5, $t6, check_positive_sign
    li $s2, 1          # Set negative flag
    addi $s1, $s1, 1   # Skip the '-' sign
    j parse_integer_part
    
check_positive_sign:
    li $t6, 43         # ASCII for '+'
    bne $t5, $t6, parse_integer_part
    addi $s1, $s1, 1   # Skip the '+' sign
    
parse_integer_part:
    # Parse integer part
    move $s3, $zero    # Clear integer accumulator
    li $t6, 0          # Flag to check if we found at least one digit
    
parse_int_loop:
    lb $t5, 0($s1)
    
    # Check for end of string, newline, or space
    beq $t5, 0, check_valid_number
    beq $t5, 10, check_valid_number  # newline
    beq $t5, 13, check_valid_number  # carriage return
    beq $t5, 32, check_valid_number  # space
    
    # Check for decimal point
    li $t6, 46         # ASCII for '.'
    beq $t5, $t6, check_decimal_valid
    
    # Check if it's a digit
    li $t6, 48         # ASCII for '0'
    blt $t5, $t6, parse_error
    li $t6, 57         # ASCII for '9'
    bgt $t5, $t6, parse_error
    
    # Convert digit and accumulate
    sub $t5, $t5, 48   # Convert ASCII to digit
    li $t6, 10
    mul $s3, $s3, $t6  # Multiply previous result by 10
    add $s3, $s3, $t5  # Add new digit
    li $t6, 1          # Set flag that we found a digit
    
    addi $s1, $s1, 1   # Move to next character
    j parse_int_loop

check_decimal_valid:
    # Check if we have at least one digit before decimal point or after
    beq $t6, 0, check_decimal_digits  # No digits before decimal, check after
    j parse_decimal_part

check_decimal_digits:
    # Check if there's at least one digit after decimal point
    addi $t5, $s1, 1   # Look at next character after decimal
    lb $t5, 0($t5)
    li $t6, 48         # ASCII for '0'
    blt $t5, $t6, parse_error
    li $t6, 57         # ASCII for '9'
    bgt $t5, $t6, parse_error
    j parse_decimal_part
    
parse_decimal_part:
    # Convert integer part to float
    mtc1 $s3, $f0
    cvt.s.w $f0, $f0
    
    addi $s1, $s1, 1   # Skip decimal point
    
    # Initialize decimal place value (0.1, 0.01, 0.001, etc.)
    li $t5, 1
    mtc1 $t5, $f10     # f10 = 1.0
    cvt.s.w $f10, $f10
    li $t5, 10
    mtc1 $t5, $f20     # f20 = 10.0
    cvt.s.w $f20, $f20
    div.s $f10, $f10, $f20  # f10 = 0.1
    
    li $t6, 0          # Flag for digits after decimal
    
parse_dec_loop:
    lb $t5, 0($s1)
    
    # Check for end of string, newline, or space
    beq $t5, 0, check_decimal_found
    beq $t5, 10, check_decimal_found  # newline
    beq $t5, 13, check_decimal_found  # carriage return
    beq $t5, 32, check_decimal_found  # space
    
    # Check if it's a digit
    li $t6, 48         # ASCII for '0'
    blt $t5, $t6, parse_error
    li $t6, 57         # ASCII for '9'
    bgt $t5, $t6, parse_error
    
    # Convert digit and add to result
    sub $t5, $t5, 48   # Convert ASCII to digit
    mtc1 $t5, $f20
    cvt.s.w $f20, $f20 # Convert to float
    mul.s $f20, $f20, $f10  # Multiply by current decimal place
    add.s $f0, $f0, $f20    # Add to result
    
    # Update decimal place (divide by 10)
    li $t5, 10
    mtc1 $t5, $f20
    cvt.s.w $f20, $f20
    div.s $f10, $f10, $f20  # f10 = f10 / 10
    
    li $t6, 1          # Set flag that we found decimal digits
    addi $s1, $s1, 1   # Move to next character
    j parse_dec_loop

check_decimal_found:
    # If we had a decimal point, we must have found at least one digit after it
    beq $t6, 0, parse_error
    j apply_sign
    
check_valid_number:
    # Check if we found at least one digit
    beq $t6, 0, parse_error
    # Convert integer to float (no decimal part found)
    mtc1 $s3, $f0
    cvt.s.w $f0, $f0
    j apply_sign
    
parse_error:
    li $v1, 0          # Set failure flag
    j parse_done
    
apply_sign:
    # Apply sign if negative
    beq $s2, 0, parse_done
    neg.s $f0, $f0
    
parse_done:
    # Restore registers
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra

# Procedure to compute dot product between two vectors
# $a0 = base address of vector a, $a1 = base address of vector b, $a2 = size
# Returns result in $f30 as specified
DotProduct:
    # Save registers
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    swc1 $f10, 0($sp)  # Save f10 and f20 since we use them
    
    move $s1, $a0  # Base address of vector a
    move $s2, $a1  # Base address of vector b
    move $s3, $a2  # Size
    
    # Initialize sum to 0
    li $t5, 0       # Use only t5 for integer temp operations
    mtc1 $t5, $f30
    cvt.s.w $f30, $f30  # Convert to single precision
    li $t6, 0       # Counter - use only t6 for integer temp operations
    
dot_loop:
    beq $t6, $s3, dot_done
    
    # Calculate addresses for vector a
    sll $t5, $t6, 2    # Multiply by 4 (shift left 2) - use only t5
    add $t5, $s1, $t5
    lwc1 $f10, 0($t5)  # Load a[i] into $f10 as specified
    
    # Calculate addresses for vector b
    sll $t5, $t6, 2    # Multiply by 4 (shift left 2) - reuse t5
    add $t5, $s2, $t5
    lwc1 $f20, 0($t5)  # Load b[i] into $f20 as specified
    
    # Multiply and add to sum - use only f10 and f20 for temp operations
    mul.s $f10, $f10, $f20
    add.s $f30, $f30, $f10
    
    addi $t6, $t6, 1
    j dot_loop
    
dot_done:
    # Restore registers
    lwc1 $f10, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# Procedure to compute Euclidean norm of a vector
# $a0 = base address of vector, $a1 = size
# Returns result in $f30 as specified
EuclideanNorm:
    # Save registers
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    swc1 $f10, 0($sp)  # Save f10 since we use it
    
    move $s1, $a0  # Base address
    move $s2, $a1  # Size
    
    # Initialize sum to 0
    li $t5, 0       # Use only t5 for integer temp operations
    mtc1 $t5, $f30
    cvt.s.w $f30, $f30  # Convert to single precision
    li $t6, 0       # Counter - use only t6 for integer temp operations
    
norm_loop:
    beq $t6, $s2, norm_sqrt
    
    # Calculate address and load element
    sll $t5, $t6, 2    # Multiply by 4 (shift left 2) - use only t5
    add $t5, $s1, $t5
    lwc1 $f10, 0($t5)  # Load vector[i] into $f10 as specified
    
    # Square the element and add to sum - use only f10 for temp operations
    mul.s $f10, $f10, $f10
    add.s $f30, $f30, $f10
    
    addi $t6, $t6, 1
    j norm_loop
    
norm_sqrt:
    # Take square root
    sqrt.s $f30, $f30
    
    # Restore registers
    lwc1 $f10, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# Procedure to compute cosine similarity
# $a0 = base address of vector a, $a1 = base address of vector b, $a2 = size
# Returns result in $f30 as specified
CosineSimilarity:
    # Save registers
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    swc1 $f10, 0($sp)    # Save f10 to preserve dot product
    
    move $s1, $a0  # Base address of vector a
    move $s2, $a1  # Base address of vector b
    move $s3, $a2  # Size
    
    # Compute dot product
    move $a0, $s1
    move $a1, $s2
    move $a2, $s3
    jal DotProduct
    mov.s $f10, $f30  # Store dot product in f10 (temp register)
    
    # Compute norm of vector a
    move $a0, $s1
    move $a1, $s3
    jal EuclideanNorm
    mov.s $f20, $f30  # Store norm of a in f20 (temp register)
    
    # Compute norm of vector b
    move $a0, $s2
    move $a1, $s3
    jal EuclideanNorm
    # f30 now contains norm of b
    
    # Compute cosine similarity: dot_product / (norm_a * norm_b)
    # f10 = dot_product, f20 = norm_a, f30 = norm_b
    mul.s $f20, $f20, $f30   # f20 = norm_a * norm_b
    div.s $f30, $f10, $f20   # f30 = dot_product / (norm_a * norm_b)
    
    # Restore registers
    lwc1 $f10, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra