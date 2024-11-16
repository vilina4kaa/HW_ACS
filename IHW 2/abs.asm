.include "macrolib.asm"
.global abs
.data

.text
abs:
  # fs0 - 0; fs2 - -1; fa0 - input to the func
  addi sp sp -4 # Save ra to the stack
  sw ra(sp)
  
  flt.d t0 fs0 fa0 # Check if the input value is less than 0
  bgtz t0 done     # Jump to "done" if greater than 0
  
  fmul.d fa0 fa0 fs2 # Multiply the value by -1 (if negative)
  
done:
  lw ra(sp) # Restore ra
  addi sp sp 4 # Restore the stack pointer
  ret # Return from the function

