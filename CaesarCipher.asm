# Jaron Lin, Jonah Lysne, Alan Mong, Timothy Lee
# Project Topic: Caesar Cipher
# Description: The Caesar cipher is a encrpytion technique (more specifically a substitution cipher)
# it takes a "shift" or "key" and then moves each letter with a fixed number of positions down the alphabet

# MACROS
.macro print(%str)
	li $v0, 4
	la $a0, %str
	syscall
.end_macro

.macro inputStr(%buffer, %size, %destination)
	li $v0, 8
	la $a0, %buffer
	li $a1, %size
	move %destination, $a0
	syscall
.end_macro

.macro inputInt(%destination)
	li $v0, 5
	syscall
	move %destination, $v0
.end_macro 

.macro getStart(%char, %destination)
	li $t9, 90 #ASCII value of 'Z'
	bgt %char, $t9, lowercase # check if char is uppercase

	li %destination, 65 #set to uppercase letter
	j end_macro
	
	lowercase:
		li %destination, 97 #set to lowercase letter
		j end_macro
		
	end_macro:
.end_macro 

# DATA #
.data
promptMode: .asciiz "\n================================================\n Caesar Cipher\n Please choose one of the following modes:\n Encryption (0)\n Decryption (1)\n Exit (2)\n================================================\n"
promptCarrot: .asciiz "> "
promptPlain: .asciiz "\nPlease enter your plain text (max 500 chars): "
plainString: .space 501
promptCipher: .asciiz "\nPlease enter your cipher text (max 500 chars): "
cipherString: .space 501
promptShift: .asciiz "Please enter your shift (integer value): "
modeError: .asciiz "\nThere was an error in your input. Please choose 0, 1, or 2."
modeExit: .ascii "\nGoodbye :)"

# TEXT #
.text
main:
	#display mode prompt
	print(promptMode)
	
	#store if user inputs 0 or 1
	#method = char input: avoids string input, can branch according to ASCII nums
	print(promptCarrot)
	li $v0, 12
	syscall
	move $t0, $v0
	
	#error handling (if user doesn't choose 0 or 1)
	beq $t0, 48, plainText   # ASCII 48 = 0
	beq $t0, 49, cipherText  # ASCII 49 = 1
	beq $t0, 50, exit		 # ...
	ble $t0, 47, errorMode
	bge $t0, 51, errorMode
	
errorMode:
	#prompts error handling msg and sends back to main
	print(modeError)
	
	j main
	
plainText:
	#display plain prompt
	print(promptPlain)

	#takes string input
	inputStr(plainString, 500, $s0)
	
	j shift
	
cipherText:
	#display cipher prompt
	print(promptCipher)
	
	#takes string input
	inputStr(cipherString, 500, $s0)
	
	j shift
	
shift:
	#display shift prompt
	print(promptShift)
	
	#stores shift/key amount
	inputInt($s1)
	
	#init loop counter
	li $t1, 0
	
	#this is where jump would happen, example code but you can change
	beq $t0, 48, positiveShiftLoop
	beq $t0, 49, negativeShiftLoop
	
positiveShiftLoop:
	#code for positive shift to $s0 (dencrypted text)
	
	#get character by loading the byte (into $t2)
	lb $t2, 0($s0)
	
	#exit if the byte is exit ASCII (10 / LF / NL)
	beq $t2, 10, exit # ALAN you may wanna change this to jump to a costum output
				   	  # meant for decrypted -> encrypted text
	
	#perform POSITIVE shift on $t2
	#because $t2 is a pointer to the byte in $s0,
	#alterations to $t2 alters $s0
	getStart($t2, $s2) #stores starting point in $s2
	
	# Arithmetic for encryption
	add $t2, $t2, $s1			# Add current char value (stored in $t2) with shift value (stored in $s1)
	sub $t2, $t2, $s2			# Subtract shifted value (stored in $t2) by $s2 (upper/lower starting value)
	div $t2, $t2, 26			# Divide by 26 (num of letters in alphabet)
	mfhi $t2					# Remainder stored in $HI, move remainder to $t2
	add $t2, $t2, $s2			# Add $t2 by $2 (upper/lower starting value)
	
	sb $t2, 0($s0)
	
	#move to next character
	addi $s0, $s0, 1
	
	#loop
	j positiveShiftLoop

negativeShiftLoop:
	# code for negative shift to $s0 (encrypted text)
	
	#get character by loading the byte (into $t2)
	lb $t2, 0($s0)
	
	#exit if the byte is exit ASCII (10 / LF / NL)
	beq $t2, 10, exit # ALAN you may wanna change this to jump to a costum output
				   	  # meant for encrypted -> decrypted text
	
	#perform NEGATIVE shift on $t2
	#because $t2 is a pointer to the byte in $s0,
	#alterations to $t2 alters $s0
	getStart($t2, $s2) #stores starting point in $s2
	
	# Arithmetic for decryption
	sub $t2, $t2, $s1			# Subtract current encrypted value (stored in $t2) with shift value (stored in $s1)
	sub $t2, $t2, $s2			# Subtract decrypted value (stored in $t2) by $s2 (upper/lower starting value)
	div $t2, $t2, 26			# Divide by 26 (num of letters in alphabet)
	mfhi $t2					# Remainder stored in $HI, move remainder to $t2
	add $t2, $t2, $s2			# Add $t2 by $s2 (upper/lower starting value)
	
	sb $t2, 0($s0)
	
	#move to next character
	addi $s0, $s0, 1
	
	#loop
	j negativeShiftLoop

exit:
	#exit function
	print(cipherString)
	print(modeExit)
	li $v0, 10
	syscall
