.intel_syntax noprefix

ErrorStr:			#Format string to fprintf error message
	.asciz "Usage: %s <0-300>\n"

Arg:				#Format string to printf 
	.asciz "0x%04lX%016lX%016lX%016lX\n"

.globl main
main:

	push [rsi]		#Store name of program on stack

	cmp rdi, 2		#User must supply exactly 1 cmd line arg
	jne Error		
	
	sub rsp, 16		#Create a space on stack for strtol err., and byte align for function call
	mov rdi, [rsi + 8]	#Set cmd line arg as first arg for strtol
	mov rsi, rsp 		#Set pointer created earlier as second arg for strtol
	mov rdx, 10		#Set the number base for strtol
	call strtol

	mov rbx, [rsp]		#Move any errors off the stack
	add rsp, 16		#Rewind the stack

	cmp BYTE PTR[rbx], 0	#User must supply number only
	jne Error

	cmp rax, 0		#User must supply a positive value			
	jl Error	

	cmp rax, 300		#User must supply a value less than 300
	jg Error

	xor r9, r9		#Ensure overflow registers are set to 0 if never used
	xor r10, r10
	xor r11, r11	
	xor r12, r12		
	xor r13, r13
	xor r14, r14

	cmp rax, 0		#f0 is hardcoded
	cmove rdx, rax	
	je Print

	mov rbx, rax		#Free up rax register for math operations
	mov rcx, 0		#Counter starts at zero
	mov rdx, 1		#Value initialized to start calculating at f2. f0, f1 are hardcoded.	
	mov rax, 0		#Value initialized to start calculating at f2. f0, f1 are hardcoded.

Fibonacci:			#Loop will run until counter is equal to the cmd line arg.

	xadd rax, rdx		#Switch then add, allow for incrementing fibonacci sequence accurately

	adc r9, r10		#Overflow registers must reflect the position of their add registers
	adc r11, r12	
	adc r13, r14
	
	xchg r10, r9		#Over flow registers must reflect the position of thier add registers
	xchg r12, r11		
	xchg r14, r13

	cmp rcx, rbx		#Compare counter to cmd arg,  
	je Print		#Jump to print if count == cmd line arg
	inc rcx			#increment counter if not equal
	jmp Fibonacci		#continue loop

Print:

	mov r10, rdx		#Store rdx value so you can use for argument assignment
	mov rdi, OFFSET Arg	#Set the first argument for printf
	mov rsi, r13		#Used if rdx and rax overflow
	mov rdx, r11		#Used if r13 overflows
	mov rcx, r9		#USed if r11 overflows
	mov r8, r10		#Used if r10 overflows
	call printf
	pop rbx

Exit:
	
	xor eax, eax		#Set eax to 0 for normal exit
	ret

Error:				#Exit on error
	mov rdi, stderr
	mov rsi, OFFSET ErrorStr
	mov rdx, [rsp]
	call fprintf
	pop rbx
	mov eax, 1
	ret
