#include <stdio.h>

#define video_WHITE 0xFFFF // Define some colors for video graphics
#define video_YELLOW 0xFFE0
#define video_RED 0xF800
#define video_GREEN 0x07E0
#define video_BLUE 0x041F
#define video_CYAN 0x07FF
#define video_MAGENTA 0xF81F
#define video_GREY 0xC618
#define video_PINK 0xFC18
#define video_ORANGE 0xFC00

extern void memory_map();
extern void memory_unmap();
extern int key_read();
extern void draw_triangle(int cor, int tamanho, int posicoes, int endereco);
extern void draw_square(int cor, int tamanho, int posicoes, int endereco);
extern void draw_triangleTeste(int cor, int tamanho, int posX, int posY, int endereco);

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
  unsigned int a = 10;
  //draw_triangle(0b111000111, 0b0000, a, 0b0000);
  draw_triangleTeste(0b000111111, 0b0000, a, a, 5); // testar essa função pega todos argumentos

  memory_unmap();

}
