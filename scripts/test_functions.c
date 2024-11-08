#include <stdio.h>

#define video_WHITE 0b000000000 // Define some colors for video graphics
#define video_RED 0b111000000
#define video_GREEN 0b000111000
#define video_BLUE 0b000000111
#define video_PURPLE 0b111000111

extern void memory_map();
extern void memory_unmap();
extern int key_read();
extern void hexs(unsigned int digito0,unsigned int digito1,unsigned int digito2,unsigned int digito3,unsigned int digito4,unsigned int digito5);
extern void draw_triangle(unsigned int cor,unsigned int tamanho,unsigned int posX,unsigned int posY,unsigned int endereco);
extern void draw_square(unsigned int cor,unsigned int tamanho,unsigned int posX,unsigned int posY,unsigned int endereco);
extern void clear_dp_memory(unsigned int enderecoDp);
extern void set_background_color(unsigned int red, unsigned int green, unsigned int blue);
extern void set_sprite(unsigned int reg, unsigned int activation_bit, unsigned int x, unsigned int y, unsigned int offset);
extern void set_background_block(unsigned int address, unsigned int red, unsigned int green, unsigned int blue);
extern void WSM(unsigned int address, unsigned int red, unsigned int green, unsigned int blue);

// funcao para desenhar um quadrado na tela
void set_draw_square(unsigned int cor,unsigned int tamanho,unsigned int posX,unsigned int posY,unsigned int endereco){
  draw_square(cor, tamanho, posX, posY, endereco);
}
// funcao para desenhar um triangulo na tela
void set_draw_triangle(unsigned int cor,unsigned int tamanho,unsigned int posX,unsigned int posY,unsigned int endereco){
  draw_triangle(cor, tamanho, posX, posY, endereco);
}
// funcao para limpar os poligonos da tela 
void clear_poligono(){
  for(int i = 0; i < 32; i++){
    // set_draw_triangle(0b000000111, 0b0000, 20, 20, 0);
    // char foo;
    // printf("%d\n", i);
    // scanf("%c", &foo);
    clear_dp_memory(i);
  }
}

void desenha_poligonos(){
  set_draw_triangle(0b000000111, 0b0011, 100, 100, 0);
  set_draw_square(0b111111000, 0b0011, 20, 20, 1);
}
// funcao para usar os mostradores
void teste_mostradores(){
  hexs(127, 6, 71, 12, 127, 127);
}
// funcao mostrando os botoes funcionando

void mudar_sprite() {
  unsigned int endereco_base = 10000; // Endereço base inicial
  unsigned int red = 0;                  
  unsigned int green = 7;                  
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
  // char foo;
  // Desabilita todos os sprites
  for (int i = 1; i < 32; i++) {
    // scanf("%c", &foo);
    set_sprite(i, 0, 0, 0, 0);  // Desativa o sprite no registrador correspondente
    // printf("%d\n", i);
  }
}

void main(){
  memory_map();
  mudar_sprite();
  while(1){
    int key_value = key_read();
    printf("key_value: %d\n", key_value);
    switch (key_value) {

      case -1: 
        clear_poligono();
        clear_screen();
        break; 
      case -2:
        set_draw_triangle(0b000000111, 0b0011, 100, 100, 0b0001);
        break; 
      case -3:
        break;
      case -4:
        set_background_block(480,100,100,225);
        break; 
      case -6:
        set_sprite(1,1,100,100,0);
        break; 
      case -8:
        set_sprite(3,1,200,200,25);	
        break;
      case -9:
        set_background_color(100,0,0);
        break;
      case -10:
        set_draw_square(0b111111000, 0b0011, 20, 20, 0b0011);
        break;
    }
    mudar_sprite();
  }
  memory_unmap();
}
