#Fall 2020 CSE12 Lab5 Test File
#
#------------------------------------------------------------------------
# pop and push macros
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#------------------------------------------------------------------------
# print string

.macro print_str(%str)

	.data
	str_to_print: .asciiz %str

	.text
	push($a0)                        # push $a0 and $v0 to stack so
	push($v0)                         # values are not overwritten
	
	addiu $v0, $zero, 4
	la    $a0, str_to_print
	syscall

	pop($v0)                        # pop $a0 and $v0 off stack
	pop($a0)
.end_macro

.macro printSRegContents(%str)
	print_str(%str)
	push($a0)                        # push $a0 and $v0 to stack so
	push($v0)                         # values are not overwritten
		
	li $v0, 34
	move $a0, $s0
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	
	li $v0, 34
	move $a0, $s1
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	
	li $v0, 34
	move $a0, $s2
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	
	li $v0, 34
	move $a0, $s3
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	
	li $v0, 34
	move $a0, $s4
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	
	li $v0, 34
	move $a0, $s5
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	
	li $v0, 34
	move $a0, $s6
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	
	li $v0, 34
	move $a0, $s7
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	
	pop($v0)                        # pop $a0 and $v0 off stack
	pop($a0)
.end_macro
#------------------------------------------------------------------------
# data segment
.data
black: .word 0x00000000
white: .word 0x00FFFFFF
red: .word 0x00FF0000
green: .word 0x0000FF00
blue: .word 0x000000F
orange: .word 0xFFA500
yellow: .word 0x00FFFF00
cyan: .word 0x0000FFFF
midnightblue: .word 0x00191970
firebrick: .word 0x00B22222
slategray: .word 0x00708090
mediumseagreen: .word 0x003CB371
darkgreen: .word 0x00006400
indigo: .word 0x004B0082

.text
main: nop
#Fill up S registers to check for saved s registers
li $s0 0XFEEDBABE
li $s1 0XC0FFEEEE
li $s2 0XBABEDADE
li $s3 0XFEED0DAD
li $s4 0X00000000
li $s5 0XCAFECAFE
li $s6 0XBAD00DAD
li $s7 0XDAD00B0D

# 0. Clear bitmap test
print_str("-------------------------------\nClear_Bitmap Test:\n")
print_str("Paints entire bitmap a midnight blue color\n\n")
printSRegContents("S registers before: ")
lw $a0, midnightblue 	
jal clear_bitmap
printSRegContents("\nS registers after:  ")

# 1. Pixel test
print_str("\n\n-------------------------------\nPixel Test:\n")
print_str("Draws single orange pixel at (1,1) and yellow pixel at (126,126)\n\n")
printSRegContents("S registers before: ")
jal pixelTest
printSRegContents("\nS registers after:  ")

# 2. Rectangle test
print_str("\n\n-------------------------------\nRectangle Test:\n")
print_str("Creates a pattern using 5 solid rectangles\n\n")
printSRegContents("S registers before: ")
jal rectangleTest
printSRegContents("\nS registers after:  ")

# 3. Diamond test
print_str("\n\n-------------------------------\nDiamond Test:\n")
print_str("Creates a pattern using 9 solid diamonds\n\n")
printSRegContents("S registers before: ")    
jal diamondTest
printSRegContents("\nS registers after:  ")
	
#Exit when done
li $v0 10 
syscall

#------------------------------------------------------------------------
pixelTest: nop 
	push($ra)
	
	# Check for Clear_Bitmap test color
	print_str("\nGet_pixel($a0 = 0x00400040) should return: 0x00191970\nYour get_pixel($a0 = 0x00400040) returns:  ")
	li $a0, 0x00400040
	jal get_pixel
	move $a0, $v0
	li $v0, 34
	syscall
	
	# cyan point at  (1,1)
	li $a0, 0x00010001
	lw $a1, cyan
	jal draw_pixel
	
	# yellow point at  (126,126)
	li $a0, 0x007E007E
	lw $a1, yellow
	jal draw_pixel
	
	print_str("\nGet_pixel($a0 = 0x00010001) should return: 0x0000ffff\nYour get_pixel($a0 = 0x00010001) returns:  ")
	li $a0, 0x00010001
	jal get_pixel
	move $a0, $v0
	li $v0, 34
	syscall
	
	print_str("\nGet_pixel($a0 = 0x007e007e) should return: 0x00ffff00\nYour get_pixel($a0 = 0x007e007e) returns:  ")
	li $a0, 0x007E007E
	jal get_pixel
	move $a0, $v0
	li $v0, 34
	syscall
	
	pop($ra)
	jr $ra

rectangleTest: nop    
	push($ra)
	
	li $a0, 0x00200020
	li $a1, 0x00400040
	lw $a2, cyan
	jal draw_rect

	li $a0, 0x00100010
	li $a1, 0x00200020
	lw $a2, orange
	jal draw_rect

	li $a0, 0x00500010
	li $a1, 0x00200020
	lw $a2, orange
	jal draw_rect

	li $a0, 0x00100050
	li $a1, 0x00200020
	lw $a2, orange
	jal draw_rect

	li $a0, 0x00500050
	li $a1, 0x00200020
	lw $a2, orange
	jal draw_rect
	
	
	print_str("\nGet_pixel($a0 = 0x001e0064) should return: 0x00ffa500\nYour get_pixel($a0 = 0x001e0064) returns:  ")
	li $a0, 0x001e0064
	jal get_pixel
	move $a0, $v0
	li $v0, 34
	syscall
	
	print_str("\nGet_pixel($a0 = 0x00400040) should return: 0x0000ffff\nYour get_pixel($a0 = 0x00400040) returns:  ")
	li $a0, 0x00400040
	jal get_pixel
	move $a0, $v0
	li $v0, 34
	syscall
	
	print_str("\nGet_pixel($a0 = 0x00400064) should return: 0x00191970\nYour get_pixel($a0 = 0x00400064) returns:  ")
	li $a0, 0x00400064
	jal get_pixel
	move $a0, $v0
	li $v0, 34
	syscall
	
	pop($ra)
	jr $ra

#------------------------------------------------------------------------  
diamondTest: nop    
	push($ra)
	
	li $a0, 0x00200010
	li $a1, 30
	lw $a2, cyan
	jal draw_diamond

	li $a0, 0x00200030
	li $a1, 30
	lw $a2, firebrick
	jal draw_diamond
	
	li $a0, 0x00200050
	li $a1, 30
	lw $a2, cyan
	jal draw_diamond


	li $a0, 0x00400010
	li $a1, 30
	lw $a2, firebrick
	jal draw_diamond

	li $a0, 0x00400030
	li $a1, 30
	lw $a2, firebrick
	jal draw_diamond
	
	li $a0, 0x00400050
	li $a1, 30
	lw $a2, firebrick
	jal draw_diamond


	li $a0, 0x00600010
	li $a1, 30
	lw $a2, cyan
	jal draw_diamond

	li $a0, 0x00600030
	li $a1, 30
	lw $a2, firebrick
	jal draw_diamond
	
	li $a0, 0x00600050
	li $a1, 30
	lw $a2, cyan
	jal draw_diamond

	
	print_str("\nGet_pixel($a0 = 0x00400057) should return: 0x00b22222\nYour get_pixel($a0 = 0x00400057) returns:  ")
	li $a0, 0x00400057
	jal get_pixel
	move $a0, $v0
	li $v0, 34
	syscall
	
	print_str("\nGet_pixel($a0 = 0x00460032) should return: 0x0000ffff\nYour get_pixel($a0 = 0x00460032) returns:  ")
	li $a0, 0x00460032
	jal get_pixel
	move $a0, $v0
	li $v0, 34
	syscall
	
	print_str("\nGet_pixel($a0 = 0x00010020) should return: 0x00191970\nYour get_pixel($a0 = 0x00010020) returns:  ")
	li $a0, 0x00010020
	jal get_pixel
	move $a0, $v0
	li $v0, 34
	syscall
	
	pop($ra)
	jr $ra
	
#------------------------------------------------------------------------  
# Be sure to use the lab5_s20_template.asm and rename it to Lab5.asm so it
# is included here!
# 
.include "Lab5.asm"
