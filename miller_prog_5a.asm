TITLE Program 5A    (miller_prog_5a.asm)

; Author:		Jared Miller
; Last Modified:	August 13, 2019
; OSU email address: millejar@oregonstate.edu
; Course number/section:	271-400
; Assignment Number:  5A              Due Date: August 11, 2019
; Description: This program implements and tests ReadVal and WriteVal procedures for unsigned integers.
; The ReadVal procedure will accept a numberic string input and computes the corresponding integer value.
; The program will get 10 validated integers from the user and stores the numberic values into an array.
; The program will then display the list of integers, their sum, and the average value of the list. The
; sum and the average will be written to the console as strings using the WriteVal procedure, which takes
; a 32-bit unsigned integer and computes the corresponding ASCII representation. 

INCLUDE Irvine32.inc

;constants
MAX = 21

;MACROs
displayString	MACRO 	buffer
	push 	edx					;save edx
	mov 	edx, buffer			;offset of buffer in edx
	call 	WriteString			;call WriteString
	pop 	edx					;restore edx
ENDM

getString			MACRO 	buffer, stringInput, characters
	push	eax
	push	ecx
	push	edx
	displayString	buffer	;Display prompt
	mov 	edx, stringInput 	;offset of stringInput in edx
	mov 	ecx, MAX
	call 	ReadString			;get user input 							
	mov 	[characters], eax	;put number of characters into charCount	
	pop		edx
	pop		ecx
	pop		eax
ENDM


.data
	input 		BYTE		MAX		DUP(0)		;holds string input
	charCount	DWORD 		? 					;number of digits in input
	intArray 	DWORD 		10 		DUP(?)		;array of integer values
	intValue 	DWORD 		?					;an integer value
	output 		BYTE 		MAX 	DUP(0) 		;holds string output

	title1		BYTE 		"Demonstrating low-level I/O procedures", 0
	title2		BYTE 		"By Jared Miller", 0
	intro1		BYTE 		"Please provide 10 decimal integers.", 0
	intro2		BYTE 		"Each integer must be small enough to fit inside a 32 bit register.", 0
	intro3		BYTE 		"After you have finished inputting the raw numbers I will display a list", 0
	intro4 		BYTE 		"  of the integers, their sum, and their average value.", 0
	prompt		BYTE 		"Please enter an integer number: ", 0
	error1		BYTE 		"ERROR: You did not enter an integer number or your number was too big.", 0
	error2		BYTE 		"Please try again: ", 0
	result1		BYTE 		"You entered the following numbers: ", 0
	spacer 		BYTE		", ", 0
	result2		BYTE 		"The sum of these numbers is: ", 0
	result3		BYTE	 	"The average is: ", 0
	closing		BYTE 		"Thanks for using this program. Goodbye.", 0

.code
main PROC
	;introduce the program to the user
	call 		introduction

	;get user input
	push 		OFFSET input 	
	push 		OFFSET intArray	
	push 		OFFSET charCount
	push 		OFFSET intValue 	
	call 		getInput

	;display the numbers
	push 		OFFSET intArray
	call 		displayNumbers

	;display the sum
	push 		OFFSET output
	push 		OFFSET intValue
	push 		OFFSET intArray
	call 		displaySum

	;display the average
	push 		OFFSET output
	push 		OFFSET intValue
	push 		OFFSET intArray
	call 		displayAverage

	;display closing message
	call 		goodbye

	exit	; exit to operating system
main ENDP

;Procedure to introduce the program to the user. 
;receives: 				none
;returns: 				none
;preconditions: 		none
;postconditions: 		Intro messages are displayed to the console. 
;registers changed: 	edx
introduction PROC
	displayString	OFFSET title1		;Display title1
	call CrLf
	displayString 	OFFSET title2		;Display title2
	call 	CrLf
	call 	CrLf
	displayString	OFFSET intro1		;Display intro1
	call 	CrLf
	displayString 	OFFSET intro2		;Dipslay intro2
	call 	CrLf
	displayString 	OFFSET intro3		;Display intro3
	call 	CrLf
	displayString	OFFSET intro4		;Display intro4
	call 	CrLf
	call 	CrLf		
	ret
introduction ENDP

;Procedure to get user input and put it into an array. The procedure uses
; the readVal proc to get 10 valid integers and puts them into an array.  
;receives: 				input (offset), intArray(offset), charCount(offset), intValue(offset)
;returns: 				intArray
;preconditions: 		none
;postconditions: 		intArray is filled with 10 integers 
;registers changed: 	eax, ebx, ecx, edx, esi, ebp 
getInput 	PROC 
	push 	ebp						;set up stack frame
	mov 	ebp, esp
	push 	ecx 					;save registers
	push 	ebx
	push 	esi
	push 	eax
	push 	edx

	mov 	ecx, 10					;set counter to 10
	mov 	ebx, 0					;additional offset of each element
	mov 	esi, [ebp+16]			;offset of intArray in esi
getInput1:
	;call readVal
	push 	[ebp+20]				;push offset of input
	push 	[ebp+12]				;push charCount
	push 	[ebp+8]					;push intValue
	call 	readVal					;get a number (converted from string to int) from user
	;put value into array
	
	mov 	eax, [ebp+8]			;move intValue into the array
	mov 	edx, [eax]
	mov 	[esi+ebx], edx
	add 	ebx, 4					;move to the next element
	loop 	getInput1

	pop 	edx						;restore registers
	pop 	eax						
	pop 	esi						
	pop 	ebx
	pop 	ecx
	pop 	ebp
	ret		16
getInput 	ENDP

;Procedure to read a string from the keyboard and compute the corresponding integer value. If the 
; value is not an integer or is too big, it will be rejected.   
;receives: 				intValue(offset), charCount(offset), input(offset)
;returns: 				intValue
;preconditions: 		none
;postconditions: 		intValue contains a valid integer 
;registers changed: 	eax, ebx, ecx, edx, esi, edi
readVal 	PROC 
	push 	ebp						;set up stack frame
	mov 	ebp, esp 				
	push 	eax						;save registers
	push 	ebx
	push	ecx
	push 	edx
	push 	esi
	push 	edi

	getString  OFFSET prompt, [ebp+16], [ebp+12]		;Get user input into memory (pass offset of prompt,
															; offset of input, offset of charCount)
readVal1:
	mov		esi, [ebp+16]			;offset of input in esi
	cld 							;clear direction flag (move forwards)
	mov 	ecx, [ebp+12]			;loop counter set to charCount
	mov 	edx, 0	
readVal2: 
	mov		eax, 0					;clear out the eax register
	lodsb							;load [esi] into al subregistre
	cmp 	eax, 48					;check for out of bounds characters
	jl 		readVal4				;error if less than 48
	cmp 	eax, 57
	jg 		readVal4				;error if greater than 57

	sub 	eax, 48					;eax - 48
	push 	eax
	mov 	eax, edx
	mov		edi, 10
	mul 	edi						;multiply by 10
	jc 		readVal3				;if the carry flag is set, overflow has occured (number too large), go to error section
	mov 	ebx, eax
	pop 	eax
	add 	eax, ebx 				;x = 10*x + (str[k]-48)
	add 	edx, eax 				;dl is the accumulator
	jc		readVal4				;if the carry flag is set, overflow has occured (number too large), go to error section
	loop 	readVal2

	push 	eax 
	mov 	eax, [ebp+8]
	mov 	[eax], edx 				;move the integer value into intVal
	pop 	eax 
	jmp 	readVal5

readVal3:
	pop 	eax
readVal4: 							;error section
	call 	CrLf
	displayString 	OFFSET error1	;display error message
	call 	CrLf
	;get user input
	getString 		OFFSET error2,  [ebp+16], [ebp+12]					
	jmp 	readVal1

readVal5: 
	pop 	edi						;restore registers
	pop	 	esi
	pop 	edx
	pop		ecx
	pop 	ebx
	pop 	eax				
	pop		ebp						;restore stack
	ret		12
readVal 	ENDP

;Procedure to convert a 32-bit unsigned integer to a numeric string and display that string to 
; the console. 
;receives: 				intValue(offset), output(offset)
;returns: 				none
;preconditions: 		intValue contains a 32-bit unsigned integer
;postconditions: 		The converted string is displayed to the console.
;registers changed: 	eax, ebx, ecx, edx, edi, esi 
writeVal	PROC
	push 	ebp 					;set up stack frame
	mov 	ebp, esp
	push 	eax
	push 	ebx
	push 	ecx
	push 	edx
	push 	edi
	push 	esi

;determine the number of digits in the number
	mov 	eax, [ebp+8] 			;eax holds the intValue
	mov 	ecx, 10
	mov 	esi, 1
writeVal00:
	mov 	edx, 0
	div 	ecx						;keep dividing by 10 until eax becomes 0
	cmp 	eax, 0
	je 		writeVal0
	inc 	esi
	jmp 	writeVal00
writeVal0:
	;esi now holds the number of digits (charCount)
;convert the int value into a string value

	mov 	edi, [ebp+12]			;offset of output
	mov 	ecx, esi				;put charCount (number of digits) into ecx counter
	mov 	ebx, [ebp+8]			;ebx holds the intValue
	cld 							;clear direction flag - edi will be incremented
	
	;write the char representations to the string, one at a time
writeVal1: 
	mov 	edx, ecx				;put charCount in edx
	dec 	edx						;charCount - 1
	mov 	eax, 1
	mov 	esi, 10
	cmp		edx, 0
	je 		writeVal3
writeVal2:
	;divide the number by 10^(charCount-n)
	push	edx
	mul 	esi 
	pop		edx
	dec 	edx 
	cmp 	edx, 0
	jg 		writeVAl2
writeVal3:
	mov 	esi, eax				;number to divide the integer by
	mov 	eax, ebx				
	mov 	edx, 0
	div 	esi 					;divide integer by a power of 10
	add 	eax, 48					;add 48 to get integer representation
	stosb 							;store the char and increment edi
	sub 	eax, 48
	mul 	esi 					;find the number to subtract the integer by to eliminate the highest digit
									; 	(e.g. 5824 - 5000 = 824)
	sub 	ebx, eax 				;subtract the integer by the power of 10 
	loop 	writeVal1				;decrement charCount and loop 
	;write a null byte
	mov 	eax, 0
	stosb

	;write the string
	displayString	[ebp+12]

	pop 	esi						;restore registers
	pop 	edi
	pop 	edx
	pop 	ecx
	pop 	ebx
	pop 	eax
	pop 	ebp
	ret		8
writeVal 	ENDP

;Procedure to list the integers in the array. 
;receives: 				intArray(offset)
;returns: 				none
;preconditions: 		intArray is filled with valid integers
;postconditions: 		The 10 integers of the array are displayed to the console.
;registers changed: 	eax, ebx, ecx, esi
displayNumbers PROC
	push 	ebp 					;set up stack frame
	mov 	ebp, esp
	push 	eax						;save registers
	push 	ebx
	push 	ecx
	push 	esi

	displayString OFFSET result1
	mov 	esi, [ebp+8]			;offset of array
	mov 	ecx, 10					;loop counter
	mov 	ebx, 0					;offset of elements
	call 	CrLf
displayNumbers1:
	mov 	eax, [esi+ebx]			;display current element
	call 	WriteDec
	cmp 	ecx, 1
	je 		displayNumbers2			;don't print a comma after the final number
	displayString OFFSET spacer	;display ", "
displayNumbers2:
	add 	ebx, 4					;go to next element
	loop 	displayNumbers1

	pop 	esi						;restore registers
	pop 	ecx
	pop 	ebx
	pop 	eax
	pop 	ebp
	ret 	4
displayNumbers ENDP

;Procedure to calculate and display the sum of the values of the array.  
;receives: 				intArray(offset), intValue(offset), output(offset)
;returns: 				none
;preconditions: 		intArray contains 10 valid integers
;postconditions: 		The sum is displayed to the console.  
;registers changed: 	eax. ebx. ecx. eso
displaySum PROC
	push 	ebp						;set up stack frame
	mov 	ebp, esp
	push 	eax 					;save registers
	push 	ebx
	push 	ecx
	push 	esi
	mov 	esi, [ebp+8] 			;offset of array in esi
	mov 	ecx, 10					;loop counter
	mov 	ebx, 0					;offset of elements
	mov 	eax, 0					;accumulator
displaySum1:
	add 	eax, [esi+ebx]			;add current element value to accumulator
	add 	ebx, 4					;move to the next element
	loop 	displaySum1

	mov 	[ebp+12], eax			;move the sum into intValue
	call 	CrLf
	call 	CrLf
	displayString	OFFSET 	result2
	push 	[ebp+16]				;push offset of output
	push 	[ebp+12]				;push intValue
	call 	writeVal				;write the string
	call 	CrLf

	pop 	esi						;restore registers
	pop 	ecx
	pop 	ebx
	pop 	eax
	pop 	ebp
	ret 	12
displaySum ENDP

;Procedure to calculate and the display the aveage of the values of the 
;	array. 
;receives: 				intArray(offset), intValue(offset), output(offset)
;returns: 				none
;preconditions: 		intArray contains 10 valid integers
;postconditions: 		The average of the values is displayed to the console. 
;registers changed: 	eax, ebx, ecx, edx, esi
displayAverage PROC
	push 	ebp						;set up stack frame
	mov 	ebp, esp
	push 	esi						;save registers
	push 	eax
	push 	ebx
	push 	ecx
	push 	edx
	mov 	esi, [ebp+8]			;offset of intArray
	mov 	eax, 0					;accumulator
	mov 	ebx, 0					;offset of elements
	mov 	ecx, 10					;loop counter
displayAverage1: 
	add 	eax, [esi+ebx]			;add current element value to accumulator
	add 	ebx, 4
	loop 	displayAverage1
	mov 	edx, 0					;preload 0 into edx
	mov 	ebx, 10
	div 	ebx						;divide total by 10 to get the average

	mov 	[ebp+12], eax			;move the average into intValue
	call 	CrLf
	displayString 	OFFSET 	result3

	push 	[ebp+16]				;push offset of output
	push 	[ebp+12]				;push intValue
	call 	writeVal
	call 	CrLf

	pop 	edx						;restore registers
	pop 	ecx
	pop 	ebx
	pop 	eax
	pop 	esi
	pop 	ebp
	ret 	12
displayAverage ENDP

;Procedure to display a closing message. 
;receives: 				none
;returns: 				none
;preconditions: 		none
;postconditions: 		A closing message is displayed to the console. 
;registers changed: 	edx
goodbye 	PROC
	call 	CrLf
	displayString 	OFFSET closing	;display closing message
	ret
goodbye 	ENDP

END main
