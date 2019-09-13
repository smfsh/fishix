bits 32 ; Operating in 32 bit space
extern main ; Tell compiler to find symbols we need from main.o
call main ; Execute main kernel function
jmp $ ; Hangout here til we quit