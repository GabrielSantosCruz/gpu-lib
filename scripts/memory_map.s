  .section .data
MEM_FD:         .asciz   "/dev/mem"
FPGA_BRIDGE:    .word    0xff200
HW_REGS_SPAN:   .word    0x100
ADRESS_MAPPED:  .space   4
ADRESS_FD:      .space   4
dataA:          .word    0x80
dataB:          .word    0x70
WRREG:          .word    0xc0

  .global memory_map
  .type memory_map, %function

  .global memory_unmap
  .type memory_unmap, %function
  
  .global key_read
  .type key_read, %function
  
  .global dp
  .type dp, %function

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
  mov r2, #3              @modo leitura/escrita
  mov r3, #1              @compartilha com os processos
  ldr r5, =FPGA_BRIDGE    @carrega o endereco base
  ldr r5, [r5]            @carrega o endereco real (igual um ponteiro)
  svc 0                   @chama o sistema para executar
  
  ldr r1, =ADRESS_MAPPED
  str r0, [r1]
  
  @carrega os registradores de volta
  ldr r1, [sp, #24]
  ldr r2, [sp, #20]
  ldr r3, [sp, #16]
  ldr r4, [sp, #12]
  ldr r5, [sp, #8]
  ldr r7, [sp, #4]
  ldr r0, [sp, #0]
  add sp, sp, #28         @reseta a pilha
  
  bx lr

memory_unmap:
  @salva os registradores na pilha
  sub sp, sp, #12
  str r0, [sp, #8]
  str r1, [sp, #4]
  str r7, [sp, #0]

  ldr r0, =mapped_address
  ldr r0, [r0]
  mov r1, #4096           @tamanho da página mapeada
  mov r7, #91             @system call: munmap
  svc 0
  
  ldr r0, =ADRESS_FD
  ldr r0, [r0]
  mov r7, #6              @system call: close
  svc 0
  
  @carrega os registradores da pilha
  ldr r0, [sp, #8]
  ldr r1, [sp, #4]
  ldr r7, [sp, #0]

  add sp, sp, #12

  bx lr

key_read: @le o valor dos botoes 
  @salva na pilha
  sub sp, sp, #4 
  str r1, [sp, #0]

  @le o valor do botao 
  ldr r1, =ADRESS_MAPPED
  ldr r1, [r1]
  ldr r0, [r1, #0x0]          @le o valor do endereco dos botoes

  @carrega da pilha
  ldr r1, [sp, #0]
  add sp, sp, #4 

  bx lr

dp: @desenha poligono
  @salvar os registradores na pilha
  sub sp, sp, #28
  str r1, [sp, #24]
  str r2, [sp, #20]
  str r3, [sp, #16]
  str r4, [sp, #12]
  str r5, [sp, #8]
  str r6, [sp, #4]
  str r0, [sp, #0]

  @zera o sinal de start
  mov r0, #0
  add r2, ADRESS_MAPPED, WRREG @soma para pegar o resultado do endereco
  str r0, [r2]                @se der algum erro maluco, pode ser isso aqui 

  @dataA
  mov r0, #0b0011           @opcode
  mov r1, #0b0000           @endereco
  lsl r1, r1, #4              @deslocar 4bits pra esq
  add r1, r1, r0              @adicionar o opcode no inicio da isntrucao
  add r2, ADRESS_MAPPED, dataA @soma para pegar o resultado que e o endereco
  str r1, [r2]                @carrega o endereco

  @dataB
  mov r0, #1                  @ 0 - quadrado 1 - triangulo
  lsl r0, r0, #31             @desloca 31 bits p esq  
  mov r1, #0b011100111      @ cor (3 bits para cada tom RGB)
  lsl r1, r1, #22             @desloca 
  add r0, r0, r1              @junta r0 e r1
  mov r2, #0b0011           @tamanho 
  lsl r2, r2, #18             @ desloca 
  add r0, r0, r2              @junta r0 e r2
  mov r3, #160                @posicao Y
  lsl r3, r3, #9              @desloca 
  add r0, r0, r3              @junta r0 e r3
  mov r4, #100                @posicao X
  add r0, r0, r4
  add r5, ADRESS_MAPPED, dataB @resultado do endereco
  str r0, [r5]                @carrega o endereco

  @sinal positivo para WRREG
  mov r6, #1 
  add r2, ADRESS_MAPPED, WRREG
  str r6, [r2]                @carrega no endereco
  
  @carrega o valor dos registradores de volta
  ldr r1, [sp, #24]
  ldr r2, [sp, #20]
  ldr r3, [sp, #16]
  ldr r4, [sp, #12]
  ldr r5, [sp, #8]
  ldr r6, [sp, #4]
  ldr r0, [sp, #0]
  add sp, sp, #28

  bx lr
