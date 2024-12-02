# RARS assembly program with automated testing
# This program can run in two modes:
# 1. Interactive Mode: Reads file name to read and write from the user,
#    count ind and then outputs this value.
# 2. Test Mode: Automatically tests to ensure it works with different data sets.
.globl main
.eqv TEXT_SIZE 512
.eqv NAME_SIZE 256
.data
    # Messages and prompts
    promptInput: .asciz "Input filename for input: "
    promptOutput: .asciz "\nInput filename for output: "
    promptSubstring: .asciz "Input substring: "
    promtConsoleOutput: .asciz "\nDo you want to output data to the console? (Y - yes, N - no, other input - no): "
    promptMode: .asciz "Select mode (1 for Interactive, 2 for Test): "
    invalidMode: .asciz "Invalid mode selected. Default switching to Interactive Mode.\n"
    answerYes: .ascii "Y\n"
    errorEmptyString: .asciz "Invalid substring. It cannot be empty!"
    errorReading: .asciz "An error occurred when opening or reading a file. Check data and try again! "
    errorWriting: .asciz "An error occurred when opening or writing a file. Check data and try again! "
    successReading: .asciz "File read successfully!"
    successWriting: .asciz "\nFile was written successfully!"
    promtAnswer: .asciz "\nAnswer: "
    intToString: .space 12 	# 32 bit number has a maximum of 10 characters + \0
    bufferText: .space TEXT_SIZE
    bufferSubstring: .space TEXT_SIZE
    bufferFilePath: .space NAME_SIZE
    bufferLetter: .space 2
    promtTestValue: .asciz "Test read file: "
    separator: .asciz "\n----------------------------------------------------\n"
    new_line: .asciz "\n"
    
     # Tests value
     short1_test_input:  .asciz "/Users/vilinaolhovskaya/GitHub/HW_ACS/IHW3/short1_input.txt"
     short1_test_substring: .asciz  "abcd"
     short1_test_substring_size: .word 4
     short1_test_output: .asciz "/Users/vilinaolhovskaya/GitHub/HW_ACS/IHW3/short1_output.txt"
     
     long1_test_input: .asciz "/Users/vilinaolhovskaya/GitHub/HW_ACS/IHW3/long1_input.txt"
     long1_test_substring: .asciz "abcd"
     long1_test_substring_size:  .word 4
     long1_test_output: .asciz "/Users/vilinaolhovskaya/GitHub/HW_ACS/IHW3/long1_output.txt"
     
     short2_test_input: .asciz "/Users/vilinaolhovskaya/GitHub/HW_ACS/IHW3/short2_input.txt"
     short2_test_substring: .asciz "abcd"
     short2_test_substring_size: .word 4
     short2_test_output: .asciz "/Users/vilinaolhovskaya/GitHub/HW_ACS/IHW3/short2_output.txt"
     
     long2_test_input: .asciz "/Users/vilinaolhovskaya/GitHub/HW_ACS/IHW3/long2_input.txt"
     long2_test_substring: .asciz "bbb"
     long2_test_substring_size: .word 3
     long2_test_output: .asciz "/Users/vilinaolhovskaya/GitHub/HW_ACS/IHW3/long2_output.txt" 
     
     empty_test_input: .asciz "/Users/vilinaolhovskaya/GitHub/HW_ACS/IHW3/empty_input.txt"
     empty_test_substring: .asciz "abcd"
     empty_test_substring_size: .word 4
     empty_test_output: .asciz "/Users/vilinaolhovskaya/GitHub/HW_ACS/IHW3/empty_output.txt"

.text
main: 
    # Prompt user to select mode
    li a7, 4                   # syscall for print string
    la a0, promptMode
    ecall

    # Read mode selection
    li a7, 5                   # syscall for read integer
    ecall
    mv t0, a0                  # t0 = user's choice

    # Check mode selection
    li t1, 1
    beq t0, t1, interactive_mode
    li t1, 2
    beq t0, t1, test_mode

    # Invalid mode selected, default to interactive mode
    li a7, 4
    la a0, invalidMode
    ecall
    j interactive_mode


# Interactive Mode
interactive_mode: 	
    # Prologue
    addi sp, sp, -4
    sw ra, (sp)
    
    addi sp, sp, -4
    sw s0, (sp)

    la a0, bufferFilePath
    la a1, bufferSubstring
    jal input 
    # Parameters:
    # a0 - file name buffer
    # a1 - substring buffer
    # a2 - exit code = substring is empty
    # a3 - substring size
    bltz a2, error_empty_substring
    mv s0, a3
   
    la a0, bufferFilePath		
    jal read_file_data
    # Parameters:
    # a0 - file name buffer
    # a1 - text address
    # a2 - text size
    # a3 - exit code
    bltz a3, error_read
   	
    # Print success message
    li a7, 4                   # syscall for print string
    la a0, successReading
    ecall
   	
    mv a0, a1
    mv a1, a2
    la a2, bufferSubstring
    mv a3, s0
    jal find_substring	
    # Parameters:
    # a0 - text
    # a1 - text size
    # a2 - substring
    # a3 - substring size
    # a4 - answer

    mv a0, a4
    mv s0, a4
    jal console_output
    # Parametrs:
    # a0 - int

    mv a0, s0
    jal int_to_string
    # Parametrs:
    # a0 - int
    # a1 - string size
    mv s0, a1

    
    la a0, bufferFilePath
    jal output 
    # Parameters:
    # a0 - file name buffer
    
    mv a2, a0
    la a0, intToString
    mv a1, s0
    jal write_file_data
    # Parametrs
    # a0 - buffer
    # a1 - string size
    # a2 - file path
    # a3 - exit code
    bltz a3, error_write
    
    # Print success message
    li a7, 4                   # syscall for print string
    la a0, successWriting
    ecall   
    j exit	
    
error_empty_substring:
    # Print error
    li a7, 4                   # syscall for print string
    la a0, errorEmptyString
    ecall
    j exit

error_read:
    # Print error
    li a7, 4                   # syscall for print string
    la a0, errorReading
    ecall
    j exit
    
error_write:
    # Print error
    li a7, 4                   # syscall for print string
    la a0, errorWriting
    ecall
    j exit
    
exit:
    # Epilogue
    lw s0, (sp)
    addi sp, sp, 4
    
    lw ra, (sp)
    addi sp, sp, 4
    
    li a7, 10		      	 # syscall for exit program with code 0
    ecall

# Test Mode. Automated Testing with predefined test cases
test_mode:
    # Prologue
    addi sp, sp, -4
    sw ra, (sp)
    
    # Test Case 1
    # Print separator 
    li a7, 4                   	# syscall for print string
    la a0, separator
    ecall
    
    # Load test data 
    la a0, short1_test_input
    la a1, short1_test_substring
    la a2, short1_test_output
    lb a3, short1_test_substring_size
    jal run_test

    # Test Case 2
    # Print separator 
    li a7, 4                   	# syscall for print string
    la a0, separator
    ecall
    
    # Load test data 
    la a0, short2_test_input
    la a1, short2_test_substring
    la a2, short2_test_output
    lb a3, short2_test_substring_size
    jal run_test

    # Test Case 3
    # Print separator 
    li a7, 4                   	# syscall for print string
    la a0, separator
    ecall
    
    # Load test data 
    la a0, long1_test_input
    la a1, long1_test_substring
    la a2, long1_test_output
    lb a3, long1_test_substring_size
    jal run_test
    
    
    # Test Case 4
    # Print separator 
    li a7, 4                   	# syscall for print string
    la a0, separator
    ecall
    
    # Load test data 
    la a0, long2_test_input
    la a1, long2_test_substring
    la a2, long2_test_output
    lb a3, long2_test_substring_size
    jal run_test


    # Test Case 5
    # Print separator 
    li a7, 4                   	# syscall for print string
    la a0, separator
    ecall
    
    # Load test data 
    la a0, empty_test_input
    la a1, empty_test_substring
    la a2, empty_test_output
    lb a3, empty_test_substring_size
    jal run_test

    # Epilogue
    lw ra, (sp)
    addi sp, sp, 4

    li a7, 10		      	 # syscall for exit program with code 0
    ecall


# Run test
# Input:
# a0: input path
# a1: substring 
# a2: output path
# a3: substring size
run_test:
    # Prologue
    addi sp, sp, -4
    sw ra, (sp)
    
    addi sp, sp, -4
    sw s0, (sp)
    
    addi sp, sp, -4
    sw s1, (sp)
    
    addi sp, sp, -4
    sw s2, (sp)
    
    addi sp, sp, -4
    sw s3, (sp)
    
    # Save input data
    mv s0, a0	# s0 = input path
    mv s1, a1	# s1 = substring
    mv s2, a2	# s2 = output path
    mv s3, a3	# s3 = substring size
   			        
    # Print string, test value, new_line
    li a7, 4                   	# syscall for print string
    la a0, promtTestValue
    ecall
    
    mv a0, s0
    li a7, 4			# syscall for print double
    ecall
    
    li a7, 4                   	# syscall for print string
    la a0, new_line
    ecall
    
    mv a0, s0
    jal read_file_data
    # Parameters:
    # a0 - file name buffer
    # a1 - text address
    # a2 - text size
    # a3 - exit code
    bltz a3, error_read_test
    	
    # Print success message
    li a7, 4                   # syscall for print string
    la a0, successReading
    ecall
   	
    mv a0, a1
    mv a1, a2
    mv a2, s1
    mv a3, s3
    jal find_substring	
    # Parameters:
    # a0 - text
    # a1 - text size
    # a2 - substring
    # a3 - substring size
    # a4 - answer

    # Print console
    # Print answer
    li a7, 4                   	# syscall for print string
    la a0, promtAnswer
    ecall 

    mv a0, a4
    li a7, 1	
    ecall	
 
    jal int_to_string
    # Parametrs:
    # a0 - int
    # a1 - string size
    mv t0, a1
   	
    mv a2, s2
    la a0, intToString
    mv a1, t0
    jal write_file_data
    # Parametrs
    # a0 - buffer
    # a1 - string size
    # a2 - file path
    # a3 - exit code
    bltz a3, error_write_test
    
    # Print success message
    li a7, 4                   # syscall for print string
    la a0, successWriting
    ecall   
    j exit_test	
    
error_empty_substring_test:
    # Print error
    li a7, 4                   # syscall for print string
    la a0, errorEmptyString
    ecall
    j exit_test

error_read_test:
    # Print error
    li a7, 4                   # syscall for print string
    la a0, errorReading
    ecall
    j exit_test
    
error_write_test:
    # Print error
    li a7, 4                   # syscall for print string
    la a0, errorWriting
    ecall
    j exit_test
    
exit_test:
    # Epilogue
    lw s3, (sp)
    addi sp, sp, 4
    
    lw s2, (sp)
    addi sp, sp, 4
    
    lw s1, (sp)
    addi sp, sp, 4
    
    lw s0, (sp)
    addi sp, sp, 4
    
    lw ra, (sp)
    addi sp, sp, 4
    ret  			# Return to caller     


# Read substr and path to read in buffers, remove \n
# Inputs: 
# a0: file path buffer
# a1: substring buffer
# Outputs: 
# a2: exit code = -1 if substring is empty
# a3: substring size
input:
    # Prologue
    addi sp, sp, -4
    sw ra, (sp)
    
    # Save input
    mv t0, a0			# t0 = file name buffer
    mv t1, a1			# t1 = substring buffer
    
    # Prompt user to enter path
    li a7, 4                   	# syscall for print string
    la a0, promptInput
    ecall
    
    # Read path 
    mv a0, t0
    li a1, NAME_SIZE		# syscall for read string
    li a7, 8
    ecall
    	
    # Prompt user to enter substring
    li a7, 4                   	# syscall for print string
    la a0, promptSubstring
    ecall
    
    # Read substring
    mv a0, t1 
    li a1, NAME_SIZE		# syscall for read string
    li a7, 8
    ecall
    
    # Check empty string, first byte = '\n' because console input
    lb t1, 0(a0)	# Load first byte
    li t2, '\n'
    beq t1, t2 empty_string 
    
    # Remove \n from path, t0 = file path buffer
    li t1, '\n'
    
    next_sym_input_1:
    lb t2, (t0)
    beq t1, t2, swap_input_1
    addi t0, t0, 1
    b next_sym_input_1
    
    swap_input_1:
    sb, zero(t0)

    # Count substring size
    la t0, bufferSubstring
    li t1, '\0'
    li t3, 0	#  Counter initialization, i = 0
    
    count_substring_size:
    lb t2, (t0)
    beq t1, t2, count_end
    addi t3, t3, 1
    addi t0, t0, 1
    b count_substring_size
    
    count_end:
    addi t3, t3, -1
    mv a3, t3
    li a2, 1		# Load exit code
    j input_end		
    
empty_string:
    li a2, -1		# Load exit code

input_end:
    # Epilogue
    lw ra, (sp)
    addi sp, sp, 4
    ret  			# Return to caller     


# Read path to write in buffer
# Inputs: 
# a0: file path buffer
output: 
    # Prologue
    addi sp, sp, -4
    sw ra, (sp)
    
    mv t0, a0		# Save file path buffer
    
    # Prompt user to enter path
    li a7, 4                   	# syscall for print string
    la a0, promptOutput
    ecall
    
    mv a0, t0
    li a1 NAME_SIZE		# syscall for read string
    li a7 8
    ecall
    
    # Remove \n from path, t0 = file path buffer
    li t1, '\n'
    
    next_sym_output:
    lb t2, (t0)
    beq t1, t2, swap_output
    addi t0, t0, 1
    b next_sym_output
    
    swap_output:
    sb zero(t0)
    
    # Epilogue
    lw ra, (sp)
    addi sp, sp, 4
    ret  			# Return to caller     

# Find the first occurrence of a substring
# Inputs: 
# a0: text
# a1: text size
# a2: substring 
# a3: substring size
# Outputs: 
# a4: answer
find_substring:	
    # Prologue
    addi sp, sp, -4
    sw ra, (sp)
    
    li t0, 0	# Counter initialization, i = 0
    mv t1, a2	# t0 =  substring

outer_loop:
    beq a1, t0, not_found      # if i = text size, done
    mv t2, a0                  # t2 = current text pos
    mv t3, t1                  # t3 = substring 
    li t4, 0		       # Counter initialization, j = 0 = t4
    
inner_loop:
    beq a3, t4, found         # if j = substring size, exit
    lb t5, 0(t3)              # t5 = current substring sym
    lb t6, 0(t2)              # t6 = current text sym
    bne t6, t5, outer_loop_continue # if mismatch, exit inner loop

    # Next iteration
    addi t2, t2, 1             # Next text sym
    addi t3, t3, 1             # Next substring sym
    addi t4, t4, 1	       # j += 1
    j inner_loop               

outer_loop_continue:
    # Next iteration
    addi a0, a0, 1             # Next text sym
    addi t0, t0, 1             # i += 1
    j outer_loop              

found:
    mv a4, t0                  # Store the start index of the found substring
    j find_substring_end

not_found:
    li a4, -1                  # If the substring is not found, return -1
    
find_substring_end:       
    # Epilogue
    lw ra, (sp)
    addi sp, sp, 4
    ret  			# Return to caller     


# Asks the user and, depending on the answer, displays the result in the console
# Inputs: 
# a0: int 
console_output:
    # Prologue
    addi sp, sp, -4
    sw ra, (sp)
    
    mv t1, a0	# Save int
    
    # Prompt user to ans question
    li a7, 4                   	# syscall for print string
    la a0, promtConsoleOutput
    ecall 

    # Read answer
    la a0, bufferLetter
    li a1 2			# syscall for read string
    li a7 8
    ecall
    
    # Compare ans and Y
    lb t0, answerYes
    lb t2, bufferLetter
    bne t2, t0, console_output_end
    
    # Print answer
    li a7, 4                   	# syscall for print string
    la a0, promtAnswer
    ecall 

    mv a0, t1
    li a7, 1	
    ecall	

console_output_end:
    # Epilogue
    lw ra, (sp)
    addi sp, sp, 4
    ret  			# Return to caller      


# Read data in file 
# Inputs: 
# a0: int
# Outputs:
# a1: string size
int_to_string:
    # Prologue
    addi sp, sp, -4
    sw ra, (sp)
    
    bltz a0, less_zero
    mv t0, a0
    li t1, 10              # Load 10 in t1 for division

    la t2, intToString     # t2 points to the start of the buffer
    li a1, 0               # String size

int_to_string_loop:
    # Get last digit
    rem t3, t0, t1        # t3 = t0 % 10 (last digit)
    addi t3, t3, 48       # Convert to ASCII
    div t0, t0, t1        # t0 = t0 / 10 (remove last digit)
    # Save digit in buffer from the end
    sb t3, 0(t2)          # Write digit to the buffer
    addi t2, t2, 1        # Move t2 to the next position
    addi a1, a1, 1        # Increment string size
    bnez t0, int_to_string_loop
    
reverse_string:
   la t0, intToString
   mv t1, t0 		# Load pointers to end and begin
   add t1, t1, a1
   addi t1, t1, -1
   
reverse_loop:
   ble t1, t0, reverse_loop_end
   lb t2, 0(t0)
   lb t3, 0(t1)
   sb t2, 0(t1)
   sb t3, 0(t0)
   addi t0, t0 1
   addi t1, t1, -1
   j reverse_loop
   
reverse_loop_end:
   # Add \0
   la t0, intToString
   add t0, t0, a1
   sb zero, 0(t0) 
   j int_to_string_end
   
less_zero:
    la t0, intToString
    li t1, '-'            # ASCII code for '-'
    sb t1, 0(t0)          # Write '-'
    li t1, 49             # ASCII code for '1'
    sb t1, 1(t0)          # Write '1'
    li t1, 0              # ASCII code for '\0'
    sb t1, 2(t0)          # Write '\0'
    li a1, 3              # String size = 3

int_to_string_end:
    # Epilogue
    lw ra, (sp)
    addi sp, sp, 4
    ret                   # Return to caller


# Read data in file 
# Inputs: 
# a0: file path buffer
# Outputs: 
# a1: text
# a2: text size
# a3: exit code 
read_file_data:
    # Prologue
    addi sp, sp, -4
    sw ra, (sp)
    
    # Open file, a0 = descriptor
    li a7, 1024
    li a1, 0
    ecall 	
	
    # Check descriptor
    li t0, -1		# Load -1 in t0
    beq a0, t0, read_file_error 	
    		
    li t1, 0 	# t1 = total text size
    mv t2, a0	# t2 = descriptor
   
read_loop:   
    # Allocate memory in heap
    li a7, 9	
    li a0, TEXT_SIZE	
    ecall
    mv t3, a0		# a0 = t3 = address to the allocated block
    
    # Read text 
    mv a0, t2	
    li a7, 63      
    mv a1, t3  
    li a2, TEXT_SIZE  	# a0 = the length read or -1 if error 
    ecall             
    
    # Check error
    beq a0, t0, read_file_error 
    	
    add t1, t1, a0	# Update total size
    add t3, t3, a0	# Update address
    
    # Checking how much data has been read 	
    bne a0, a2, read_loop_end	  	# If buffer not full, exit from loop
   
    j read_loop
 
read_loop_end:   
    sub t3, t3, t1
    mv a1, t3
    mv a2, t1
    li a3, 1		# Load exit code
    j read_file_end
    
read_file_error:
    li a3, -1	# Load exit code
    
read_file_end:    
    # Close file
    li a7, 57
    mv a0, t2
    ecall
    
    # Epilogue
    lw ra, (sp)
    addi sp, sp, 4
    ret  			# Return to caller     


# Inputs
# a0: buffer
# a1: string size
# a2: file path
# Outputs:
# a3: exit code
write_file_data: 
    # Prologue
    addi sp, sp, -4
    sw ra, (sp)
    
    mv t0, a0	# t0 = buffer
    mv t1, a1	# t1 = string size

    # Open file, a0 = descriptor
    mv a0, a2
    li a7, 1024
    li a1, 1
    ecall 	

    # Check descriptor
    li t2, -1		# Load -1 in t2
    beq a0, t2, write_file_error 	
    
    mv t3, a0	# save descriptor
    	
    # Write 
    mv a1, t0
    mv a2, t1
    li a7 64     
    ecall
    
    beq a0, t2, write_file_error 
    li a3, 1	# Load exit code
    j write_file_end 
    
      		
write_file_error:
    li a3, -1	# Load exit code
    
write_file_end:   
    # Close file
    mv a0, t3
    li a7, 57
    mv a0, t2
    ecall
    
    # Epilogue
    lw ra, (sp)
    addi sp, sp, 4
    ret  			# Return to caller     


