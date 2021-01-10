#########################################################################
# Created by:  Zepeda, Pablo 
#              pzepeda
#              7 December 2020
#
# Assignment:  Lab 5: Function and Graphics              
#              CSE 12/L, Computer Systems and Assembly Language 
#              UC Santa Cruz, Fall 2020
#
# Description: This program will perform some primitive graphics operations 
#              on a simulated Bitmap display. The functions utilized will  
#              fill the display with a given color, create  
#              rectangular and diamond shapes using a memory - mapped 
#              graphics display tool in MARS called Bitmap. 
#
# Notes:       This program is intended to be run from the MARS IDE.
#########################################################################
#Fall 2020 CSE12 Lab5 File

## Macro that stores the value in %reg on the stack 
##  and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
.macro getCoordinates(%input %x %y)
# Bit wise AND of 0x00XX00YY & 0x00ff0000 = 0x00xx0000
# Apply a Right Logical shift, srl, to move the XX bits by 16 bits to have 0x000000xx
# Bit wise AND of 0x00XX00YY & 0x000000ff = 0x000000yy
andi %x, %input, 0x00ff0000  # bitwise and,  x is now 0x00xx0000
srl %x,%x, 16 		     # logical right shift by 16 bits, x is now 0x000000xx	    
andi %y, %input, 0x000000ff  # bitwise and, y is now 0x000000yy 
 
.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
.macro formatCoordinates(%output %x %y)
# Move %x into %output, 0x000000XX
# Apply a Left Logical shift, sll, to move the XX bits by 16 bits to have 0x00XX0000 
# Bit wise OR of 0x00XX0000 & 0x000000YY = 0x00XX00YY
move %output, %x         #output is now 0x000000XX
sll %output, %output, 16 #shift XX to the left by 16 bits, output is now 0x00XX0000 
or %output, %output, %y #bitwise OR 0 or Y becomes Y, output is now 0x00XX00YY

.end_macro 


.data
originAddress: .word 0xFFFF0000

.text
# test to see if subroutines work
#li $a0, 0x00250025      # coordinates of pixel in format (0x00XX00YY)
#li $a1, 0x00FF0000      # color of pixel in format (0x00RRGGBB)
#push($ra)		# save $ra before jal
#jal draw_pixel
#pop($ra)                # restore when the subroutine returns 

#li $a0, 0x00FFFF00     # Color in format (0x00RRGGBB) 
#push($ra)              # save $ra before jal
#jal clear_bitmap      
#pop($ra)               # restore when the subroutine returns

j done
    
done: nop
	li $v0 10 
	syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
#Clear_bitmap: Given a color, will fill the bitmap display with that color.
#   Inputs:
#    $a0 = Color in format (0x00RRGGBB) 
#   Outputs:
#    No register outputs
#    Side-Effects: 
#    Colors the Bitmap display all the same color
#*****************************************************
clear_bitmap: nop
#callee
#0xFFFF0000 to 0xFFFFFFFF,  LAB 5 Document said it's okay to hard-code the value 0xFFFF0000
#sw store color 
#$t0  = 0xFFFF0000
# add 4 bytes for each pixel
#sw $a0, ($t0)
# save data onto the stack 
# start at the base address of the bit map canvas 
# for loop (i = base_address; i > 0xFFFFFFFF; i = i + 4) Add 4 bytes to transverse to the next pixel
# { store the color into the address location }
# restore data from the stack 
# return 
push($ra)   	     # save data onto the stack 
push($t0)
push($a0)

li $t0, 0xFFFF0000    # base address of the canvas,   LAB 5 Document said it's okay to hard-code the value 0xFFFF0000 
loop:
bgt $t0, 0xFFFFFFFF, out  #if we reach the end of the canvas break out of the loop, iterating address > end of bitmap canvas
sw $a0, ($t0)         # store color into address location 
addi $t0, $t0, 4      # add 4 bytes for each pixel

b loop               # loop until condition is met 
 
out:    # The bitmap display is filled with a specific color 

pop($a0)	# restore data from the stack 
pop($t0)	
pop($ra)
 	jr $ra # return to the caller 

#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#*****************************************************
draw_pixel: nop 
# $t3 x
# $t4 y
# save data onto the stack 
# Call get getCoordinates()
# input: $a0 = 0x00XX00YY output:  $t3 = x-coor 0x000000XX, $t4 = y-coor 0x000000YY
# Base address for Bitmap display, Oxffff0000
# Display width & Height in Pixels 128 x 128
# Calculate address to store color  
# Base address + (x-coord + y-coord * 128) * 4 bytes 
# 0xFFFF0000 + (x + y * 128) * 4
# $t0 = calculated address 
# store the color, $a1, in the calculated address, $t0   
# restore data from the stack 
push($ra)		
push($a0)		# save data onto the stack 
push($a1)  	
push($t0)
push($t3)
push($t4)
getCoordinates($a0, $t3, $t4) # output $t3: x-coor, $t4: y-coor
			# calculate the address & store the result in $t0
			#0xFFFF0000 + (x + y * 128) * 4
mul $t0, $t4, 128       # $t0 = y * 128
add $t0, $t3, $t0       # $t0 = x + (y * 128)
mul $t0, $t0, 4		# $t0 = (x + (y * 128)) * 4 	
			# $t0 = 0xFFFF0000 + (x + y * 128) * 4
add, $t0, $t0, 0xFFFF0000  # LAB 5 Document said it's okay to hard-code the value 0xFFFF0000
sw $a1, ($t0)        #store the color from $a1 into the calculated address, $t0 

pop($t4)
pop($t3)
pop($t0)
pop($a1)		# restore data from the stack 
pop($a0)
pop($ra)
	jr $ra       # return to the caller 
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#   Outputs:
#    Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
get_pixel: nop
# save data onto the stack
# Call get getCoordinates()
# input: $a0 = 0x00XX00YY output:  $t3 = x-coor 0x000000XX, $t4 = y-coor 0x000000YY
# Calculate address and load the pixel color into $v0 
# 0xFFFF0000 + (x + y * 128) * 4
# $t0 = calculated address
# load the pixel color into $v0 from the calculated address, $t0
# restore data from the stack 

push($a0)      # push temporary data onto stack to restore it later
push($t3)
push($t4)
push($ra)
	getCoordinates($a0, $t3, $t4) # output $t3: x-coor, $t4: y-coor
			#0xFFFF0000 + (x + y * 128) * 4
mul $t0, $t4, 128       # $t0 = y * 128
add $t0, $t3, $t0	# $t0 = x + (y * 128)
mul $t0, $t0, 4		# $t0 = (x + (y * 128)) * 4
			# $t0 = 0xFFFF0000 + (x + y * 128) * 4
add, $t0, $t0, 0xFFFF0000  # LAB 5 Document said it's okay to hard-code the value 0xFFFF0000
lw $v0, ($t0)         # loading the word pixel color from the calculated address into $v0
pop($ra)
pop($t4)
pop($t3)
pop($a0)              # pop and restore from stack, last-in, first out LIFO  

	jr $ra       # return to the caller

#*****************************************************
#draw_rect: Draws a rectangle on the bitmap display.
#	Inputs:
#		$a0 = coordinates of top left pixel in format (0x00XX00YY)
#		$a1 = width and height of rectangle in format (0x00WW00HH)
#		$a2 = color in format (0x00RRGGBB) 
#	Outputs:
#		No register outputs
#*****************************************************
# save data onto the stack
# call getCoordinates(), $a0 = 0x00XX00YY, output: $t0 = x-coor, $t1 = y-coor
# call getCoordinates(), $a1 = width and height of rectangle in format (0x00WW00HH)
# output $t2: width, $t3: height
# x-coor, $t0, + width, $t2, = x-value @ bottom right of rectangle 
# y-coor, $t1 + height, $t3, = y-val @ bottom right of rectangle 
# save the value of $t1, y-coord or COL, to reset the COL
#
# for (x-coor = $t0; x-coor < = x-value @ bottom right of the rectangle; x-coor++)
# 	$t0 is iterator, coord to draw at 
#
# 	for (y-coord = $t1; y-coor < = y-value @ bottom right of the rectangle; y-coor++)
#		call formatCoordinates()  x, y coord inputs $t0, $t1, returns %output = (0x00XX00YY) in $a0
#		$a2 has the color, when draw_rect is called, move the color into $a1 for draw_pixel input
#		save the values on to the stack, $ra, $t0, $t1, $t2, $t3 ,$t4 before draw_pixel changes them
#		call draw_pixel, subroutine changes $t3, $t0, $t4
#		restore the values from the stack, $t4, $t3, $t2, $t1, $t0, $ra
#		
# reset the col, y coord, $t1 back to the starting coord 
# exit out of outer loop
# restore data from the stack 
# return to the caller
#	
#		
draw_rect: nop
	push($a0)
	push($t0)    			# push temporary data onto stack to restore it later
	push($t1)
	push($a1)
	push($a2)
	push($t2)
	push($t3)
	push($t4)			       # $a0 = coordinates of top left pixel in format (0x00XX00YY)
	getCoordinates($a0, $t0, $t1)  # output $t0: x-coor, $t1: y-coor
				       # $a1 = width and height of rectangle in format (0x00WW00HH)
	getCoordinates($a1, $t2, $t3)  # output $t2: width, $t3: height 
	add $t2, $t0, $t2  # $t2 = x-value @ bottom right of rectangle  
	add $t3, $t1, $t3  # $t3 = y-val @ bottom right of rectangle 
	#store in the value of $t1, to reset the col 
	move $t4, $t1		# save the value of $t1, y-coord or COL, to reset the COL 
	label_1: 			# for (x-coord = $t0; x-coor < = x-value @ bottom right of the rectangle; x-coor++)
		#t0 is iterator, coord to draw at 
		 
		 
		bge $t0, $t2, exit # if the iterator >= x-value @ bottom right of the rectangle, exit out of outter loop 
		
		label_2: # for (y-coord = $t1; y-coor < = y-value @ bottom right of the rectangle; y-coor++)
			bge $t1, $t3, exitOutOfInnerLoop  # if y-coord >= y-val @ bottom right of rectangle, exit out of inner loop
			formatCoordinates($a0,$t0 ,$t1)  # x, y coord inputs, returns %output = (0x00XX00YY), ready for draw_pixel 
			#$a0 = coordinates of pixel in format (0x00XX00YY)
			#move $a2, into $a1, has the color 
			#call draw_pixel
			move $a1, $a2 #$a2 has the color,when draw_rect is called, move the color into $a1 for draw_pixel input
			push($ra)
			push($t0)
			push($t1)      # save the values on to the stack, before draw_pixel changes them 
			push($t2)
			push($t3)           
			push($t4)
			jal draw_pixel	# draw pixel changes $t3, $t0, $t4 
			pop($t4)
			pop($t3)
			pop($t2)
			pop($t1)	# restore the values from the stack
			pop($t0)
			pop($ra)
			#$a1 = color of pixel in format (0x00RRGGBB)
			#Draw rectangle input $a2 = color in format (0x00RRGGBB) 
			
			
			add $t1, $t1, 1 #moving from pixel to pixel, y-coord 
			j label_2 
		exitOutOfInnerLoop:
		
		move $t1, $t4 #reset the col, y coord, $t1 back to the starting coord 
		add $t0, $t0, 1 #moving from pixel to pixel, x-coord  
	j  label_1   
		
exit: 
	#pop in reverse order 
	pop($t4)
	pop($t3)
	pop($t2)
	pop($a2)
	pop($a1)
	pop($t1)
	pop($t0)
	pop($a0)
 	jr $ra  	#return to the caller

#***********************************************
# draw_diamond:
#  Draw diamond of given height peaking at given point.
#  Note: Assume given height is odd.
#-----------------------------------------------------
# draw_diamond(height, base_point_x, base_point_y)
# 	for (dy = 0; dy <= h; dy++)
# 		y = base_point_y + dy
#
# 		if dy <= h/2
# 			x_min = base_point_x - dy
# 			x_max = base_point_x + dy
# 		else
# 			x_min = base_point_x - floor(h/2) + (dy - ceil(h/2)) = base_point_x - h + dy
# 			x_max = base_point_x + floor(h/2) - (dy - ceil(h/2)) = base_point_x + h - dy
#
#   		for (x=x_min; x<=x_max; x++) 
# 			draw_diamond_pixels(x, y)
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of top point of diamond in format (0x00XX00YY)
#    $a1 = height of the diamond (must be odd integer)
#    $a2 = color in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
# Pseudocode from Lab 5 Document
# Draw_diamond(height, base_point_x, base_point_y)
#            for (dy = 0; dy <= h; dy++)
#                y = base_point_y + dy
#
#                if dy <= h/2
#                    x_min = base_point_x - dy
#                    x_max = base_point_x + dy
#                else
#                    x_min = base_point_x - h + dy
#		    x_max = base_point_x + h - dy
#
#                 for (x=x_min; x<=x_max; x++) 
#                    draw_diamond_pixels(x, y)

draw_diamond: nop
	push($a0)
	push($t0)    			# push temporary data onto stack to restore it later
	push($t1)
	push($a1)
	push($a2)
	push($t2)
	push($t3)
	push($t4)
	push($t5)
	push($t6)
	push($t7)
	push($t8)
	push($t9)
	push($s0)				
	getCoordinates($a0, $t0, $t1)  #output: $t0 = base_point_x, $t1 = base_point_y
					# $a1 = height of diamond 
					# $a2 = color in format (0x00RRGGBB)
					# $t2 = dy 
					# $t3 = y 
					# $t4 = h/2
					# set $t5 = 0 or 1 depending on the if else statement 
					# $t6 = x_min
					# $t7 = x_max
					# $t8 = x = x_min

	div $t4, $a1, 2    		# $t4 = h/2 division      
	
	add $t2, $zero, $zero		#set dy = 0
	outerLoop: 				# for (dy = 0; dy > h; dy++)
	bgt $t2, $a1, breakOut 			# branch out if dy > h or $t2 > $a1  
	add $t3, $t1, $t2			# y = base_point_y + dy or $t3 = $t1 + $t2
	
	sle $t5, $t2, $t4    			# if dy <= h/2 set $t5 = 1 else set $t5 = 0
	beq $t5, $zero, else			#if $t5 = 0, branch out to else
	sub $t6, $t0, $t2 			# if block: x_min = base_point_x - dy
	add $t7, $t0, $t2			# x_max = base_point_x + dy
	j endIf	# skip over else block and go to endIf
	
else: 
	sub $t6, $t0, $a1  			# x_min = base_point_x - h + dy
	add $t6, $t6, $t2			# $t6 = x_min
	
	add $t7, $t0, $a1 			# x_max = base_point_x + h - dy	
	sub $t7, $t7, $t2			# $t7 = x_max
						
endIf:				        	# end of if - else block 
						# for (x = x_min; x <= x_max; x++)
	move $t8, $t6					# $t8 = x = x_min
innerForLoop:
	
	bgt $t8, $t7, outOfForLoop 				# if x > x_max branch out 
	formatCoordinates($a0,$t8 ,$t3)  # x, y coord inputs, returns %output = (0x00XX00YY), ready for draw_pixel 
	move $t9, $a1				#Save the height value from $a1 into $t9,
	move $a1, $a2 #$a2 has the color,when draw_diamond is called, move the color into $a1 for draw_pixel input
	push($ra)
	push($t0)
	push($t1)      # save the values on to the stack, before draw_pixel changes them 
	push($t2)
	push($t3)           
	push($t4)
	jal draw_pixel	# draw pixel changes $t3, $t0, $t4 						  
	pop($t4)
	pop($t3)
	pop($t2)
	pop($t1)	# restore the values from the stack
	pop($t0)
	pop($ra)
	move $a1, $t9		# put the height value back into $a1
	
	addi $t8, $t8, 1					#increment x by one, x++
	
	j innerForLoop
	
	
outOfForLoop:			# out of inner for loop 
	addi $t2, $t2, 1			# increment $t2 by one or dy++

	j outerLoop
	
	
	breakOut: 
	#pop in reverse order 
	pop($s0)
	pop($t9)
	pop($t8)
	pop($t7)
	pop($t6)
	pop($t5)
	pop($t4)
	pop($t3)
	pop($t2)
	pop($a2)
	pop($a1)
	pop($t1)
	pop($t0)
	pop($a0)
	jr $ra

	