.include "macrolib.asm"
.global expr
.data

.text
expr:
  # Formula: sqrt(1+x) = sum(((0.5*(0.5-1)(0.5-2)...(0.5-(n+1)))*((1/sqrt(a+1)^(2n-1))*(x-a)^n) / n!)) , where n = [0, +inf)
  # fs0 - 0; fs1 - 1; fs2 - -1; fs3 - 0.5 by default
  # fa1 - value of the computed sum (accumulator); fa2 - x; fa3 - calculation precision; fa4 - a (shift of x)
  # ft1 - n; ft2 - (0.5 - n + 1); ft3 - 0.5*(0.5-1)(0.5-2)...(0.5-(n-1))); ft4 - n!; ft5 - 1/sqrt(a+1); ft6 - (1/sqrt(a+1)^(2n-1)); 
  # ft7 - (x - a); ft8 - (x - a)^n; ft9 - current value ((0.5*(0.5-1)(0.5-2)...(0.5-(n+1)))*((1/sqrt(a+1)^(2n-1))*(x-a)^n) / n!)
  # ft0 - intermediate error at the current step (difference between the current and previous values)

  addi sp sp -4 # Save ra to the stack
  sw ra(sp)
  
  fmv.d ft1 fs0  # ft1 = 0
  fmv.d ft2 fs1  # ft2 = 1
  fmv.d ft3 fs1  # ft3 = 1
  fmv.d ft4 fs1  # ft4 = 1
  
  fadd.d ft5 fa4 fs1 # ft5 = 1 + a
  fsqrt.d ft5 ft5    # ft5 = sqrt(a + 1)
  fmv.d ft6 ft5      # ft6 = sqrt(a + 1)
  fdiv.d ft5 fs1 ft5 # ft5 = (1/sqrt(a + 1))
  
  fsub.d ft7 fa2 fa4 # ft7 = x - a
  fmv.d ft8 fs1      # ft8 = 1
  
  fmul.d ft9 ft3 ft6 # ft9 = 1 * sqrt(a + 1)
  fmul.d ft9 ft9 ft8 # ft9 = sqrt(a + 1) * 1
  fdiv.d ft9 ft9 ft4 # ft9 = sqrt(a + 1) / 1
  
  fmv.d fa1 ft9      # fa1 = sqrt(a + 1)
  
loop:
  fmul.d ft0 fa1 fa3 # Calculate error - difference = 0.0005 * fa1
  fmv.d fa0 ft0 
  jal abs             # Compute absolute value of the error
  fmv.d ft0 fa0       # Update absolute value of the error
  fadd.d ft1 ft1 fs1  # n += 1
  fsub.d ft2 ft1 fs1  # ft2 = n - 1
  fsub.d ft2 fs3 ft2  # 0.5 - (n - 1)
  fmul.d ft3 ft3 ft2  # *= (0.5 - (n - 1)) -> 0.5*(0.5-1)(0.5-2)...(0.5-(n-1)))
  fmul.d ft4 ft4 ft1  # *= n -> n!
  fmul.d ft6 ft6 ft5  # *= (1/sqrt(a + 1))
  fmul.d ft6 ft6 ft5  # *= (1/sqrt(a + 1)) -> (1/sqrt(a + 1))^(2n - 1)
  fmul.d ft8 ft8 ft7  # *= (x-a) -> (x - a)^n
  fmul.d ft9 ft3 ft6  # 0.5*(0.5-1)(0.5-2)...(0.5-(n-1))) * (1/sqrt(a + 1))^(2n - 1)
  fmul.d ft9 ft9 ft8  # 0.5*(0.5-1)(0.5-2)...(0.5-(n-1))) * (1/sqrt(a + 1))^(2n - 1) * (x-a)^n
  fdiv.d ft9 ft9 ft4  # 0.5*(0.5-1)(0.5-2)...(0.5-(n-1))) * (1/sqrt(a + 1))^(2n - 1) * (x-a)^n / n!
  
  fmv.d fa0 ft9 
  jal abs             # Store the absolute value of the current term in fa0 to compare with the precision
  fle.d t0 fa0 ft0    # If the current term <= error, stop the computation
  bgtz t0 final
  
  # If the computation is not finished
  fadd.d fa1 fa1 ft9  # Update the sum: new sum = current sum + current term
  j loop              # Return to the loop
  
  # Save the computed sum in fa1
final:
  lw ra (sp)          # Restore ra
  addi sp sp 4        # Free stack space
  ret

  
  
  
  
  
