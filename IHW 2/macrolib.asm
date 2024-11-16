.macro print_str (%str) # Print a string; uses the stack for saving because a0 will be modified
  .data
    string: .asciz %str
  .text
    li a7 4         # System call for printing a string
    la a0 string    # Load the address of the string into a0
    ecall           # Make the system call
.end_macro
  
.macro read_double(%x) # Read a double and store it in the specified register; result in fa0
  li a7 7           # System call for reading a double
  ecall             # Make the system call
  fmv.d %x fa0      # Store the input value into register %x
.end_macro

.macro read_double_a0 # Input directly into fa0 (used for working with fa0 directly)
  li a7 7           # System call for reading a double
  ecall             # Make the system call
.end_macro

.macro print_double (%x) # Print a double value from register %x
  li a7 3           # System call for printing a double
  fmv.d fa0 %x      # Move the value from register %x to fa0
  ecall             # Make the system call
.end_macro

.macro read_int(%x) # Read an integer and store it in the specified register; result in a0
  li a7 5           # System call for reading an integer
  ecall             # Make the system call
  mv %x a0          # Store the input value into register %x
.end_macro

# fa1 - result; fa2 - input value x; fa3 - specified precision; fa4 - a (see count_expr); t0 - temporary register used for checks
# fa7 - expected value (used for testing => holds the expected result)
# fs0 - 0; fs1 - 1; fs2 - -1; fs3 - 0.5
.macro test(%x, %e, %expected)
  fld fa2 %x a1 # Load the value of x
  fld fa3 %e a3 # Load the precision
  fld fa7 %expected a7 # Load the expected result (used for testing)

  fcvt.w.d t0 fa2 # Convert the value of x to an integer and store it in t0
  li t1 -1 # Load -1 into t1 for comparison
  beq t0 t1 incorrect_a # If t0 == -1, jump to incorrect_a
  fcvt.d.w fa4 t0 # Convert t0 to a double and store it in fa4
  j continue_a
  
continue_a:
  jal expr # If x != 1, compute the expression
  j continue # Continue execution

incorrect_a: # If a == -1...
  # fa2 - x; fa4 - a
  li t0 0
  fcvt.d.w fa4 t0 # Convert 0 to a double and store it in fa4
  li t1 1
  feq.d t0 fa2 fs2 # Check if x = -1
  beq t0 t1 case_x # If true -> go to case_x
  j continue_a # Return to continue_a
  
case_x:
  fmv.d fa1 fs0 # Set 0 as the result
  j continue
  
continue:
  print_str("x = ")        # Print "x = "
  print_double(fa2)        # Print the value of x
  print_str("\n")          # Print a new line
  print_str("epsilon = ")  # Print "epsilon = "
  print_double(fa6)        # Print epsilon
  print_str("\n")          # Print a new line
  print_str("expected = ") # Print "expected = "
  print_double(fa7)        # Print the expected value
  print_str("\n")          # Print a new line
  print_str("sqrt(1+x) = ")  # Print "sqrt(1+x) = "
  print_double(fa1)        # Print the result
  print_str("\n")          # Print a new line
  print_str("\n")          # Print a new line
.end_macro




  
