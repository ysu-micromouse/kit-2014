'control program Picaxe 28X2
'© D Hall & J Chidley 2009
 'PICONE TURBO 


symbol left_motor=1018			'sets left motor speed for straight line max 1023
symbol right_motor=1023			'sets right motor speed for straight line max 1023
symbol slowleft_motor=850		'slower speed for straightening
symbol slowright_motor=850		'slower speed for straightening
symbol left_wall=8			'sets left wall detection 
symbol right_wall=8			'sets right wall detection 
symbol front_wall=6			'sets front wall detection 
symbol reset_frontwall=17`		'resets wheel counter if deadend is found 
symbol left_straighten=41		'value of left sensor if no straightening required
symbol right_straighten=41		'value of right sensor if no straightening required
symbol straight_before_right=11	'sets distance of short straight before right turn 
symbol angle_right=81			'sets amount of right turn 
symbol straight_after_right=58	'sets distance of short straight after right turn (lower number to travel further)
symbol straight_before_left=11	'sets distance of short straight before left turn 
symbol angle_left=82			'sets amount of left turn 
symbol straight_after_left=74		'sets distance of short straight after left turn (lower number to travel further)
symbol straight_turnround=50		'distance travelled into deadend before turn round 
symbol angle_turnround=78		'sets amount of turn round 
symbol end_wall=80			'front wall trigger in dead end

symbol button_A = pinC.4		'Button A
symbol start_button = pinC.6
symbol middle_green_led = 6
symbol left_red_led = 7
symbol right_red_led = 4
symbol yellow_led = 0			;
symbol green_led = 5
symbol sensor = b7                  'sensor reading from pic28
symbol sensor_leds = c.5		'IR leds
symbol motor_right = c.1
symbol motor_left = c.2
symbol relay = 1
symbol left_sensor = b40
symbol front_sensor = b41
symbol right_sensor = b42
symbol wall_config = b43
symbol last_wheel = bit16


'PicOne maze solver symbols

symbol map_walls = b0           'this is overlaid by the folwing 8 sysbols
symbol w_north = bit5           '1 if wall to north
symbol w_south = bit7           '1 if wall to south
symbol w_west = bit4            '1 it wall to west
symbol w_east = bit6            '1 if wall to east
symbol w_visited = bit2         '1 if mouse has visited this square
symbol w_done = bit3            'used in maze solver
symbol w_direc1 = bit0          'bit 0 of solved direction
symbol w_direc2 = bit1          'bit 1 of solved direction

symbol map_walls2 = b1          'this is overlaid by the folwing 8 sysbols
symbol w_north2 = bit13         '1 if wall to north
symbol w_south2 = bit15         '1 if wall to south
symbol w_west2 = bit12          '1 it wall to west
symbol w_east2 = bit14          '1 if wall to east
symbol w_visited2 = bit10       '1 if mouse has visited this square
symbol w_done2 = bit11          'used in maze solver
symbol w_direc12 = bit8         'bit 0 of solved direction
symbol w_direc22 = bit9         'bit 1 of solved direction

symbol solvit = bit8            'run the solver
symbol clear_the_maze = bit9    'Used in maze solver

symbol backup_b0 = 239          'memory locations to save data
symbol backup_b1 = 126
symbol start_count = 238



symbol maze_pos = b10           'used by maze solver
symbol list1 = b11              'address of list1 entry
symbol list2 = b12              'address of list2 entry
symbol Target = b4              'address of target for maze solver

symbol pos = b13                'position of mouse in maze
symbol direc = b9               'direction of mouse in maze 0=north 1=east 2=south 3=west

symbol temp = b52
symbol temp2 = b6

symbol maze_start=$F0
symbol maze_center= $78 	   '$78=Center for 16X16 maze

#no_data
#no_table
	
main:
	
		switch off relay						'output to relay
		switch off sensor_leds			'IR leds off
		adcsetup =3
		setfreq em64				'external resinator speed
		pwmout motor_right,255,0		'stop right motor
		pwmout motor_left,255,0			'stop left motor
		gosub maze_setup				'setup maze
		pwmout motor_right,255,0		'stop right motor
		pwmout motor_left,255,0			'stop left motor
		ptr=0
		b45= 40					'mouse start square requires added wheel counts to straight line count
		switch on middle_green_led		'middle green led on
		switch on left_red_led			'left red led on
		switch on right_red_led			'right red led on
		
		do while start_button=1			'wait for start button 
			If button_A = 0 Then 		'If other button pressed output maze
				GoSub List_maze
			end if
		loop

		switch off middle_green_led		'middle green led off
	
		do while start_button=0			'wait for start button to be released
		loop
		
		front_sensor=0		
		switch off left_red_led			'left red led off
		switch off right_red_led		'right red led off
		pause 5000					'time to remove hand from mouse


steer_straight:
		pwmout motor_right,255,right_motor	
		pwmout motor_left,255,left_motor
		 
forward_loop:
				
		switch on sensor_leds			'IR leds on
		readadc  0,left_sensor			'read left wall sensor
		readadc  1,front_sensor			'read front wall sensor
		readadc  2,right_sensor			'read right wall sensor
		switch off sensor_leds			'IR leds off
		
		if left_sensor> left_wall then
			wall_config= 1			'wall config value for current cell
			switch on left_red_led 
		else
			wall_config= 0			'wall config value for current cell
			switch off left_red_led		'no left wall left red led off
		endif
		
		if right_sensor> right_wall then
			switch on right_red_led
			wall_config=wall_config+ 2	'wall config value for current cell
		else
			switch off right_red_led	'no right wall right red led off
		endif

		last_wheel=pinc.0
		do while last_wheel=pinc.0		'wait for left wheel counter
			@ptr=@ptr and 247			'Clear maze working bit
			ptrl=ptrl+1
		loop

		b45=b45 + 1					'add one to straight line counter
		
		if front_sensor> reset_frontwall then 	'front wall detected end of current move
			switch on sensor_leds			'IR leds on
			readadc 1,front_sensor			'read front wall sensor
			switch off sensor_leds			'IR leds off
			if front_sensor> reset_frontwall then end_move 'double check front sensor for timing gate interference
		endif		
		
		if wall_config<b44 then 			'has wall config changed
			if b45>=20 then
				b45= 92				'use change in wall config to correct straight line wheel counter
				b44= 0				'resets wall config for previous cell
			endif
		else
			b44=wall_config
		endif
		
		if b45>117 then end_move			'straight line wheel counter end of current move

		if left_sensor< left_wall then 		'straighten on left wall if available
			if right_sensor< right_wall then steer_straight		'straighten on right wall if available
			if right_sensor< right_straighten then steer_right		
		else
			if left_sensor> left_straighten then steer_right
		endif
		
		pwmout motor_left,255,slowleft_motor		'slower speed for left motor to straighten mouse
		pwmout motor_right,255,right_motor
		goto forward_loop

end_move:	if start_button = 0 then			'stop if start button pressed
			pwmout motor_right,255,0		'stop right motor
			pwmout motor_left,255,0			'stop left motor
			gosub save_maze 
			goto main
		endif	
				 
		gosub direction_check				'end of cell check for next move
		b44= 0						'resets wall config for previous cell
		goto steer_straight

steer_right:
		pwmout motor_right,255,slowright_motor	'slower speed for right motor to straighten mouse
		pwmout motor_left,255,left_motor
		goto forward_loop


straight:
		b45 = 0
return
		

right_turn:	
		b48=straight_before_right
		gosub left_wheel_counter
		pwmout motor_right,255,0
		b48= angle_right
		gosub left_wheel_counter
		b45= straight_after_right
return


left_turn:	
		b48=straight_before_left
		gosub left_wheel_counter
		pwmout motor_left,255,0
		b48= angle_left
		gosub right_wheel_counter
		b45= straight_after_left
return
									

turn_round:	
		b48= straight_turnround
		b47= 0
		
		last_wheel=pinc.0
		do
			pwmout motor_right,255,right_motor
			pwmout motor_left,255,left_motor
			
			switch on sensor_leds				'IR leds on
			readadc  0,left_sensor				'reads left wall to straight on
			readadc  1,front_sensor				'read front wall sensor
			switch off sensor_leds
			 
			if front_sensor>reset_frontwall then	'if dead end travel to end wall 
			 	b47=0
			endif
			 
			if left_sensor>= left_wall then
				if left_sensor< left_straighten then 
					pwmout motor_left,255,slowleft_motor	'slower speed for left motor to straighten mouse
				else
				 	pwmout motor_right,255,slowright_motor	'slower speed for right motor to straighten mouse
				endif
			endif
										
			
			do while last_wheel=pinc.0			'wait for left wheel counter
				@ptr=@ptr and 247
				ptrl=ptrl+1
			loop
			last_wheel=pinc.0
			
			b47=b47+ 1
			
		loop until b47=b48 or front_sensor>end_wall
		
		pwmout motor_right,255,0			'stop both motors before turnround
		pause 40						'adjusted to ensure mouse stops without twist
		pwmout motor_left,255,0
		
		if solvit=1 then
			GoSub solve_maze
            	solvit = 0
            endif
            
		switch on relay					'switch relay on
		pwmout motor_right,255,700			'right_motor
		pwmout motor_left,255,700			'left_motor
		b48= angle_turnround
		
		gosub right_wheel_counter			'count turnround
		
		pwmout motor_right,255,0
		pause 40						'adjusted to ensure mouse stops without twist
		pwmout motor_left,255,0
		switch off relay					'switch relay off
		pause 500
		b45= 30						'after deadend requires added wheel counts to straight line count
		pwmout motor_right,255,right_motor
		pwmout motor_left,255,left_motor
		return


left_wheel_counter:						'count left wheel counter to the value of b8

		b47=0
		
		do
			last_wheel=pinc.0
			
			do while last_wheel=pinc.0		'wait for left wheel counter to change
				@ptr=@ptr and 247
				ptrl=ptrl+1
			loop
			
			b47=b47+ 1
			
		loop until b47=b48		

return



right_wheel_counter:						'count right wheel counter to the value of b8

		b47=0
		
		do
			last_wheel=pinc.3
			
			do while last_wheel=pinc.3		'wait for right wheel counter to change
				@ptr=@ptr and 247
				ptrl=ptrl+1
			loop
			
			b47=b47+ 1
			
		loop until b47=b48		

return





direction_check:	
		if front_sensor> front_wall then
			switch on middle_green_led		'middle green led on if wall is detected
			wall_config=wall_config+ 4		'wall config walue for current cell
		else
			switch off middle_green_led
		endif
		
		pwmout motor_right,255,0			'stop right motor untill next move is decided
		pause 20						'adjusted to ensure mouse stops with no twist
		pwmout motor_left,255,0				'stop left motor untill next move is decided
		 
		 
		sensor=wall_config
		gosub check_cell
		b46=b8
		pwmout motor_right,255,right_motor
		pause 35						'ajusted to ensure mouse starts with no twist
		pwmout motor_left,255,left_motor
		 		 
		
		on b46 gosub turn_round,straight,right_turn,left_turn

		return





Maze_setup:
        'Setup maze for new run
        
        
        if	button_a = 0 then
        	GoSub clear_maze        	'if button pressed then reset the maze map
		gosub save_maze
        else
        	gosub restore_maze
        	GoSub clear_maze_bits   	'Rest the maze for solving
        end if
        
        switch on yellow_led
        
        Target = maze_center 			'first run to the center
        pos = maze_start - 16 'start in bottom left square (mouse always starts with a forward move so asume start one square forward)
        direc = 0                   	'facing north
        solvit = 0
                
        GoSub solve_maze                	'solve the maze
        
        switch off yellow_led             	'mouse ready to go when yellow led is off
        
        return
        
        


check_cell:                               	'check if direction required for PIC28 called when pin 6 is High


         If pos = Target Then    		'if at target swap to go back to start/center
         		gosub save_maze
         		solvit = 1
                 If Target = maze_center Then
                         Target = maze_start
                         switch on green_led
                 Else	
                       Target = maze_center
                       switch off green_led
                       b39=b39+1
                       if b39 = 2 then
                       	gosub fill_maze
                       endif
                 End If
                 gosub solve_maze
	   end if
        

        
        get pos, map_walls     		'get the maze map info for the position of the mouse

        If w_visited = 0 Then   		'if already been here dont store the walls again
                solvit = 1
        else
        	if solvit = 1 then
        		if sensor=0 or sensor=1 or sensor=2 or sensor=4 then
        			GoSub solve_maze
                  	solvit = 0
                  	clear_the_maze = 1
                  	get pos, map_walls
                  endif  	
        	endif
        
        End If
        
       
        
        Do
                Select Case sensor
                        Case 3
                                b8 = 1      'if walls both sides and no front wall always go forward
                        Case 5
                                b8 = 2	  
                        Case 6
                                b8 = 3
                        Case 7
                                b8 = 0
                        Else
                                    b8=map_walls & %00000011
                                select case direc  'convert to wall map bits depending on the direction of the mouse
                                        Case 0
                                                lookup b8,(1,2,0,3),b8 'mouse facing north
                                        Case 1
                                                lookup b8,(3,1,2,0),b8 'mouse facing east
                                        Case 2
                                                lookup b8,(0,3,1,2),b8  'mouse facing south
                                        Case 3
                                                lookup b8,(2,0,3,1),b8 'mouse facing west
                                endselect
                                
                                If solvit = 1 Then
                                        Select Case b8
                                                
                                                Case 0
                                                        b8 = 100
                                                Case 1
                                                        If sensor = 4 Then
                                                                b8 = 100
                                                        End If
                                                Case 2
                                                        If sensor = 2 Then
                                                                b8 = 100
                                                        End If
                                                Case 3
                                                        If sensor = 1 Then
                                                                b8 = 100
                                                        End If
                                        endselect
                                End If
                endselect
                
                
                If b8 = 100 Then
                		If w_visited = 0 Then
                        	GoSub write_the_mazemap
                        endif
                        GoSub solve_maze
                        solvit = 0
                        clear_the_maze = 1
                        get pos, map_walls
                        
                End If

        Loop Until b8 < 100
        
        
        If w_visited = 0 Then
                GoSub write_the_mazemap
                solvit=1
        End If
    
        get pos, map_walls


        On b8 GoSub go_round, go_forward, go_right, go_left
        
        switch off yellow_led
        
Return

go_left:                                'Mouse turning left
        dec direc
        If direc = 255 Then
                direc = 3
        End If
        GoTo go_forward
Return

go_right:                               'Mouse turning right
        inc direc
        If direc = 4 Then
                direc = 0
        End If
        GoTo go_forward
Return

go_round:                               'Mouse to do a U turn
        direc = direc + 2
        If direc > 3 Then
                direc = direc - 4
        End If
        GoTo go_forward
Return

go_forward:                             'mouse moving forward (Also move forward after a turn)

        Select Case direc
        Case 0
                pos = pos - 16 	'move north
        Case 1
                inc pos         	'move east
        Case 2
                pos = pos + 16 	'move south
        Case 3
                dec pos         	'move west
        endselect
        
Return


write_the_mazemap:			'Add new walls to the maze map

                select case direc   'convert to wall map bits depending on the direction of the mouse
                				'Also sets viseted bit for this square
                Case 0
                        lookup sensor,(4,20,68,84,36,52,100,116),b53 	'mouse facing north
                Case 1
                        lookup sensor,(4,36,132,164,68,100,196,228),b53 	'mouse facing east
                Case 2
                        lookup sensor,(4,68,20,84,132,196,148,212),b53   'mouse facing south
                Case 3
                        lookup sensor,(4,132,36,164,20,148,52,180),b53 	'mouse facing west
                endselect
                

                map_walls = map_walls | b53

                put pos,map_walls

Return


solve_maze:                             	'Solve the maze

        clear_the_maze=1
        
        poke backup_b0, map_walls       	'save varibals
        poke backup_b1, map_walls2
        
        switch on yellow_led
        list1=$50           			'initalize list1 address
        list2=$C0           			'initalize list2 address
        poke list1, Target      		'add maze center to list 1
        poke $51,target         		'terminate list1
        get Target, map_walls2
        w_done2 = 1
        put target,map_walls2
        
        Do
                Do
                        peek list1, maze_pos 'get next pos from list1
                        inc list1
                        
                        get maze_pos, map_walls2 'get wall map
                        

                        If w_north2 = 0 Then
                                                 'add_north
                                temp = maze_pos - 16
                                get temp, map_walls
                                
                                If w_done = 0 And w_south = 0 Then
                                        w_direc1 = 0
                                        map_walls=map_walls|%00001010
                                        put b52,map_walls
                                        If temp = pos Then GoTo End_maze
                                        poke list2, temp 'add to list2
                                        inc list2
                                End If
                        End If
                        
                        If w_south2 = 0 Then
                                                  'add_south
                                temp = maze_pos + 16
                                get temp, map_walls
                                
                                If w_done = 0 And w_north = 0 Then
                                        w_done = 1
                                        map_walls=map_walls&%11111100
                                        put temp,map_walls
                                        If temp = pos Then GoTo End_maze
                                        poke list2, temp 'add to list2
                                        inc list2
                                                
                                End If
                        End If
                        
                        If w_east2 = 0 Then
                                                   'add_east
                                temp = maze_pos + 1
                                get temp, map_walls
                                If w_done = 0 And w_west = 0 Then
                                        map_walls=map_walls|%00001011
                                        put temp,map_walls
                                        If temp = pos Then GoTo End_maze
                                        poke list2, temp 'add to list2
                                        inc list2
                                End If
                        End If
                        
                        If w_west2 = 0 Then
                                                    'add_west
                                temp = maze_pos - 1
                                get temp, map_walls
                                If w_done = 0 And w_east = 0 Then
                                        w_direc2 = 0
                                        map_walls=map_walls|%00001001
                                        put temp,map_walls
                                        If temp = pos Then GoTo End_maze
                                        poke list2, temp 'add to list2
                                        inc list2
                                End If
                        End If
                        
                Loop Until maze_pos = Target
        
                poke list2, Target              'terminate list 2
                
                if      list1<$C0 then  		'Swap and reset the lists
                        list1=$C0
                        list2=$50
                 Else
                        list1=$50
                        list2=$C0
                End If

                peek list1, maze_pos 		'get next pos from list1
                
        Loop Until maze_pos = Target

        							'the maze is solved
End_maze:

        get pos, map_walls
        If w_done = 0 Then GoTo maze_unsolvable
        
        peek backup_b0, map_walls 			'restore bit variables
        peek backup_b1, map_walls2
        switch off yellow_led

Return


clear_maze_bits:                        		'clear done bits in map

        toggle green_led
        
        For temp = 0 To 255
                get temp, map_walls

                w_done = 0
                put temp,map_walls
          
        Next
        
        toggle green_led
        
        clear_the_maze = 0

Return


save_maze:                       			'save maze to eeprom
     	gosub led_thing
      gosub led_thing
	gosub led_thing
	gosub led_thing
    
      For temp = 0 To 255
              get temp, map_walls
              write temp,map_walls
      Next

Return


restore_maze:                     			'restore maze from eeprom

	setfreq m8
       
     	gosub led_thing_2
      gosub led_thing_2
	gosub led_thing_2
	gosub led_thing_2

	setfreq em64

      For temp = 0 To 255
              read temp, map_walls
              put temp,map_walls
      Next

Return


Fill_maze:                       			'Block all unviseted paths

        For b6 = 0 To 255
                get b6, map_walls
                If w_visited = 0 Then
                        w_north = 1
                        w_south = 1
                        w_east	= 1
                        w_west	= 1
                        put b6,map_walls
                End If
        Next
        

Return


clear_maze:							'Reset to a blank maze

	setfreq M8
	gosub led_thing
	gosub led_thing
	setfreq em64

        switch on green_led
        switch on yellow_led

        for temp=$01 to $0E                     'clear the top line
                put temp,$20
        Next
        
        for temp=$F2 to $FE                     'clear the bottom line
                put temp,$80
        Next
        
        for b53=$10 to $E0 step $10      		'clear left side
                put b53,$10
                for temp=$01 to $0E
                        b0 = temp + b53 		'clear center maze
                        put b0,$00
                Next
                inc b0
                put b0,$40            		'clear right side
        Next
        
        put $00,$30                   		'clear maze corners
        put $0F,$60
        put $F0,$D4
        put $FF,$C0
        put $F1,$90
        
        clear_the_maze = 0
        
        switch off green_led
        switch off yellow_led
        
Return


List_maze:                  				'list maze to debug window

    setfreq M8

    sertxd(" ",13,10)
    
    For temp = 0 To 240 Step 16
        
        b8 = temp + 15
        
        For temp2 = temp To b8
            get temp2, map_walls
            b53 = temp2 - 16
            get b53, map_walls2
            If w_north = 1 Or w_south2 = 1 Then
                sertxd ("+-")
            Else
                sertxd ("+ ")
            End If
        Next
        
        sertxd("+",13,10)
        
        map_walls2 = 0
        b8 = temp + 15
        
        For temp2 = temp To b8
            get temp2, map_walls
            
            If w_west = 1 Or w_east2 = 1 Then
                sertxd ("|")
            Else
                sertxd (" ")
            End If
            
		if w_done=1 then
	            b53=map_walls & %00000011
      	      lookup b53,("^",">","v","<"),b53
      	else
      		b53=" "
      	endif
      	
            sertxd (b53)
            map_walls2 = map_walls
        Next
        sertxd("|",13,10)
        
    Next
    sertxd("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+",13,10)
    
    SETFREQ EM64

Return

       
maze_unsolvable:

	setfreq m2
	
	gosub led_thing

	
	If button_A=0 then
		gosub list_maze
	endif
	
goto maze_unsolvable


LED_thing:

      switch off yellow_led
	switch on green_led
	pause 100
	switch off green_led
	switch on yellow_led
	pause 75
	switch off yellow_led
	switch on right_red_led
	pause 50
	switch off right_red_led
	switch on middle_green_led
	pause 75
	switch off middle_green_led
	switch on left_red_led
	pause 100
	switch off left_red_led
	switch on middle_green_led
	pause 75
	switch off middle_green_led
	switch on right_red_led
	pause 50
	switch off right_red_led
	switch on yellow_led
	pause 75
	
	return
 
End


led_thing_2:

      switch off middle_green_led
	switch on green_led
	pause 100
	switch off left_red_led
	switch on yellow_led
	pause 100
	switch off green_led
	switch on right_red_led
	pause 100
	switch off yellow_led
	switch on middle_green_led
	pause 100
	switch off right_red_led
	switch on left_red_led
	pause 100
	
	return



































































































