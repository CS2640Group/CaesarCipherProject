# Jaron Lin, Jonah Lysne, Alan Mong, Timothy Lee
# Project Topic: Caesar Cipher
# Description: The Caesar cipher is a encrpytion technique (more specifically a substitution cipher)
# it takes a "shift" or "key" and then moves each letter with a fixed number of positions down the alphabet


.data
promptMode: .asciiz "\n================================================\n Caesar Cipher\n Please choose one of the following modes:\n Encryption (0)\n Decryption (1)\n================================================\n"
promptPlain: .asciiz "\nPlease enter your plain text (in lowercase, max 500 chars): "
plainString: .space 500
promptCipher: .asciiz "\nPlease enter your cipher text (in uppercase, max 500 chars): "
cipherString: .space 500
promptShift: .asciiz "Please enter your shift: "
modeError: .asciiz "\nThere was an error in your input. Please choose 1 or 2."

#can change amount of chars/newline spacing later if we want

.text
main:
	#display mode prompt
	li $v0, 4
	la $a0, promptMode
	syscall
	
	#store if user inputs 0 or 1
	li $v0, 5
	syscall
	move $t0, $v0
	
	#error handling (if user doesn't choose 0 or 1)
	beq $t0, 0, plainText
	beq $t0, 1, cipherText
	blt $t0, 0, errorMode
	bge $t0, 2, errorMode
	
errorMode:
	#prompts error handling msg and sends back to main
	li $v0, 4
	la $a0, modeError 
	syscall
	
	j main
	
plainText:
	#display plain prompt
	li $v0, 4
	la $a0, promptPlain
	syscall
	
	#takes string input
	li $v0, 8
	la $a0, plainString
	li $a1, 99
	move $s0, $a0
	syscall
	
	j shift
	
cipherText:
	#display cipher prompt
	li $v0, 4
	la $a0, promptCipher
	syscall
	
	#takes string input
	li $v0, 8
	la $a0, cipherString
	li $a1, 99
	move $s1, $a0
	syscall
	
	j shift
	
shift:
	#display shift prompt
	li $v0, 4
	la $a0, promptShift
	syscall
	
	#stores shift/key amount
	li $v0, 5
	syscall
	move $s2, $v0
	
	# this is where jump would happen, example code but you can change
	# beq $t0, 0, toUpper
	# beq $t0, 1, toLower
	
exit:
	#exit function
	li $v0, 10
	syscall
	