.include "macrolib.asm"
.global x_input
.text
x_input:
  # Input value of x and check for validity
  # ft0 - temporary register; fa1 - input value of x
  # t1 - condition check x == -1; t0 - temporary register
  
  addi sp sp -4       # Save ra to the stack
  sw ra(sp)

  # Prompt the user to input x
  print_str("Input x (x>=-1): ") # Message "Input x (x>=-1):"
  read_double(fa1)               # Read the value of x

  flt.d t1 fa1 fs2               # Check if x is less than -1
  bgtz t1 mistake                # If x < -1, jump to the mistake label

  lw ra (sp)       # Restore ra
  addi sp sp 4     # Free the stack
  ret              # Return from the function

mistake:
  print_str("Incorrect x, try again! \n") # Message "Incorrect x, try again!"
  j x_input            # Go back to the beginning of the input process

  
