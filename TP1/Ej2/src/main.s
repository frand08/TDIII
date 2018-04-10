%define	ROM_START_ADDRESS 0xFFF0

use16
inicio:
	mov eax,0xf000
	mov ds,eax
	push dword 0x26		; lo que ocupa td3_memcopy (num bytes)
	push dword td3_memcopy	; direccion origen
;	push dword 0x00000	; direccion destino (primer caso)
	push dword 0xf0000	; direccion destino (segundo caso)


	call dword td3_memcopy
	
	mov esp, [esp+8]
loop:
	nop
	jmp dword loop		; para que haga un loop infinito

td3_memcopy:
; pusheo los registros que voy a utilizar, y limpio los flags de interrupcion y direccion

	push ebp		; al entrar en la funcion guardo ebp
	mov ebp, esp		; y lo apunto a la pila

        push ecx
        push edi
        push esi
        cld                     ; pongo flag de direccion en 0


; realizo la copia

	mov edi, [ebp+8]	; edi contiene la direccion del primer argumento
        mov esi, [ebp+12]	; esi contiene la del segundo argumento
        mov ecx, [ebp+16]	; ecx se carga con el tercer argumento
        repnz movsb		; repnz: REPeat Not Zero.
                                ; movsb:
                                ;       [es:edi] <- [ds:esi]
                                ;       edi++, esi++ (si direction flag esta en 0)
				; 	edi--, esi-- (si direction flag esta en 1)
                                ;       ecx--
; popeo y retorno
        pop esi
        pop edi
        pop ecx
	pop ebp
	ret

; inicializo la ROM y salto al inicio

ROM:
        db 0x0                  ; define un byte que contiene 0x0
	%define CODESIZE ($-inicio)
				; para obtener la cantidad de bytes que hay desde aca hasta el inicio
	%define CODE ROM_START_ADDRESS-CODESIZE
				; obtiene la cantidad de bytes a reservar para que cli este en FFF0
        times CODE nop        	; reserva los bytes necesarios
        cli                     ; limpio los flags de interrupcion
	jmp dword inicio	; para aclarar que es jmpf, sino aparece
				; word data exceeds bounds [-w+number-overflow]

	align 16

