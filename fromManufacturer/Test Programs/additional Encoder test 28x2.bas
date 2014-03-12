

main:
		low 1
		 pwmout c.1,255,0
		 pwmout c.2,255,0


	
		
label_2b:	if pinc.3=1 then label_4b
		low 4
label_3b:	if pinc.0=1 then label_5b
		low 7	
		goto label_2b
			
label_4b:	high 4
		goto label_3b
		
label_5b:	high 7
		goto label_2b


