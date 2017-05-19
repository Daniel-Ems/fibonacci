.intel_syntax noprefix

ErrorStr:
	.asciz "Usage ./fibonacci <0-100>"
Arg:
	.asciz "number you passed %d\n"
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

	mov rcx, 0
1:
	cmp rcx, rax
	je 3f
2:
	inc rcx
	jmp 1b
3:
	sub rsp, 8
	mov rdi, OFFSET Arg
	mov rsi, rcx
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
