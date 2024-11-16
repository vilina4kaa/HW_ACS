.include "macrolib.asm"

.data
	epsilon_percent: .double 0.0005   # Small value (tolerance)
	plus_one: .double 1               # One
	minus_one: .double -1             # Minus one
	zero0: .double 0                  # Zero
	half: .double 0.5                 # Half

.text
main:
  # fa1 - input value; fa2 - value of x; fa3 - temporary variable for result; fa4 - a (according to count_expr); t0 - flag, used for value checks
  # fs0 - 0; fs1 - 1; fs2 - -1; fs3 - 0.5
  fld fs0 zero0 s0       # Load the value 0 into fs0
  fld fs1 plus_one s1    # Load the value 1 into fs1
  fld fs2 minus_one s2   # Load the value -1 into fs2
  fld fs3 half s3        # Load the value 0.5 into fs3
  jal x_input            # Call the function to input x, result in fa1
  fmv.d fa2 fa1          # Save the value of x into fa2
  fcvt.w.d t0 fa2        # Convert the value of x to an integer and store in t0
  li t1 -1               # Load -1 into t1 for comparison
  beq t0 t1 incorrect_a  # If t0 == -1, jump to incorrect_a
  fcvt.d.w fa4 t0        # Convert t0 to a double and store it in fa4
continue_a:
  fld fa3 epsilon_percent a3 # Load the tolerance value into fa3
  jal expr                   # Compute the expression
  j continue                 # Continue execution

continue:
  print_str("sqrt(1+x) = ")  # Print the string "sqrt(1+x) = "
  print_double(fa1)          # Print the value of the result (fa1)
  li a7 10                   # Prepare the exit code
  ecall                      # Perform the system call

incorrect_a: # If a == -1, perform special handling
  # fa2 - x; fa4 - a
  li t0 0
  fcvt.d.w fa4 t0            # Convert 0 to a double and store it in fa4 (for initialization of a)
  li t1 1 
  feq.d t0 fa2 fs2           # Check if x = -1
  beq t0 t1 case_x           # If true -> go to case_x
  j continue_a               # Return to continue_a
  
case_x:
  fmv.d fa1 fs0              # Set result (fa1) to 0
  j continue
