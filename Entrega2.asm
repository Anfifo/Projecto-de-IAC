;******************************;
;*        Grupo 33:           *;
;* Andre Fonseca     84698    *;
;* Catarina Custodio 84705    *;
;* Isabel Dias       84726    *;
;******************************;

;************************************************************************************
; Informacao do Codigo:
;
; Regras seguidas geralmente pelo codigo : 
; R0:  -
; R1: (R) corresponde a um endereço de leitura
; R2: (R)/(W) corresponde a um endereço de leitura ou um endereço de escrita
; R3: (W) corresponde a um endereço de escrita 
; R4: Contador 
; R5: (R/W) endereço de uma tabela/words/strings
; R6:  -
; R7:  -
; R8: (R) guarda valor de um endereco para comparacao
; R9: (R) guarda valor de um endereço para comparacao 
; R10: - 
;
; W: Write, corresponde a um endereco ou registo onde escrevemos 
; R: Read, corresponde a um endereco ou registo do qual vamos ler.
;
;*************************************************************************************

;*************************************************************************************
; Constantes 
;*************************************************************************************

SELECAO_COMBOIO     EQU 8018H               ; (W) endereço de escrita que escolhe comboio e a operacao a executar sobre este
OPERACAO_COMBOIO    EQU 801AH               ; (W) endereço de escrita onde alteramos o sentido e velocidade do comboio seleccionado na operacao de comboios
BARRAS_VELOCIDADE   EQU 8004H               ; (R) endereço de leitura dos "sliders" (superior e inferior) do controle dos comboios

TECLADO07 EQU 8006H                         ; (R) endereço de leitura das teclas de 0 a 7, cada posicao do bit corresponde a um semaforo 7654 3210
TECLADO8F EQU 8008H                         ; (R) endereço de leitura das teclas de 0 a 15, cada posicao do bit corresponde a um semaforo **** **98
SEMAFOROS EQU 8012H                         ; (W) endereço de escrita que altera os semaforos, Os bits 7 a 2 indicam o número do semáforo. Os bits 1 e 0 indicam a cor

BOTOES_PRESSAO  EQU 800CH                   ; (R) endereço de leitura dos botoes de pressao, a 1 on, 0 off
AGULHAS         EQU 8016H                   ; (W) endereço de escrita dos estados da agulhas de 7 a 2 numero agulha, 1-0 estado da agulha (01=esquerda 10=direita)

NUMERO_EVENTOS_SENSORES EQU 801CH           ; (R) le o numero de eventos lidos pelos sensores, cada evento corresponde a 2 valores no porto na INFORMACAO_SENSORES
INFORMACAO_SENSORES     EQU 801EH           ; (R) le a informacao dada pelo sensor, qual
LCD_SUPERIOR  EQU 8000H                     ; (W) escreve informacao no LCD superior 
LCD_INFERIOR  EQU 8002H                     ; (W) escrever informacao no LCD inferior

COMBOIO_0 EQU 0H                            ; Valor que corresponde ao comboio numero 0 (azul)
COMBOIO_1 EQU 10H                           ; Valor que corresponde ao comboio numero 1 (verde)
SENTIDO_NEGATIVO_COMBOIO EQU 80H            ; Valor que corresponde ao sentido negativo de um comboio

ESQUERDA EQU 1H                             ; Valor do estado da agulha quando esta em modo "esquerda"
DIREITA  EQU 2H                             ; Valor do estado da agulha quando esta em modo "direita"

CINZENTO EQU 0H                             ; Valor da cor Cinzenta no semaforo
VERMELHO EQU 1H                             ; Valor da cor Vermelha no semaforo
VERDE    EQU 2H                             ; Valor da cor Verde no semaforo30H                 

TRANSFORMADOR_ASCII EQU 30H                 ; Valor necessario para no sensor transformar a informacao correcta ASCII dos numeros
DESOCUPADO EQU 0							              ; quando o troco se encontra desocupado
OCUPADO EQU 1								                ; quando o troco se encontra ocupado

NENHUM EQU 0H
OFF EQU 0H
ON EQU 1H

MASCARA_VELOCIDADE_ANTES_DE_VERIFICAR  EQU 0BH
MASCARA_VELOCIDADE_DEPOIS_DE_VERIFICAR EQU 83H                                                                        
MASCARA_BOTOES_AGULHAS EQU 0FH              ; filtrar os bits que nao sejam os primeiros 4 das agulhas, pois so temos 4 agulhas para mudar 
MASCARA_SEMAFORO_8_9 EQU 3H                 ; filtrar os bits que nao sejam os primeiros 2 pois so temos 2 semaforos, 8 e 9

VALOR_COMBOIO_A_ANDAR        EQU 03H       ; corresponde a 00000011b
VALOR_COMBOIO_PARADO        EQU 00H

VALOR_ALTERAR_SEMAFORO_8      EQU 1H
VALOR_ALTERAR_SEMAFORO_9      EQU 2H

NUMERO_SEMAFORO_8 EQU 8H
NUMERO_SEMAFORO_9 EQU 9H

VALOR_3_SEGUNDOS EQU 6H                         ; 3 segundos correspondem a 6 vezes meio segundo

NENHUM_SENSOR EQU 0FFFFH
;*****************************************************************************************************************
; Tabelas
;*****************************************************************************************************************
; pilha: usada para o stack pointer
;
; estados das agulhas: usada para saber a que estado estao as agulhas no momento presente (apos movimento)
;
; cores semaforos: usada para saber a que estado/cor estao os semaforos no momento presente(apos mudanca de cor)
;
; valores anteriores: usada para saber qual o valor anteriormente lido para apenas aplicar mudanca se for diferente
;******************************************************************************************************************

PLACE     1000H

pilha:      TABLE 200H                      ; espaco reservado para a pilha (200H bytes, pois sao 100H words)
SP_inicial:                                 ; este e o endereco (1200H) com que o SP deve ser inicializado.
                                            ; O 1º end. de retorno será armazenado em 11FEH (1200H-2H)

estados_agulhas:                            ; tabela para os estados das agulhas (DIREITA e ESQUERDA).
                                            ; 01 ESQUERDA, 10 DIREITA
  STRING    DIREITA                       ; agulha 0
  STRING    DIREITA                       ; agulha 1
  STRING    DIREITA                       ; agulha 2
  STRING    DIREITA                       ; agulha 3

cores_semaforos:                            ; tabela para as cores dos semáforos (VERDE, CINZENTO ou VERMELHO).
                                            ; 00 cinzento, 01 vermelho, 10 verde, 11 amarelo.
  STRING    VERDE                         ; cor do semáforo 0
  STRING    VERDE                         ; cor do semáforo 1
  STRING    VERDE                         ; cor do semáforo 2
  STRING    VERDE                         ; cor do semáforo 3
  STRING    VERDE                         ; cor do semáforo 4
  STRING    VERDE                         ; cor do semáforo 5
  STRING    VERDE                         ; cor do semáforo 6
  STRING    VERDE                         ; cor do semáforo 7
  STRING    VERDE                         ; cor do semáforo 8
  STRING    VERDE                         ; cor do semáforo 9

valores_anteriores_agulhas:        
  WORD NENHUM

troco:
  STRING    DESOCUPADO
  STRING    DESOCUPADO
  STRING    DESOCUPADO
  STRING    DESOCUPADO
  STRING    DESOCUPADO
  STRING    DESOCUPADO
  STRING    DESOCUPADO
  STRING    DESOCUPADO
  
tabela_interrupcoes:
  WORD interrupcao0
  WORD interrupcao1

valor_velocidade_comboio0:
  WORD VALOR_COMBOIO_A_ANDAR

valor_velocidade_comboio1:
  WORD VALOR_COMBOIO_A_ANDAR

valores_semaforos_0_7: ; tabela usada para alterar a cor dos semaforos
  WORD NENHUM

valores_semaforos_8_9: ; tabela usada para atribuir os valores aos semaforos
  WORD NENHUM 

ultimo_sensor_activo_comboio0: ; endereço onde guardamos o ultimo sensor pelo qual o comboio 0 passou
  WORD NENHUM 

ultimo_sensor_activo_comboio0_tras: ; endereco onde guardamos o ultimo sensor pela qual a traseira do comboio 0 passou
  WORD NENHUM

ultimo_sensor_activo_comboio1: ; endereço onde guardamos o ultimo sensor pelo qual o comboio 1 passou
  WORD NENHUM

ultimo_sensor_activo_comboio_1_tras: ; endereço no qual guardamos o ultimo sensor pelo qual a traseira do comboio 1 passou
  WORD NENHUM

valor_interrupcao1: ; esta a off se a interrupcao estiver desligada, esta a on se a interrupcao estiver ligada
  WORD OFF

flag_interrupcao1_sensores: ; esta a off se for a primeira vez que se inicia a interrupcao
  WORD OFF

contador_interrupcao1_paragem:
  WORD OFF

;*******************************************************************************************************
; Programa Principal
;*******************************************************************************************************
; Programa para verificar se houve mudanca aos comandos de leitura, se sim, entao inicializa-se a rotina 
;*******************************************************************************************************
PLACE 0000H
MOV SP, SP_inicial
MOV BTE, tabela_interrupcoes

pre_start:
CALL inicializar_comboios
CALL por_semaforos_a_cinzento

start:

MOV R4, 0H                                   ; contador para aceder a tabela 
MOV R5, valores_anteriores_agulhas                   ; endereco com a tabela dos valores anteriores

ciclo:
CALL verificar_mudanca_agulhas
CALL verificar_mudanca_sensores
CALL verificar_ultimo_sensor

JMP start

;******************************************************************************************************
; Rotinas de inicialização
;******************************************************************************************************
; Processo pelo qual inicializamos os comboios a andar a velocidade 3 para a frente e os semaforos
; da passagem de nivel a cinzento
;
;
;******************************************************************************************************

inicializar_comboios:
CALL comboio_0_frente
CALL comboio_1_frente
RET

;------------------------------------------------------------------------------------------------------

por_semaforos_a_cinzento:
PUSH R3
PUSH R4
PUSH R5
PUSH R8

MOV R3, SEMAFOROS 
MOV R8, CINZENTO

por_semaforo_8_a_cinzento:
MOV R4, NUMERO_SEMAFORO_8
MOV R5, cores_semaforos
CALL calcula_endereco
CALL escrever

por_semaforo_9_a_cinzento:
MOV R4, NUMERO_SEMAFORO_9
MOV R5, cores_semaforos
CALL calcula_endereco
CALL escrever 

POP R8
POP R5
POP R4
POP R3
RET

;-----------------------------------------------------------------------------------------------------
comboio_0_frente:
PUSH R0
PUSH R7

MOV R0, COMBOIO_0
MOV R7, VALOR_COMBOIO_A_ANDAR
CALL calcula_e_escreve_valor_comboio

POP R7
POP R0
RET 

comboio_1_frente:
PUSH R0
PUSH R7

MOV R0, COMBOIO_1
MOV R7, VALOR_COMBOIO_A_ANDAR
CALL calcula_e_escreve_valor_comboio

POP R7
POP R0
RET


;******************************************************************************************************
; Rotinas de verificacao 
;******************************************************************************************************
; Processo que verifica se existiu mudanca dos inputs, caso nao haja nao executa os ciclos.
;
; Argumentos: contador (R4) valores_anteriores(R5)        | Retorna: nada
;
;******************************************************************************************************

;--------------------------------------------------------------------------------------------------------
verificar_mudanca_agulhas:                  ; verificar se houve mudanca nos valores dos botoes de Pressao
PUSH R2
PUSH R5
PUSH R8
PUSH R9


MOV R2, BOTOES_PRESSAO
MOV R5, valores_anteriores_agulhas
MOVB R8, [R2]
MOV R9, [R5]

CMP R8,R9
JZ fim_verificar_mudanca_agulhas               ; caso nao haja mudanca saltamos para os Sensores
MOV [R5], R8                                   ; escreve na tabela o valor anterior
CALL agulhas

fim_verificar_mudanca_agulhas:
POP R9
POP R8
POP R5
POP R2
RET

;--------------------------------------------------------------------------------------------------------
verificar_mudanca_sensores:                 ; iniciar a leitura dos sensores caso haja pelo menos 1 evento
PUSH R8
PUSH R9

MOV R2, NUMERO_EVENTOS_SENSORES
MOVB R8, [R2]

CMP R8, 0H
JZ fim_verificar_mudanca_sensores
CALL sensores 

fim_verificar_mudanca_sensores:
POP R9
POP R8
RET
;---------------------------------------------------------------------------------------------------------

verificar_ultimo_sensor:
PUSH R1
PUSH R5

verificar_sensor_8_comboio0:
MOV R5, ultimo_sensor_activo_comboio0       ;valor do sensor pelo qual o comboio passou
CALL sensor_8_comboio

verificar_sensor_8_comboio1:
MOV R5, ultimo_sensor_activo_comboio1 
CALL sensor_8_comboio

verificar_sensor_9_comboio_0:
MOV R5, ultimo_sensor_activo_comboio0
CALL sensor_9_comboio

verificar_sensor_9_comboio1:
MOV R5, ultimo_sensor_activo_comboio1
CALL sensor_9_comboio

verficar_sensor_2_ou_5_comboio0:
MOV R1, COMBOIO_0
MOV R5, ultimo_sensor_activo_comboio0
CALL sensor_2_ou_5_comboio

verficar_sensor_2_ou_5_comboio1:
MOV R1, COMBOIO_1
MOV R5, ultimo_sensor_activo_comboio1
CALL sensor_2_ou_5_comboio

fim_verificar_ultimo_sensor:
POP R5
POP R1
RET

;***************************************************************************************************************************************
; Rotina Auxiliar a Rotina de verificacao 
;***************************************************************************************************************************************
; Processo responsavel por mover para o Registo R8 e R9 os valores do endereco e o valor anterior da tabela respectiva depois de comparar
;
; antes_de_comparar: 
; Argumentos: R4 (contador), R2 (endereco do valor atual ), R5 (com o endereco do valor anterior)
; Retorna: R8 (R8 <- [R2]) , R9 (R9 <- [R5]), R4 (R4 <- R4+1)
;
;***************************************************************************************************************************************


sensor_8_comboio: ; se o comboio passou pelo sensor 8, entao vamos ligar a passagem de nivel, caso contrario nao fazemos nada
PUSH R5
PUSH R8
PUSH R9
MOV R8, [R5]
MOV R9, 08H

CMP R8, R9
JNZ fim_sensor_8_comboio ; se nao for o 8, nao fazemos nada nesta rotina
EI1
EI
CALL ligar_passagem_de_nivel  ; se for o 8 activamos a interrupcao e ligamos a passagem de nivel

fim_sensor_8_comboio:
POP R9
POP R8
POP R5
RET


;----------------------------------------------------------------------------------------------------------------------------------------

ligar_passagem_de_nivel: ; activamos a passagem de nivel, a primeira vez da passagem de nivel so activa um semaforo para a mudanca ser alternada entre os semaforos
PUSH R2
PUSH R3
PUSH R5
PUSH R6
PUSH R7
PUSH R8

MOV R2, flag_interrupcao1_sensores ; se a flag da interrupcao 1 estiver off quer dizer que e a primeira vez que esta activa por isso muda apenas 1 semaforo
MOV R3, valor_interrupcao1 ; se houve uma interrupcao activa este valor vai estar a on
MOV R6, OFF
MOV R7, ON
MOV R8,[R2]
MOV R9,[R3]

CMP R9, OFF
JZ fim_ligar_passagem_de_nivel

CMP R8, OFF
JZ segundo

primeiro:
CALL alterar_o_semaforo_8

segundo:
CALL alterar_o_semaforo_9

MOV [R2], R7                     ; flag interrupcao ON porque ja activou mais de uma vez
MOV [R3], R6                     ; valor da interrupcao foi usado por isso poe a OFF 

fim_ligar_passagem_de_nivel:
POP R8
POP R7
POP R6
POP R5
POP R3
POP R2
RET 
;---------------------------------------------------------------------------------------------------------------------------------------
alterar_o_semaforo_8:
PUSH R3
PUSH R7

MOV R3, valores_semaforos_8_9
MOV R7, VALOR_ALTERAR_SEMAFORO_8
MOV [R3], R7 
CALL semaforos8F

POP R7
POP R3
RET
;----------------------------------------------------------------------------------------------------------------------------------------

alterar_o_semaforo_9:
PUSH R3
PUSH R7

MOV R3, valores_semaforos_8_9
MOV R7, VALOR_ALTERAR_SEMAFORO_9
MOV [R3], R7
CALL semaforos8F
POP R7
POP R3
RET



;----------------------------------------------------------------------------------------------------------------------------------------

sensor_9_comboio:
PUSH R2
PUSH R3
PUSH R5
PUSH R8
PUSH R9
PUSH R10

MOV R2, flag_interrupcao1_sensores ; voltar a por a flag a off, para quando um comboio passar pela primeira vez 
MOV R3, OFF
MOV R8, [R5]
MOV R9, 09H
MOV R10, [R2]

CMP R8, R9
JNZ fim_sensor_9_comboio ; se nao for o 9, nao fazemos nada nesta rotina
CMP R10, R3
JZ fim_sensor_9_comboio ; se ele ja estiver a OFFF nao fazemos nada nesta rotina

repor_os_semaforos_a_cinzento:
CALL por_semaforos_a_cinzento
MOV [R2], R3

fim_sensor_9_comboio:
POP R10
POP R9
POP R8
POP R5
POP R3
POP R2
RET

;---------------------------------------------------------------------------------------------------------------------------------------
sensor_2_ou_5_comboio:
PUSH R0
PUSH R2
PUSH R4
PUSH R5
PUSH R6 
PUSH R7
PUSH R8
PUSH R9
PUSH R10

MOV R0, NENHUM_SENSOR                     ; para apagar o ultimo sensor lido
MOV R2, contador_interrupcao1_paragem     ; um contador que conta o numero de vezes que a interrupcao aconteceu
MOV R4, [R2]
MOV R6, VALOR_3_SEGUNDOS                  ; corresponde a 6, pois 6*1/2 segundo = 3
MOV R7, 0H
MOV R8, [R5]                              ; numero do ultimo sensor activo (vem como argumento)
MOV R9, 02H                               ; ver se o sensor 2 esta ligado
MOV R10, 05H                              ; ver se o sensor 5 esta ligado 

CMP R8, R9 
JZ pre_espera_paragem 

CMP R8, R10
JNZ fim_sensor_2_ou_5_comboio 

pre_espera_paragem:
CMP R4, R6
JNZ inicio_espera_paragem
MOV [R2], R7                            ; por o contador de novo a zero
MOV [R5], R0                            ; apagar o ultimo sensor lido deste comboio para nao voltar a iniciar o loop 

comboio_frente_R1:
MOV R0, R1
MOV R7, VALOR_COMBOIO_A_ANDAR
CALL calcula_e_escreve_valor_comboio
JMP fim_sensor_2_ou_5_comboio

inicio_espera_paragem:
EI1
EI
CALL espera_paragem  ; se for 2 ou 5 iniciamos uma paragem

fim_sensor_2_ou_5_comboio:
POP R10
POP R9
POP R8
POP R7
POP R6
POP R5
POP R4
POP R2
POP R0
RET

;---------------------------------------------------------------------------------------------------------------------------------------
espera_paragem: ;recebe o R1 que determina se é o comboio 1 ou 0 
PUSH R1
PUSH R2
PUSH R3
PUSH R5
PUSH R6
PUSH R7
PUSH R8

MOV R2, contador_interrupcao1_paragem ; se a flag da interrupcao 1 estiver off quer dizer que e a primeira vez que esta activa por isso muda apenas 1 semaforo
MOV R3, valor_interrupcao1 ; se houve uma interrupcao activa este valor vai estar a on
MOV R6, OFF
MOV R8,[R2]
MOV R9,[R3]

CMP R9, OFF                         ;a interrupcao estava a OFF por isso nao fazemos nada.
JZ fim_espera_paragem

CMP R8, 0H
JNZ aumentar_contador_espera            ; se o contador ja tiver sido iniciado, entao ja esta parado, vamos so aumentar o contador

para_o_comboio_R1:
MOV R0, R1
MOV R7, VALOR_COMBOIO_PARADO
CALL calcula_e_escreve_valor_comboio

aumentar_contador_espera:
ADD R8, 1
MOV [R2], R8
MOV [R3], R6                     ; valor da interrupcao foi usado por isso poe a OFF 

fim_espera_paragem:
POP R8
POP R7
POP R6
POP R5
POP R3
POP R2
POP R1
RET


;---------------------------------------------------------------------------------------------------------------------------------------





;******************************************************************************************************************************
; Rotina Auxiliar a mover comboios
;******************************************************************************************************************************
; Processo responsavel por colocar o valor dos sliders (R7) nos respectivos comboios.
;
; Argumentos: R7 (valor do sentido e velocidade do comboio), R0 (valor respectivo ao numero do comboio), 
; Retorna: nada
;
;******************************************************************************************************************************

calcula_e_escreve_valor_comboio:
PUSH R0
PUSH R7
PUSH R8
PUSH R9
PUSH R10

MOV R2, SELECAO_COMBOIO
MOV R3, OPERACAO_COMBOIO
MOV R8,  MASCARA_VELOCIDADE_ANTES_DE_VERIFICAR
MOV R9,  MASCARA_VELOCIDADE_DEPOIS_DE_VERIFICAR
MOV R10, SENTIDO_NEGATIVO_COMBOIO                   ; corresponde ao valor 80H

AND R7, R8                                 ; aplicar a mascara para filtrar os bits desncessarios 
BIT R7, 3                                  ; ler o bit 3 para ver a direcao dele
JZ escreve_comboio                         ; se o bit for zero saltamos para nao por o seu sentido negativo

por_sentido_negativo_do_comboio:                 
ADD R7, R10 

escreve_comboio: 
AND R7,R9                                   ; limpar os bits nao necessarios
MOVB [R2],R0                                ; escolher o comboio e operacao de mudar sentido
MOVB [R3],R7                                ; escrever a mudanca de sentido e velocidade

POP R10
POP R9
POP R8
POP R7
POP R0

RET

;**********************************************************************************************************************
; Semaforos de 0 a 8
;**********************************************************************************************************************
; Processo responsavel pela cor dos semaforos de 0 a 7 atraves dos botoes do teclado de 0 a 7 (Verde/Vermelho)
;
; Rotinas Auxiliares: 
; ver_valor:   calcula o valor a colocar no semaforo 
; proximo_botao:  passamos ao proximo botao ao fazer shift do valor para a direita e acrescentamos 1 ao contador
; escrever_valor: escreve no semaforo e na tabela os valores do semaforo para mudar a cor
;
; R0: valor no endereco do teclado07
; R1: le o teclado de 0 a 7
; R2: le o teclado de 8 a F 
; R3: e o endereco onde vamos escrevever os semaforos
; R4: e um contador que usamos para podermos ver de que semaforo estamos a tratar conforme o numero de shifts feitos
; R5: endereco das tabelas com os valores dos semaforos atuais
; R7: temporario que esta 2 bits a esquerda para estar na posicao do semaforo para se escrever
; R8: valor temporario com o sinal que estava na tabela da cor dos semaforos
; R9: valor da cor verde (semaforo)
; R10: valor da cor vermelha (semaforo)
;***********************************************************************************************************************

semaforos07:
PUSH R0
PUSH R1
PUSH R2
PUSH R3
PUSH R4
PUSH R5
PUSH R6
PUSH R7
PUSH R8
PUSH R9
PUSH R10

MOV R1, TECLADO07
MOV R3, SEMAFOROS
MOV R4, 0H                                  ; inicializar o contador a 0 
MOV R5, cores_semaforos                     ; colocar no argumento R5 da funcao o endereço da tabela 
MOV R9, VERDE
MOV R10, VERMELHO
MOVB R0, [R1]                               ; mover os valores do teclado para R1

verificar_de_existe_sinal_ligado:
CMP R0, 0
JZ fim_semaforos07

ler_botoes_e_escrever_botoes07:
CALL le_botoes

fim_semaforos07:
POP R10
POP R9
POP R8
POP R7
POP R6
POP R5
POP R4
POP R3
POP R2
POP R1
POP R0
RET

;***************************************************************************************************************************
; Rotinas auxiliares aos Semaforos e Agulhas
;***************************************************************************************************************************
; 
; le_botoes:
;      Argumentos: R0 (valor do botoes)
;      Retorna: nada 
;
;
;--------------------------------------------------------------------------------------------------------------------------
; 
; escrever_valor:
;      Argumentos: R4 (contador) R3 ( endereço onde se escreve) R5 (endereço de uma tabela para se escrever) R9 (estado 1) R10 (estado 2)
;      Retorna: Nada
;
; Semaforo 0-7: R9 Verde                             ! R10: Vermelho
; Semaforo 8-9: R9 Cinza                             | R10: Vermelho
; Agulhas:      R9 Direita                           | R10: Esquerda
;
;--------------------------------------------------------------------------------------------------------------------------
;   
; calcula_endereco: 
;         Argumentos: R4 (contador), R5(endereço de uma tabela)
;         Retorna: R5 + R5 (o endereço da tabela contado no contador)
;
;--------------------------------------------------------------------------------------------------------------------------
; 
; ver_estado_da_tabela:
;         Argumentos: R5 (endereco de uma tabela), R9(um valor), R10 (um valor) 
;         Retorna: R8 (com o valor de R9 ou R10 dependente da comparacao de R9 com o valor no [R5])
;
;--------------------------------------------------------------------------------------------------------------------------
; 
; escreve:
;         Argumentos: R3 (endereço de escrita), R4 (contador usado para somar ao R8 e escrever no R3), R5(endereço de escrita de uma tabela), R8(valor a ser escrito na tabela)
;         Retorna: Nada 
;
;
; -------------------------------------------------------------------------------------------------------------------------
; 
; proximo_botao:
;      Argumentos: R4(contador), R0(valor)   
;      Retorna: R4+1(incrementa o contador),  R0->1 (faz um shift right)
;
;***************************************************************************************************************************

le_botoes:
PUSH R0

leitura:
BIT R0,0                                    ; testar o bit 0 que corresponde a verificar se o botao foi carregado 
JNZ muda_valor                              ; se o bit estiver a 1, o botao foi premido por isso mudamos o valor 
CALL proximo_botao                          ; caso contrario passamos ao proximo botao 
JMP leitura

muda_valor:
CALL escrever_valor

POP R0 
RET 

;------------------------------------------------------------------------------------------------------------------------

escrever_valor:
CALL calcula_endereco
CALL ver_estado_da_tabela
CALL escrever

RET 
;-------------------------------------------------------------------------------------------------------------------------

calcula_endereco:
PUSH R4
ADD R5, R4                                  ; somamos o numero de bits que contamos para saber o endereco de estado a que acede
POP R4
RET
;--------------------------------------------------------------------------------------------------------------------------

ver_estado_da_tabela:
PUSH R5
PUSH R9
PUSH R10

MOVB R8, [R5]
CMP R8, R9                                  ; se estiver para a direita, muda para esquerda
JZ mudar_para_R10

mudar_para_R9:
MOV R8, R9
JMP fim_ver_estado_da_tabela

mudar_para_R10:
MOV R8, R10

fim_ver_estado_da_tabela:
POP R10
POP R9
POP R5
RET

;---------------------------------------------------------------------------------------------------------------------------
escrever:
PUSH R3
PUSH R4
PUSH R5
PUSH R7
PUSH R8

MOV R7, R4                                  ; guardar o valor de R4 
SHL R7, 2                                   ; shift em 2 bits do valor de R4 para poder escrever o numero (da agulha/semaforo) correcto 

MOVB [R5], R8                               ; escrever na tabela o sinal decidido 
ADD R7, R8                                  ; atribui o sinal ao semaforo/agulha calculada
MOVB [R3], R7                               ; escreve no semaforo

POP R8
POP R7
POP R5
POP R4
POP R3
RET 

;--------------------------------------------------------------------------------------------------------------------------

proximo_botao:
ADD R4, 1H                                  ; incrementar 1 ao contador
SHR R0, 1                                   ; rodamos para passar ao proximo bit para testar
RET

;***************************************************************************************************************************
; Semaforos de 8 a F
;***************************************************************************************************************************
; Processo responsavel por escrever os valores dos semaforos 8 e 9 consoante os botoes 8 e 9 do teclado
;
; Argumentos: Nenhum
; Retorna: Nada
;
; Rotinas Auxiliares: 
; ver_valor:   calcula o valor a colocar no semaforo 
; proximo_botao:  passamos ao proximo botao ao fazer shift do valor para a direita e acrescentamos 1 ao contador
; escrever_valor: escreve no semaforo e na tabela os valores do semaforo para mudar a cor
;
; R0: valor no endereco do teclado07
; R1: le o teclado de 0 a 7
; R2: le o teclado de 8 a F 
; R3: e o endereco onde vamos escrevever os semaforos
; R4: e um contador que usamos para podermos ver de que semaforo estamos a tratar conforme o numero de shifts feitos
; R5: endereco das tabelas com os valores dos semaforos atuais
; R7: temporario que esta 2 bits a esquerda para estar na posicao do semaforo para se escrever
; R8: valor temporario com o sinal que estava na tabela da cor dos semaforos
; R9: valor da cor cinza (semaforo)
; R10: valor da cor vermelha (semaforo)
;****************************************************************************************************************************
semaforos8F:
PUSH R0
PUSH R1
PUSH R2
PUSH R3
PUSH R4
PUSH R5
PUSH R6
PUSH R7
PUSH R8
PUSH R9
PUSH R10

MOV R2, valores_semaforos_8_9
MOV R3, SEMAFOROS
MOV R4, 8H                                  ; inicializar o contador a 8
MOV R5, cores_semaforos                     ; colocar no argumento R5 da funcao o endereço da tabela 
MOV R6, MASCARA_SEMAFORO_8_9
MOV R9, CINZENTO
MOV R10, VERMELHO
MOV R0, [R2]                               ; mover os valores do teclado para R1
AND R0, R6

CMP R0, 0
JZ fim_semaforos8F


le_botoes_e_muda_semaforo8F:
CALL le_botoes

fim_semaforos8F:
POP R10
POP R9
POP R8
POP R7
POP R6
POP R5
POP R4
POP R3
POP R2
POP R1
POP R0
RET

;****************************************************************************************************************************
; Agulhas
;****************************************************************************************************************************
; Processo responsavel por alterar os valores das agulhas consoante os botoes de pressao 0-3
;
; Argumentos: Nenhum 
; Retorna: Nada 
;
; Rotinas Auxiliares: 
; ver_valor:    calcula o valor a colocar na agulha 
; proximo_botao:  passamos ao proximo botao ao fazer shift do valor para a direita e acrescentamos 1 ao contador (auxiliar dos semaforos)
; escrever_valor: escreve nas agulhas e na tabela os estados das agulhas
;
; R0:  valor no endereco dos botoes de pressao
; R1:  endereco dos Botoes de Pressao
; R2:  - 
; R3:  e o endereco onde vamos escrever os valores para alterar o estado das agulhas
; R4:  e um contador que usamos para podermos ver de que agulha estamos a tratar conforme o numero de shifts feitos
; R5:  endereco das tabelas com os estados das agulhas
; R7:  temporario que esta 2 bits a esquerda para estar na posicao das agulhas para se escrever
; R8:  valor temporario com o estado em que estava a agulha 
; R9:  valor do estado DIREITA
; R10: valor do estado ESQUERDA
;****************************************************************************************************************************

agulhas:

PUSH R0
PUSH R1
PUSH R2
PUSH R3
PUSH R4
PUSH R5
PUSH R6
PUSH R7
PUSH R8
PUSH R9
PUSH R10

MOV R1, BOTOES_PRESSAO
MOV R3, AGULHAS
MOV R4, 0H                                  ; inicializar o contador a 0 
MOV R5, estados_agulhas                     ; movemos o endereco dos estados_agulhas (tabela) para o R5
MOV R6, MASCARA_BOTOES_AGULHAS              ; filtrar os bits maiores que 4 pois apenas temos 4 agulhas
MOV R9, DIREITA
MOV R10, ESQUERDA

MOVB R0, [R1]
AND R0, R6
CMP R0, 0
JZ fim_agulhas                              ; se for 0 entao nao ha valores para atribuir

ler_botoes_pressao:
CALL le_botoes

fim_agulhas:
POP R10
POP R9
POP R8
POP R7
POP R6
POP R5
POP R4

POP R3
POP R2
POP R1
POP R0
RET

;**********************************************************************************************************************************
; Sensores
;**********************************************************************************************************************************
; Processo responsavel pela leitura dos Sensores que transmite ao LCD o sensor por qual cada comboio passou. 
; 
; Argumentos: Nenhum
; Return: Nada
; 
; R0: temporario que recebe o valor 30H que transforma o valor de R9 em codigo ASCII que possa ser lido pelos LCDs como numeros
; R1: Endereco com a informacao dos Sensores
; R2: Endereco do LCD superior (comboio 0)
; R3: Endereco do LCD inferior (comboio 1)
; R8: fica com o primeiro byte das informacoes dos sensores, informacao sobre qual dos comboios passou
; R9: fica com o segundo byte das informacoes dos sensores, o sensor pelo qual o comboio passou
;***********************************************************************************************************************************

sensores:
PUSH R0
PUSH R1
PUSH R2
PUSH R3
PUSH R4
PUSH R5
PUSH R6
PUSH R7
PUSH R8
PUSH R9
PUSH R10

MOV R0, TRANSFORMADOR_ASCII
MOV R1, INFORMACAO_SENSORES
MOVB R8, [R1]                               ; 1º byte (informacão sobre o comboio que passou)
MOVB R9, [R1]                               ; 2º byte (valor do sensor pelo qual passou)
MOV R7, R9                                  ; numero do sensor passado nao transformado em ascii

transformar_para_ascii:
MOV R0, TRANSFORMADOR_ASCII                 ; somar 30H para transformar em codigo ASCII os numeros 0-9
ADD R9,R0

BIT R8, 0                                   ; nao contamos o bit a 1 que e a parte de tras da carruagem 
JNZ fim_sensores

BIT R8, 1                                   ; bit que diz qual o comboio 
JNZ escreve_sensor_comboio_1

escreve_sensor_comboio_0:
MOV R3, LCD_SUPERIOR
MOV R5, ultimo_sensor_activo_comboio0
CALL escreve_sensor
JMP fim_sensores

escreve_sensor_comboio_1:
MOV R3, LCD_INFERIOR
MOV R5, ultimo_sensor_activo_comboio1
CALL escreve_sensor
JMP fim_sensores


escreve_sensores_tras:
BIT R8, 1                                   ; bit que diz qual o comboio 
JNZ escreve_sensor_comboio_1_tras


escreve_sensor_comboio_0_tras:
MOV R5, ultimo_sensor_activo_comboio0_tras
MOV [R5], R7
JMP fim_sensores

escreve_sensor_comboio_1_tras:
MOV R5, ultimo_sensor_activo_comboio_1_tras
MOV [R5], R7

fim_sensores:
POP R10
POP R9
POP R8
POP R7
POP R6
POP R5
POP R4
POP R3
POP R2
POP R1
POP R0
RET

;********************************************************************************************************************************
; Rotinas Auxiliares aos sensores                                                                                                                       ;
;********************************************************************************************************************************

escreve_sensor:
PUSH R7
PUSH R9

MOVB [R3], R9
MOV [R5], R7

POP R9
POP R7
RET

;********************************************************************************************************************************
; Interrupcoes                                                                                                                  ;
;********************************************************************************************************************************

interrupcao0:
RFE

interrupcao1:
PUSH R3
PUSH R7

MOV R7, ON
MOV R3, valor_interrupcao1
MOV [R3], R7

POP R7
POP R3
RFE
