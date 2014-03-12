'BASIC converted from flowchart 
'Test 3 debug 28X1
'the following program has been upgraded to work on the 28x2



main:
		low 1
		let adcsetup=3
		 setfreq m8
		 pwmout c.1,255,0
		 pwmout c.2,255,0
label_37:	debug  b1
		 high c.5
		readadc  0,b0
		readadc  1,b1
		readadc  2,b2
		 low c.5
		pause 20
		goto label_37



