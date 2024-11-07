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
//extern void clear_dp_from_vga();
//extern void wbm(int cor, int endereco);

extern void set_background_color(unsigned int red, unsigned int green, unsigned int blue);
extern void set_sprite(unsigned int reg, unsigned int activation_bit, unsigned int x, unsigned int y, unsigned int offset);
extern void set_background_block(unsigned int address, unsigned int red, unsigned int green, unsigned int blue);
extern void WSM(unsigned int address, unsigned int red, unsigned int green, unsigned int blue);


void mudar_sprite() {
    unsigned int endereco_base = 0; // Endereço base inicial
    unsigned int red = 0;                  
    unsigned int green = 255;                  
    unsigned int blue = 0;                  

    // Loop para as primeiras 400 posições de memória
    for (unsigned int i = 0; i < 400; i++) {
        unsigned int address = endereco_base + i; // Calcula o endereço para cada posição
        WSM(address, red, green, blue);           // Chama a função WSM para o endereço e valores RGB
    }
}

void set_background_block_caller(unsigned int column, unsigned int line, unsigned int red, unsigned int green, unsigned int blue) {
    unsigned int address = (line * 80) + column;  // Cálculo do endereço do bloco
    set_background_block(address, red, green, blue);  // Chama a função Assembly para configurar bloco de background
} //USA ESSA

void clear_screen() {
    // Define a cor de fundo para um valor (por exemplo, preto)
    set_background_color(0, 0, 0);

    // Apaga todos os blocos de background
    for (int col = 0; col < 80; col++) {
        for (int lin = 0; lin < 60; lin++) { //mudar isso
            set_background_block_caller(col, lin, 110, 111, 111);  // Define todos os blocos para preto (verificar a ordem)
        }
    }

    // Desabilita todos os sprites
    for (int i = 1; i < 32; i++) {
        set_sprite(i, 0, 0, 0, 0);  // Desativa o sprite no registrador correspondente
    }
}

void main(){
  memory_map();

  draw_triangle(video_PURPLE, 0b0001, 10, 10, 0);
  
  int key_value = 0;
  
  while(key_value != 8){

    key_value = key_read();
    printf("Valor do botão: %d\n", key_value);

    if(key_value == 1){
      draw_triangle(0b000111111, 0b0001, 30, 20, 1);
    } else if (key_value == 2){
      draw_square(0b000111111, 0b0001, 100, 200, 0);
    } else if (key_value == 4) {
      clear_dp_from_vga();
    }
  }

  memory_unmap();
}
