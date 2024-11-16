.include "macrolib.asm"
.data
  x_1: .double -0.85
  expected1: .double 0.387298334620742
  x_2: .double -1
  expected2: .double 0
  x_3: .double 3.96
  expected3: .double 2.227105745132009
  x_4: .double 0
  expected4: .double 1
  x_5: .double 67
  expected5: .double 8.246211251235321
  x_6: .double 99
  expected6: .double 10
  x_7: .double 1984
  expected7: .double 44.55333881989093
  x_8: .double 0.59
  expected8: .double 1.260952021291849
  
  eps1: .double 0.0005
  eps2: .double 0.0000005
  eps3: .double 0.0000000005
  
  plus_one: .double 1
  minus_one: .double -1
  zero0: .double 0
  half: .double 0.5
.text
main:
  fld fs0 zero0 s0 # 0
  fld fs1 plus_one s1 # 1
  fld fs2 minus_one s2 # -1
  fld fs3 half s3 # 0.5
  
  fld fs7 eps1 s7 
  fld fs6 eps2 s6
  fld fs5 eps3 s5
  
  fmv.d fa6 fs7 # For printing epsilon
  test(x_1, eps1, expected1)
  
  fmv.d fa6 fs6
  test(x_1, eps2, expected1)
  
  fmv.d fa6 fs5
  test(x_1, eps3, expected1)
  
  fmv.d fa6 fs7
  test(x_2, eps1, expected2)
  test(x_3, eps1, expected3)
  
  fmv.d fa6 fs6
  test(x_3, eps2, expected3)
  
  fmv.d fa6 fs5
  test(x_3, eps3, expected3)
  
  fmv.d fa6 fs7
  test(x_4, eps1, expected4)
  test(x_5, eps1, expected5)
  
  fmv.d fa6 fs6
  test(x_5, eps2, expected5)
  
  fmv.d fa6 fs5
  test(x_5, eps3, expected5)
  
  fmv.d fa6 fs7
  test(x_6, eps1, expected6)
  test(x_7, eps1, expected7)
  
  fmv.d fa6 fs7
  test(x_8, eps1, expected8)
  
  fmv.d fa6 fs6
  test(x_8, eps2, expected8)
  
  fmv.d fa6 fs5
  test(x_8, eps3, expected8)
	
  li a7 10
  ecall
