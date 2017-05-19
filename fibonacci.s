.intel_syntax noprefix

ErrorStr:
	.asciz "Usage ./fibonacci <0-100>"
Arg:
	.asciz "0x%lx%lx\n"
.globl main
main:
	cmp rdi, 2		#User must supply exactly 1 cmd line arg
	jne Error		
	
	sub rsp, 8		#Create a space on stack for strtol err., and byte align for function call
	mov rdi, [rsi + 8]	#Set cmd line arg as first arg for strtol
	mov rsi, rsp 		#Set pointer created earlier as second arg for strtol
	mov rdx, 10		#Set the number base for strtol
	call strtol

	mov rbx, [rsp]		#Move any errors off the stack
	add rsp, 8		#Rewind the stack

	cmp BYTE PTR[rbx], 0	#User must supply number only
	jne Error

	cmp rax, 0		#User must supply a positive value			
	jl Error	

	xor r11, r11		#Ensure registers are set to 0 if never used
	xor r14, r14		

	cmp rax, 0		#f0 is hardcoded
	cmove rdx, rax	
	je Print

	mov rcx, 0		#Counter starts at zero
	mov rdx, 1		#Value initialized to start calculating at f2. f0, f1 are hardcoded.	
	mov rbx, 0		#Value initialized to start calculating at f2. f0, f1 are hardcoded.

Fibonacci:			#Loop will run until counter is equal to the cmd line arg.

	xadd rbx, rdx		#Switch then add, allow for incrementing fibonacci sequence accurately

	adc r11, r14		#Overflow registers rbx:r11, rdx:r14
	xchg r14, r11		#Over flow registers must follow add registers

	cmp rcx, rax		#Compare counter to cmd arg,  
	je Print		#Jump to print
	inc rcx
	jmp Fibonacci

Print:

	sub rsp, 8		#Align stack for printf
	mov rdi, OFFSET Arg	#Set the first argument for printf
	mov rsi, r11		#Not used if user cmd line arg == 0
	mov rdx, rdx		#Set the second argument for printf
	call printf
	add rsp, 8 		#rewind the stack

Exit:
	
	xor eax, eax		#Set eax to 0 for normal exit
	ret

Error:				#Exit on error

	mov rdi, OFFSET ErrorStr
	call puts
	mov eax, 1
