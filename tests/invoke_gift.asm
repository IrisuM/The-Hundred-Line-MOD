option casemap:none
.code
InvokeGift PROC FRAME
    push rbp
    .pushreg rbp
    push r14
    .pushreg r14
    sub rsp, 28h
    .allocstack 28h
    .endprolog
    mov r14, rdx
    mov rbp, r8
    mov eax, r9d
    call rcx
    add rsp, 28h
    pop r14
    pop rbp
    ret
InvokeGift ENDP
END
