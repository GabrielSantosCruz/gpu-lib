#include <stdio.h>

extern void memory_map();
extern void memory_unmap();
extern int key_read();

void main(){
  
  while(1){
     // Chama a função para mapear a memória
    memory_map();
    printf("Memória mapeada.\n");
    
     // Lê o valor dos botões
    int key_value = key_read();
    printf("Valor dos botões: %d\n", key_value);
  
    // Desmapeia a memória
    memory_unmap();
    printf("Memória desmapeada.\n");
  }
}
