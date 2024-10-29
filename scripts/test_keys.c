#include <stdio.h>

extern void memory_map();
extern void memory_unmap();
extern int key_read();
extern void dp();

void main(){
  printf("pelo menos aqui foi!\n");  
    /*while(1){
     // Chama a função para mapear a memória
    memory_map();
    
     // Lê o valor dos botões
    int key_value = key_read();
    key_value = ~key_value;
    key_value += 16;
    printf("Valor dos botões: %d\n", key_value);
    // Desmapeia a memória
    memory_unmap();
  }*/
  memory_map();
  dp();
  memory_unmap();
}
