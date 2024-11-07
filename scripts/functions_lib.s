  .section .data
MEM_FD:         .asciz   "/dev/mem"
FPGA_BRIDGE:    .word    0xff200
HW_REGS_SPAN:   .word    0x1000
ADDRESS_MAPPED:  .space   4
ADDRESS_FD:      .space   4
dataA:          .word    0x80
dataB:          .word    0x70
WRREG:          .word    0xc0
mensagem:       .asciz   "erro\n"

  .section .text

  @definicao das funcoes
  .global memory_map
  .type memory_map, %function

  .global memory_unmap
  .type memory_unmap, %function
  
  .global key_read
  .type key_read, %function
  
  .global draw_triangle
  .type draw_triangle, %function
  
  .global hexs
  .type hexs, %function

  .global clear_dp_memory
  .type clear_dp_memory, %function

  .global clear_dp_from_vga
  .type clear_dp_from_vga, %function

  .global wbm
  .global wbm, %function

  .global set_sprite
  .type set_sprite, %function   

  .global set_background_color
  .type set_background_color, %function 

  .global set_background_block
  .type set_background_block, %function

  .global WSM
  .type WSM, %function


@\brief: mapeia a memoria
memory_map:
  @salva os valores dos registradores na pilha
  sub sp, sp, #28         @reserva 28 bytes na pilha
  str r1, [sp, #24]
  str r2, [sp, #20]
  str r3, [sp, #16]
  str r4, [sp, #12]
  str r5, [sp, #8]
  str r7, [sp, #4]
  str r0, [sp, #0]

  @abre o arquivo de memoria
  mov r7, #5              @syscall open
  ldr r0, =MEM_FD         @caminho do arquivo
  mov r1, #2              @modo leitura e escrita
  mov r2, #0              @sem flags
  svc 0                   @chama o sistema para executar

  ldr r1, =ADDRESS_FD
  str r0, [r1]
  mov r4, r0              @guarda em r4

  @configura o mmap
  mov r7, #192            @syscall do mmap2
  mov r0, #0              @kernel decide o endereço
  ldr r1, =HW_REGS_SPAN   @tamanho da pagina
  ldr r1, [r1]

  mov r2, #3              @modo leitura/escrita
  mov r3, #1              @compartilha com os processos
  ldr r5, =FPGA_BRIDGE    @carrega o endereco base
  ldr r5, [r5]            @carrega o endereco real (igual um ponteiro)
  svc 0                   @chama o sistema para executar
  
  ldr r1, =ADDRESS_MAPPED  @endereco e carregado aqui
  str r0, [r1]
  
  @carrega o valor dos registradores de volta
  ldr r1, [sp, #24]
  ldr r2, [sp, #20]
  ldr r3, [sp, #16]
  ldr r4, [sp, #12]
  ldr r5, [sp, #8]
  ldr r7, [sp, #4]
  ldr r0, [sp, #0]
  add sp, sp, #28         @reseta a pilha
  
  bx lr

@\brief: desmapeia a memoria e fecha o arquivo /dev/mem
memory_unmap:
  @salva o valor dos registradores na pilha
  sub sp, sp, #12
  str r0, [sp, #8]
  str r1, [sp, #4]
  str r7, [sp, #0]

  ldr r0, =ADDRESS_MAPPED
  ldr r0, [r0]
  mov r1, #4096           @tamanho da página mapeada
  mov r7, #91             @system call: munmap
  svc 0
  
  ldr r0, =ADDRESS_FD
  ldr r0, [r0]
  mov r7, #6              @system call: close
  svc 0
  
  @carrega o valor dos registradores da pilha
  ldr r0, [sp, #8]
  ldr r1, [sp, #4]
  ldr r7, [sp, #0]

  add sp, sp, #12

  bx lr

@\brief: le o valor dos botoes
@\param[in]: null
@\return: a soma do valor dos botoes pressionados
key_read: 
  @salva na pilha
  sub sp, sp, #4 
  str r1, [sp, #0]

  @le o valor do botao 
  ldr r1, =ADDRESS_MAPPED
  ldr r1, [r1]
  ldr r0, [r1, #0x0]          @le o valor no endereco dos botoes
  
  sub r0, r0, #15             @como o valor presente é 15, aqui vai zerar e dizer o botão que está sendo apertado

  @carrega da pilha
  ldr r1, [sp, #0]
  add sp, sp, #4 

  bx lr

@\brief: desenha triangulo 
@\param[in]: r0-cor
@\param[in]: r1-tamanho
@\param[in]: r2-posicao x
@\param[in]: r3-posicao y
@\param[in]: r4-endereco
@\return: null
draw_triangle: 
  @analisando aqui agora, nao faz muito sentido, nesse caso, salvar esses valores na pilha
  @ Salva os registradores na pilha
  ldr r4, [sp, #0]           @ Carrega `endereco` da pilha (quinto argumento)
  sub sp, sp, #28
  str r0, [sp, #24]          @ Salva `cor`
  str r1, [sp, #20]          @ Salva `tamanho`
  str r2, [sp, #16]          @ Salva `posX`
  str r3, [sp, #12]          @ Salva `posY`
  str r4, [sp, #8]           @ Salva `endereco`

  @ Zera o sinal de start
  mov r0, #0
  ldr r1, =ADDRESS_MAPPED
  ldr r1, [r1]
  str r0, [r1, #0xc0]

  @ Configuração de dataA
  mov r0, #0b0011            @ opcode
  lsl r4, r4, #4             @ Desloca endereco 4 bits à esquerda
  add r4, r4, r0             @ Adiciona o opcode a endereco 
  ldr r3, =ADDRESS_MAPPED
  ldr r3, [r3]
  str r4, [r3, #0x80]        @ Armazena `dataA` no endereço mapeado

  @ Configuração de dataB
  mov r0, #1                 @ Tipo: 0 - quadrado, 1 - triângulo
  lsl r0, r0, #31            @ Desloca `tipo` para o bit 31
  ldr r1, [sp, #24]          @ Carrega `cor`
  lsl r1, r1, #22            @ Desloca `cor`
  add r0, r0, r1             @ Junta `tipo` e `cor`

  ldr r2, [sp, #20]          @ Carrega `tamanho`
  lsl r2, r2, #18            @ Desloca `tamanho`
  add r0, r0, r2             @ Junta `tamanho`

  ldr r3, [sp, #12]          @ Carrega `posY`
  lsl r3, r3, #9             @ Desloca `posY`
  add r0, r0, r3             @ Junta `posY`

  ldr r4, [sp, #16]          @ Carrega `posX`
  add r0, r0, r4             @ Junta `posX`

  ldr r6, =ADDRESS_MAPPED
  ldr r6, [r6]
  str r0, [r6, #0x70]        @ Armazena `dataB` no endereço mapeado

  @ Sinal positivo para WRREG
  mov r0, #1
  ldr r1, =ADDRESS_MAPPED
  ldr r1, [r1]
  str r0, [r1, #0xc0]        @ Atualiza WRREG para sinal positivo
  
  @ Restaura os valores dos registradores
  ldr r0, [sp, #24]          @ Restaura `cor`
  ldr r1, [sp, #20]          @ Restaura `tamanho`
  ldr r2, [sp, #16]          @ Restaura `posX`
  ldr r3, [sp, #12]          @ Restaura `posY`
  ldr r4, [sp, #8]           @ Restaura `endereco`
  add sp, sp, #28            @ Libera o espaço da pilha

  bx lr

@\brief: desenha quadrado 
@\param[in]: r0-cor
@\param[in]: r1-tamanho
@\param[in]: r2-posicao x
@\param[in]: r3-posicao y
@\param[in]: r4-endereco
@\return: null
draw_square: 
  @analisando aqui agora, nao faz muito sentido, nesse caso, salvar esses valores na pilha
  @ Salva os registradores na pilha
  ldr r4, [sp, #0]           @ Carrega `endereco` da pilha (quinto argumento)
  sub sp, sp, #20
  str r0, [sp, #16]          @ Salva `cor`
  str r1, [sp, #12]          @ Salva `tamanho`
  str r2, [sp, #8]          @ Salva `posX`
  str r3, [sp, #4]          @ Salva `posY`
  str r4, [sp, #0]           @ Salva `endereco`

  @ Zera o sinal de start
  mov r0, #0
  ldr r1, =ADDRESS_MAPPED
  ldr r1, [r1]
  str r0, [r1, #0xc0]

  @ Configuração de dataA
  mov r0, #0b0011            @ opcode
  lsl r4, r4, #4             @ Desloca endereco 4 bits à esquerda
  add r4, r4, r0             @ Adiciona o opcode a endereco 
  ldr r3, =ADDRESS_MAPPED
  ldr r3, [r3]
  str r4, [r3, #0x80]        @ Armazena `dataA` no endereço mapeado

  @ Configuração de dataB
  mov r0, #1                 @ Tipo: 0 - quadrado, 1 - triângulo
  lsl r0, r0, #31            @ Desloca `tipo` para o bit 31
  ldr r1, [sp, #24]          @ Carrega `cor`
  lsl r1, r1, #22            @ Desloca `cor`
  add r0, r0, r1             @ Junta `tipo` e `cor`

  ldr r2, [sp, #20]          @ Carrega `tamanho`
  lsl r2, r2, #18            @ Desloca `tamanho`
  add r0, r0, r2             @ Junta `tamanho`

  ldr r3, [sp, #12]          @ Carrega `posY`
  lsl r3, r3, #9             @ Desloca `posY`
  add r0, r0, r3             @ Junta `posY`

  ldr r4, [sp, #16]          @ Carrega `posX`
  add r0, r0, r4             @ Junta `posX`

  ldr r6, =ADDRESS_MAPPED
  ldr r6, [r6]
  str r0, [r6, #0x70]        @ Armazena `dataB` no endereço mapeado

  @ Sinal positivo para WRREG
  mov r0, #1
  ldr r1, =ADDRESS_MAPPED
  ldr r1, [r1]
  str r0, [r1, #0xc0]        @ Atualiza WRREG para sinal positivo
  
  @ Restaura os valores dos registradores
  ldr r0, [sp, #24]          @ Restaura `cor`
  ldr r1, [sp, #20]          @ Restaura `tamanho`
  ldr r2, [sp, #16]          @ Restaura `posX`
  ldr r3, [sp, #12]          @ Restaura `posY`
  ldr r4, [sp, #8]           @ Restaura `endereco`
  add sp, sp, #28            @ Libera o espaço da pilha

  bx lr

@\brief: desenha quadrado 
@\param[in]: r0-cor
@\param[in]: r1-endereco
@\return: null
wbm:
  @ Salva os registradores na pilha
  sub sp, sp, #8
  str r0, [sp, #0]          @ Salva `cor`
  str r1, [sp, #4]          @ Salva `endereco`

  @ Zera o sinal de start
  mov r0, #0
  ldr r1, =ADDRESS_MAPPED
  ldr r1, [r1]
  str r0, [r1, #0xc0]

  @ Configuração de dataA
  mov r0, #0b0010          @ opcode
  ldr r1, [sp, #4]           @ carrega o endereco em r1
  lsl r1, r1, #4             @ Desloca endereco 4 bits à esquerda
  add r1, r1, r0             @ Adiciona o opcode a endereco 
  ldr r2, =ADDRESS_MAPPED
  ldr r2, [r2]
  str r1, [r2, #0x80]        @ Armazena `dataA` no endereço mapeado

  @ Configuração de dataB
  ldr r0, [sp, #0]

  ldr r1, =ADDRESS_MAPPED
  ldr r1, [r1]
  str r0, [r1, #0x70]        @ Armazena `dataB` no endereço mapeado

  @ Sinal positivo para WRREG
  mov r0, #1
  ldr r1, =ADDRESS_MAPPED
  ldr r1, [r1]
  str r0, [r1, #0xc0]        @ Atualiza WRREG para sinal positivo
  
  @ Restaura os valores dos registradores
  ldr r0, [sp, #0]          @ Restaura `cor`
  ldr r1, [sp, #4]          @ Restaura `tamanho`
  add sp, sp, #8            @ Libera o espaço da pilha

  bx lr

@\brief: ascende os mostradores de 7 segmentos
@recebe: valores
@retorna: nada
hexs:
  @ salva o valor dos registradores na pilha 
  ldr r4, [sp, #0]
  ldr r5, [sp, #4]
  sub sp, sp, #24
  str r0, [sp, #20]
  str r1, [sp, #16]
  str r2, [sp, #12]
  str r3, [sp, #8]
  str r4, [sp, #4]
  str r5, [sp, #0]

  @mostradores
  @HEX5_BASE: .word 0x10  @ Endereço do display HEX5 
  @HEX4_BASE: .word 0x20  @ Endereço do display HEX4
  @HEX3_BASE: .word 0x30  @ Endereço do display HEX3
  @HEX2_BASE: .word 0x40  @ Endereço do display HEX2
  @HEX1_BASE: .word 0x50  @ Endereço do display HEX1
  @HEX0_BASE: .word 0x60  @ Endereço do display HEX0

  @salvar os resgistradores na memoria

  ldr r6, =ADDRESS_MAPPED
  ldr r6, [r6]
 
  strb r0, [r6, #0x10] @escrever no digito 5   
  strb r1, [r6, #0x20] @escrever no digito 4   
  strb r2, [r6, #0x30] @escrever no digito 3   
  strb r3, [r6, #0x40] @escrever no digito 2   
  strb r4, [r6, #0x50] @escrever no digito 1   
  strb r5, [r6, #0x60] @escrever no digito 0   
  @carrega os registradores da memoria 
  ldr r0, [sp, #20]
  ldr r1, [sp, #16]
  ldr r2, [sp, #12]
  ldr r3, [sp, #8]
  ldr r4, [sp, #4]
  ldr r5, [sp, #5]
  add sp, sp, #24

  bx lr

@\brief: recebe uma posicao e apaga o poligono da instrucao dp 
@\param[in]: r0-endereco 
@\return: null
clear_dp_memory:
  @ Salva os registradores na pilha
  sub sp, sp, #4 
  str r0, [sp, #0]           @guarda r0 no topo da pilha

  @ Zera o sinal de start
  mov r2, #0
  ldr r1, =ADDRESS_MAPPED
  ldr r1, [r1]
  str r2, [r1, #0xc0]

  @ Configuração de dataA
  mov r1, #0b0011            @ opcode
  lsl r0, r0, #4             @ Desloca endereco 4 bits à esquerda
  add r0, r0, r1             @ Adiciona o opcode a endereco 
  ldr r3, =ADDRESS_MAPPED
  ldr r3, [r3]
  str r0, [r3, #0x80]        @ Armazena `dataA` no endereço mapeado

  @ Configuração de dataB
  mov r0, #1                 @ Tipo: 0 - quadrado, 1 - triângulo
  lsl r0, r0, #31            @ Desloca `tipo` para o bit 31
  mov r1, #0b000000000     @ carrega uma "cor" 
  lsl r1, r1, #22            @ Desloca `cor`
  add r0, r0, r1             @ Junta `tipo` e `cor`

  mov r2, #0b0000          @ Carrega `tamanho` como 0, para limpar o vga
  lsl r2, r2, #18            @ Desloca `tamanho`
  add r0, r0, r2             @ Junta `tamanho`

  mov r3, #0b000000000     @ Carrega `posY`
  lsl r3, r3, #9             @ Desloca `posY`
  add r0, r0, r3             @ Junta `posY`

  mov r4, #0b000000000     @ Carrega `posX`
  add r0, r0, r4             @ Junta `posX`

  ldr r6, =ADDRESS_MAPPED
  ldr r6, [r6]
  str r0, [r6, #0x70]        @ Armazena `dataB` no endereço mapeado

  @ Sinal positivo para WRREG
  mov r0, #1
  ldr r1, =ADDRESS_MAPPED
  ldr r1, [r1]
  str r0, [r1, #0xc0]        @ Atualiza WRREG para sinal positivo
  
  @ Restaura os valores dos registradores
  ldr r0, [sp, #0]
  add sp, sp, #4

  bx lr

@\brief: limpa todos enderecos da memoria de instrucao
clear_dp_from_vga:
  mov r0, #31                @ adiciona 31 a r0, que e a quantidade de enderecos
  for:
    bl clear_dp_memory       @ chama a funcao para limpar o endereco
    cmp r0, #0              @ compara com -1, para ver se todos enderecos ja foram limpos 
    beq exit                 @ sai do loop caso a comparacao seja verdadeira 
    sub r0, r0, #1           @ subtrai 1 do valor de r0
    bl for                   @ volta para o inicio do loop

  exit:
    bx lr


set_sprite:                           @ Início da função set_sprite

    PUSH {lr}                         @ Salva o link register (retorno da função) na pilha

    LDR r6, =ADDRESS_MAPPED
    LDR r6, [r6]

    LDR r5, [r6, #0xb0]
    CMP r5, #1              @Testa o bit 0 de r0 (bit de status do buffer)
    BEQ wait_loop   
  
    LSL r0, r0, #4                    @ Desloca r0 (primeiro argumento)
    STR r0, [r6, #0x80]              @ Armazena r0 deslocado no dataA

    LSL r1, r1, #29                   @ Desloca r1 (segundo argumento)
    LSL r2, r2, #19                   @ Desloca r2 (terceiro argumento)
    LSL r3, r3, #9                    @ Desloca r3 (quarto argumento)

    ORR r1, r1, r2                    @ Combina r1 e r2
    ORR r1, r1, r3                    @ Combina r1 e r3

    LDR r4, [sp, #4]                  @ Carrega o quinto argumento da stack para r4

    ORR r1, r1, r4                    @ Combina r1 com r4 (quinto argumento)
	
    STR r1, [r6, #0x70]              @ Armazena o valor combinado no dataB

    MOV r0, #1                        @ Habilita instrução WRREG
    STR r0, [r6, #0xc0]
    MOV r0, #0                        @ Desabilita instrução WRREG
    STR r0, [r6, #0xc0]

    ADD sp, sp, #8                   @ Ajusta a stack
    BX lr                            


set_background_color:                @ Início da função set_background_color

    PUSH {lr}                        @ Salva o link register (retorno da função) na pilha

    LDR r6, =ADDRESS_MAPPED
    LDR r6, [r6]

    LDR r5, [r6, #0xb0]
    CMP r5, #1              @Testa o bit 0 de r0 (bit de status do buffer)
    BEQ wait_loop   
    
    MOV r3, #0                       @ Define r3 como o valor fixo do registrador para esta operação
    LSL r3, r3, #4                   @ Desloca o valor do registrador (r3) 4 bits à esquerda
    STR r3, [r6, #0x80]              @ Armazena o valor do registrador no dataA

    LSL r0, r0, #6                   @ Desloca o valor do componente R 6 bits à esquerda
    LSL r1, r1, #3                   @ Desloca o valor do componente G 3 bits à esquerda

    ORR r0, r0, r1                   @ Combina R e G em um único valor
    ORR r0, r0, r2                   @ Adiciona B ao valor combinado de R e G
	
    STR r0, [r6, #0x70]             @ Armazena o valor final RGB no dataB

    MOV r0, #1                       @ Sinaliza para habilitar a instrução
    STR r0, [r6, #0xc0]             @ Grava o sinal de habilitação no WRREG
    MOV r0, #0                       @ Sinaliza para desabilitar a instrução
    STR r0, [r6, #0xc0]             @ Grava o sinal de desabilitação no WRREG

    ADD sp, sp, #4                   @ Ajusta a stack
    BX lr

set_background_block:
  
  PUSH {lr}

  LDR r6, =ADDRESS_MAPPED
  LDR r6, [r6]

  LDR r5, [r6, #0xb0]
  CMP r5, #1              @Testa o bit 0 de r0 (bit de status do buffer)
  BEQ wait_loop   

  LSL r0, r0, #4
  MOV r5, #2
  ORR r0, r0, r5
  STR r0, [r6, #0x80]              @ Armazena o valor do registrador no dataA

  LSL r2, r2, #3
  LSL r3, r3, #6
  ORR r1, r1, r2
  ORR r1, r1, r3
  STR r1, [r6, #0x70]             @ Armazena o valor final RGB no dataB


  MOV r0, #1                       @ Sinaliza para habilitar a instrução
  STR r0, [r6, #0xc0]             @ Grava o sinal de habilitação no WRREG
  MOV r0, #0                       @ Sinaliza para desabilitar a instrução
  STR r0, [r6, #0xc0]             @ Grava o sinal de desabilitação no WRREG

  ADD sp, sp, #4                   @ Ajusta a stack
  BX lr                            


wait_loop:
  LDR r6, =ADDRESS_MAPPED
  LDR r6, [r6]
  LDR r5, [r6, #0xb0]
  CMP r5, #1              @Testa o bit 0 de r0 (bit de status do buffer)
  BEQ wait_loop   
  BX lr

WSM:

  PUSH {lr}

  LDR r6, =ADDRESS_MAPPED
  LDR r6, [r6]

  LDR r5, [r6, #0xb0]
  CMP r5, #1              @Testa o bit 0 de r0 (bit de status do buffer)
  BEQ wait_loop   

  LSL r0, r0, #4
  MOV r5, #1
  ORR r0, r0, r5
  STR r0, [r6, #0x80]              @ Armazena o valor do registrador no dataA

  LSL r2, r2, #3
  LSL r3, r3, #6
  ORR r1, r1, r2
  ORR r1, r1, r3
  STR r1, [r6, #0x70]             @ Armazena o valor final RGB no dataB


  MOV r0, #1                       @ Sinaliza para habilitar a instrução
  STR r0, [r6, #0xc0]             @ Grava o sinal de habilitação no WRREG
  MOV r0, #0                       @ Sinaliza para desabilitar a instrução
  STR r0, [r6, #0xc0]             @ Grava o sinal de desabilitação no WRREG

  ADD sp, sp, #4                   @ Ajusta a stack
  BX lr            

