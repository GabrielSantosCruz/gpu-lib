#include <stdio.h>

#define video_WHITE 0b000000000 // Define some colors for video graphics
#define video_RED 0b111000000
#define video_GREEN 0b000111000
#define video_BLUE 0b000000111
#define video_PURPLE 0b111000111

extern void memory_map();
extern void memory_unmap();
extern int key_read();
extern void draw_triangle(int cor, int tamanho, int posicoes, int endereco);
extern void draw_square(int cor, int tamanho, int posicoes, int endereco);
extern void clear_dp_from_vga();

void main(){
  memory_map();

  draw_triangle(video_PURPLE, 0b0001, 10, 10, 0);
  
  int key_value = 0;
  
  while(key_value != 8){

    key_value = key_read();

    if(key_value == 1){
      draw_triangle(0b000111111, 0b0001, 30, 20, 1);
    } else if (key_value == 2){
      clear_dp_from_vga();
    }

  }

  memory_unmap();
}
