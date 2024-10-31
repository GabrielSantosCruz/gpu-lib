#include <stdio.h>

extern void memory_map();
extern void memory_unmap();
extern int key_read();
//recebe: r0-forma, r1-cor, r2-tamanho, r3-posicao X, r4-posicao Y
extern void draw_triangle(int cor, int tamanho, int posicoes, int endereco);

void main(){
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
  unsigned int a = 20;
  int b = 300; // posX 
  a = b << 9;
  a += 20; // posY
  draw_triangle(0b111000111, 0b0001, a, 0b0000);
  //a = b << 9;
  //a += 250; // posY
  draw_triangle(0b000111000, 0b0001, a, 0b1111);
  // eu tenho que passar a posição toda em posX
  memory_unmap();
}
