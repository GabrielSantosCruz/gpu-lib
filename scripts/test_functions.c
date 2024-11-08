#include <stdio.h>

#define video_WHITE 0b000000000 // Define some colors for video graphics
#define video_RED 0b111000000
#define video_GREEN 0b000111000
#define video_BLUE 0b000000111
#define video_PURPLE 0b111000111

extern void memory_map();
extern void memory_unmap();
extern int key_read();
extern void hexs(int digito0, int digito1, int digito2, int digito3, int digito4, int digito5);
extern void draw_triangle(int cor, int tamanho, int posX, int posY, int endereco);
extern void draw_square(int cor, int tamanho, int posX, int posY, int endereco);
extern void wbm(int cor, int endereco);
extern void clear_dp_memory();
extern void clear_background();


int board[3][3] = {
  {1, 0, 1},
  {0, 1, 0},
  {0, 0, 1}
};


void print_board(int col, int row, int matriz[col][row]){
  for(int i = 0; i < row; i++){
    for(int j = 0; j < col; j++){
      if(matriz[i][j] == 1){
        wbm(0b0001111111, ((i * 80 + 80) + (j + 280)));
      }
    }
  }
}


void main(){
  memory_map();
  clear_background();
  int posX = 50;
  int posY = 20;
  int posicao = ((posX * 80+80) + (posY+80));
  wbm(0b000111111, posicao);
  print_board(3, 3, board);

  memory_unmap();
}
