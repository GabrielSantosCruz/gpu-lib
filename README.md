# Sistemas Digitais

Este projeto tem como objetivo desenvolver uma biblioteca com funções gráficas para o 
Processador Gráfico desenvolvido no trabalho de conclusão de curso do Engenheiro da 
Computação Gabriel Sá Barreto Alves (Link do trabalho: https://drive.google.com/file/d/1MlIlpB9TSnoPGEMkocr36EH9-CFz8psO/view).  
Essas funções foram desenvolvidas em linguagem assembly e deve ser integrada com o jogo Tetris desenvolvido
no problema 1 (https://github.com/Fernanda-Marinho/PBL-TEC499) desta disciplina. A integração das funções com o jogo
foi feita em linguagem C. Neste projeto foi utilizada a plataforma de desenvolvimento DE1-SoC. 


# Equipe:
- [Camila de Araújo Bastos](https://github.com/Caamilab)
- [Fernanda Marinho Silva](https://github.com/Fernanda-Marinho/)
- [Gabriel Santos Cruz](https://github.com/GabrielSantosCruz)


# Executando o Projeto
### Clonando o Repositório
```bash
git clone https://github.com/GabrielSantosCruz/gpu-lib 
cd gpu-lib/

```
### Executando
```bash
cd scripts/ 
sudo make run

```

# Introdução 

O trabalho de conclusão de curso utilizado como base para o desenvolvimento deste projeto propõe
o desenvolvimento de uma arquitetura baseada em sprites para criar jogos 2D usando dispositivos FPGA.
Essa arquitetura visa facilitar a compreensão dos conceitos de sistemas digitais e a integração entre hardware e 
software por meio de uma abordagem prática e interativa. No trabalho ainda há a inclusão de jogos como Asteroids e Space Invaders,
porém no presente projeto esses jogos não foram implementados. 

# Mapeamento de memória 

O mapeamento de memória é um processo necessário para possibilitar a interação direta com o hardware da placa FPGA. Essa interação é feita através da abertura de arquivos especiais e do mapeamento de memória, que permite o acesso aos recursos de hardware por meio de endereços de memória específicos. O processo é dividido em duas etapas principais:

## Passo 1: Abertura do `/dev/mem`
O arquivo especial **`/dev/mem`** é utilizado para permitir o acesso direto ao hardware. Ao abrir este arquivo com permissões de leitura e escrita, o código em assembly garante que será possível acessar e modificar os registros físicos, além de sincronizar adequadamente as operações de entrada/saída (I/O).

## Passo 2: Mapeamento da Memória
Após a abertura do arquivo, o próximo passo é realizar o mapeamento de memória. O código define o endereço base do **FPGA Bridge** como **0xff200**, que marca o ponto inicial na memória física a ser acessada. A extensão da área de memória (span) é configurada como **0x1000**, especificando o tamanho total da região a ser mapeada. O sistema operacional atribui um endereço virtual para esta área mapeada, permitindo que o programa em assembly acesse diretamente os periféricos, como os displays HEX, de maneira eficiente e controlada.

Durante este processo, são configurados os endereços específicos dos componentes de hardware, como os displays de 7 segmentos (HEX5 a HEX0), permitindo o controle direto. O mapeamento também assegura que diferentes partes do sistema possam acessar essa região de memória compartilhada, facilitando uma comunicação eficiente e a atualização rápida dos elementos controlados.

# Envio de instruções 

O envio de instruções é feito de maneira coordenada para garantir que os comandos sejam processados corretamente pelo processador gráfico da FPGA. 

## Configuração dos Dados
Primeiramente, os valores apropriados são carregados nos barramentos de dados:
- **dataA** (`0x80`): Carrega informações como o opcode (código da operação) e os endereços dos registradores.
- **dataB** (`0x70`): Armazena dados específicos que serão utilizados na execução da instrução.

## Ativação do Sinal de Escrita
Após a configuração dos barramentos `dataA` e `dataB`, o sinal de escrita, **WRREG** (`0xc0`), é ativado. Esse sinal indica que uma nova instrução está pronta para ser escrita no buffer de instruções, garantindo que o comando seja enfileirado corretamente.

## Verificação do Estado do Buffer
Antes de enviar outra instrução, é necessário verificar o sinal **WRFULL** (`0xb0`), que informa se o buffer de instruções está cheio. Caso o buffer esteja cheio, o programa aguarda até que haja espaço disponível, assegurando que as instruções sejam transmitidas sem perdas ou sobrescritas.

Esse processo garante uma comunicação eficiente e sincronizada com os periféricos da FPGA, otimizando o controle de elementos gráficos e displays.


# Escrita no Banco de Registradores (WBR) 

# Escrita na Memória de Sprites (WSM)

# Escrita na Memória de Background (WBM)

# Definição de um Polı́gono (DP)

# Conclusão


