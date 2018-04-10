%define	ROM_START_ADDRESS 0xFFF0

use16
inicio:
   mov ax,0x00F0
   mov ss,ax
   mov eax,0xFFFF
   mov esp,eax             ; en la direccion pedida en clase,
                           ; 0xF000:0xFFFF (ss:sp), hay un problema
                           ; con el memcopy que copia en 0x000F (parte
                           ; alta), por lo que se modifico para que no
                           ; ocurra dicho problema 
	push dword 0x10000      ; lo que ocupa (64k)
	push dword 0x0000	      ; direccion origen
	push dword 0x00000	   ; direccion destino (primer caso)
;	push dword 0xf0000	   ; direccion destino (segundo caso)


	call dword td3_memcopy
	
	mov esp, [esp+8]
loop:
	nop
	jmp dword loop		      ; para que haga un loop infinito

td3_memcopy:
; pusheo los registros que voy a utilizar, y limpio el flag direccion

	push ebp		            ; al entrar en la funcion guardo ebp
	mov ebp, esp		      ; y lo apunto a la pila

	push eax
   push ecx
   push edi
   push esi
   cld                     ; pongo flag de direccion en 0


; realizo la copia
	mov eax,0xf000
	mov ds,eax		         ; como cs:ip cuenta con los 3 MSB en F, para indicar que
				               ; quiero copiar desde la direccion 0xFFFFXXXX, debo primero
				               ; hacer que DS = 0xF000, cosa de que 0xF000*0x10+XXXX = FXXXX
	mov edi, [ebp+8]	      ; edi contiene la direccion del primer argumento
   mov esi, [ebp+12]	      ; esi contiene la del segundo argumento
;   mov ecx,0x1            ; sin estas dos lineas me
;   rep movsb              ; copia hasta 65535
   mov ecx, [ebp+16]       ; ecx se carga con el tercer argumento
;   inc ecx
   a32 repnz movsb		   ; a32: para que me deje 64k en vez de 64k-1
                           ; repnz: REPeat Not Zero.
                           ; movsb:
                           ;       [es:edi] <- [ds:esi]
                           ;       edi++, esi++ (si direction flag esta en 0)
				               ; 	edi--, esi-- (si direction flag esta en 1)
                           ;       ecx--
; popeo y retorno
   pop esi
   pop edi
   pop ecx
	pop eax
	pop ebp
	ret

; inicializo la ROM y salto al inicio

        db 0x0             ; define un byte que contiene 0x0
	%define CODESIZE ($-inicio)
				               ; para obtener la cantidad de bytes que hay desde aca 
                           ; hasta el inicio
	%define CODE ROM_START_ADDRESS-CODESIZE
				               ; obtiene la cantidad de bytes a reservar para que 
                           ; cli este en FFF0
   times CODE nop          ; reserva los bytes necesarios
   cli                     ; limpio los flags de interrupcion
	jmp dword inicio	      ; para aclarar que es jmpf, sino aparece
				               ; word data exceeds bounds [-w+number-overflow]

	align 16

