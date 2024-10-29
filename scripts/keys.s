  .section .data
MEM_FD:         .asciz   "/dev/mem"
FPGA_BRIDGE:    .word    0xff200
HW_REGS_SPAN:   .word    0x100
ADRESS_MAPPED:  .space   4
ADRESS_FD:      .space   4

  .global key_read
  .type key_read, %function

key_read:
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
  
  
  @salva na pilha
  sub sp, sp, #4 
  str r1, [sp, #0]

  @le o valor do botao 
  ldr r1, =ADRESS_MAPPED
  ldr r1, [r1]
  ldr r0, [r1, #0x0]

  @carrega da pilha
  ldr r1, [sp, #0]
  add sp, sp, #4 

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
  
  ldr r0, =fd
  ldr r0, [r0]
  mov r7, #6              @system call: close
  svc 0
  
  @carrega os registradores da pilha
  ldr r0, [sp, #8]
  ldr r1, [sp, #4]
  ldr r7, [sp, #0]

  add sp, sp, #12

