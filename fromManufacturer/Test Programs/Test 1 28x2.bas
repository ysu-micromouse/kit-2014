'BASIC converted from flowchart 
'TEST 1 PICAXE 28X1
'the following program has been upgraded to work on the 28x2


main:
		low 1
		let adcsetup=3
label_D:	 pwmout c.1,255,0
label_14:	 pwmout c.2,255,0
		 setfreq m8
		high 4
		high 6
		high 7
		high 0
		high 5
		pause 2000
		low 0
		low 5
label_1B:	if pinc.6=1 then label_1B
		pause 1000
label_26:	 high c.5
		readadc  0,b0
		readadc  1,b1
		readadc  2,b2
		 low c.5
		if b0> 20 then label_70
		low 7
label_7E:	if b1> 20 then label_89
		low 6
label_97:	if b2> 20 then label_A2
		low 4
label_B1:	if pinc.6=1 then label_26
		 pwmout c.1,255,500
		 pwmout c.2,255,500
label_CA:	let b3= 0
		let b4= 0
		low 4
		low 7
label_D8:	if pinc.0=1 then label_E3
		goto label_D8



label_70:	high 7
		goto label_7E

label_89:	high 6
		goto label_97

label_A2:	high 4
		goto label_B1

label_E3:	if pinc.0=1 then label_E3
		let b3=b3+ 1
		if b3= 10 then label_12F
		goto label_D8


label_12F:	high 7
label_FC:	if pinc.0=1 then label_107
		goto label_FC

label_107:	if pinc.0=1 then label_107
		let b4=b4+ 1
		if b4> 10 then label_5E
		goto label_FC

label_5E:	low 7
		if pinc.6=1 then label_CA
label_14B:	let b3= 0
		let b4= 0
label_159:	if pinc.3=1 then label_164
		goto label_159



label_164:	if pinc.3=1 then label_164
		let b3=b3+ 1
		if b3= 10 then label_181
		goto label_159


label_181:	high 4
label_188:	if pinc.3=1 then label_193
		goto label_188

label_193:	if pinc.3=1 then label_193
		let b4=b4+ 1
		if b4= 10 then label_1B0
		goto label_188


label_1B0:	low 4
		if pinc.6=1 then label_14B
		
label_1D9:	high 1	
		pause 1000
		low 1
		pause 1000
		if pinc.4=1 then label_1D9
		
	
		 pwmout c.1,255,0
		 pwmout c.2,255,0
		 stop





