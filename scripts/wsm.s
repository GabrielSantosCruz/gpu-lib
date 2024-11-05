  .section .data
MEM_FD:         .asciz   "/dev/mem"
FPGA_BRIDGE:    .word    0xff200
HW_REGS_SPAN:   .word    0x1000
ADRESS_MAPPED:  .space   4
ADRESS_FD:      .space   4
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
  
  .global wsm 
  .type wsm, %function 

@mapeia a memoria
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

  ldr r1, =ADRESS_FD
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
  
  ldr r1, =ADRESS_MAPPED  @endereco e carregado aqui
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

@desmapeia a memoria e fecha o arquivo /dev/mem
memory_unmap:
  @salva o valor dos registradores na pilha
  sub sp, sp, #12
  str r0, [sp, #8]
  str r1, [sp, #4]
  str r7, [sp, #0]

  ldr r0, =ADRESS_MAPPED
  ldr r0, [r0]
  mov r1, #4096           @tamanho da página mapeada
  mov r7, #91             @system call: munmap
  svc 0
  
  ldr r0, =ADRESS_FD
  ldr r0, [r0]
  mov r7, #6              @system call: close
  svc 0
  
  @carrega o valor dos registradores da pilha
  ldr r0, [sp, #8]
  ldr r1, [sp, #4]
  ldr r7, [sp, #0]

  add sp, sp, #12

  bx lr

@\brief: escreve valores RGB na memória de sprites
@\param[in]: r0 - componente R
@\param[in]: r1 - componente G
@\param[in]: r2 - componente B
@\param[in]: r3 - endereço de memória do sprite
@\return: null
write_sprite_memory:
  @ Salva os registradores na pilha
  sub sp, sp, #16
  str r0, [sp, #12]          @ r
  str r1, [sp, #8]           @ g 
  str r2, [sp, #4]           @ b
  str r3, [sp, #0]           @ endereco 

  @ Zera o sinal de start
  mov r0, #0
  ldr r1, =ADDRESS_MAPPED
  ldr r1, [r1]
  str r0, [r1, #0xc0]        @ Define WRREG como 0 para reiniciar o sinal

  @ Configuração de dataA (opcode e endereço de memória)
  mov r0, #0b0001            @ Define o opcode WSM (0001)
  lsl r3, r3, #9             @ Desloca endereço de memória para alinhar
  add r3, r3, r0             @ Combina o opcode com o endereço
  ldr r2, =ADDRESS_MAPPED
  ldr r2, [r2]
  str r3, [r2, #0x80]        @ Armazena `dataA` no endereço mapeado para dataA

  @ Configuração de dataB (valores RGB)
  ldr r0, [sp, #12]          @ carrega r 
  lsl r0, r0, #6             @ r para a posicao correta
  ldr r1, [sp, #8]           @ carrega g
  lsl r1, r1, #3             @ desloca g
  add r0, r0, r1             @ combina r e g
  ldr r1, [sp, #4]           @ carrega b
  add r0, r0, r1             @ combina r g e b 

  ldr r4, =ADDRESS_MAPPED
  ldr r4, [r4]
  str r0, [r4, #0x70] 

  @ Sinal positivo para WRREG
  mov r0, #1
  ldr r1, =ADDRESS_MAPPED
  ldr r1, [r1]
  str r0, [r1, #0xc0]        @ Atualiza WRREG para iniciar a escrita

  @ Restaura os valores dos registradores
  ldr r0, [sp, #12]          @ restaura r
  ldr r1, [sp, #8]           @ restaura g
  ldr r2, [sp, #4]           @ restaura b
  ldr r3, [sp, #0]           @ restaura endereco 
  add sp, sp, #16            @ libera pilha 

  bx lr                      @ Retorna da função

