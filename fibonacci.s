.intel_syntax noprefix

ErrorStr:
	.asciz "Usage ./fibonacci <0-100>"
Arg:
	.asciz "number you passed Ox%lx%lx\n"
.globl main
main:
	cmp rdi, 2
	jne Error
	
	mov rdi, [rsi + 8]
	mov rsi, 0 
	mov rdx, 10
	sub rsp, 8
	call strtol
	add rsp, 8

	cmp rax, 0
	cmove rdx, rax
	je 3f

	cmp rax, 1
	cmove rdx, rax
	je 3f

	xor r11, r11
	xor r14, r14
	mov rcx, 1
	mov rdx, 1
	mov rbx, 1
1:
	cmp rcx, rax
	je 3f
2:
	inc rcx
	xadd rbx, rdx
	adc r11, r14
	xchg r14, r11
	#xchg rbx, rdx
	jmp 1b
3:
	sub rsp, 8
	mov rdi, OFFSET Arg
	mov rsi, r11
	mov rdx, rdx
	call printf
	add rsp, 8 
	ret

Exit:
	
	xor eax, eax
	ret

Error:
	mov rdi, OFFSET ErrorStr
	call puts
	mov eax, 1
