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

DESOCUPADO EQU 0H							              ; quando o troco se encontra desocupado
OCUPADO EQU 1H								                ; quando o troco se encontra ocupado
RESERVADO EQU 2H

NENHUM EQU 0H
OFF EQU 0H
ON EQU 1H

MASCARA_VELOCIDADE_ANTES_DE_VERIFICAR  EQU 0BH
MASCARA_VELOCIDADE_DEPOIS_DE_VERIFICAR EQU 83H                                                                        
MASCARA_BOTOES_AGULHAS EQU 0FH                    ; filtrar os bits que nao sejam os primeiros 4 das agulhas, pois so temos 4 agulhas para mudar 
MASCARA_SEMAFORO_8_9 EQU 3H                      ; filtrar os bits que nao sejam os primeiros 2 pois so temos 2 semaforos, 8 e 9

VALOR_COMBOIO_A_ANDAR EQU 03H             ; corresponde a 00000011b
VALOR_COMBOIO_PARADO EQU 00H

VALOR_ALTERAR_SEMAFORO_8 EQU 1H
VALOR_ALTERAR_SEMAFORO_9 EQU 2H

NUMERO_SEMAFORO_8 EQU 8H
NUMERO_SEMAFORO_9 EQU 9H

VALOR_3_SEGUNDOS EQU 6H                         ; 3 segundos correspondem a 6 vezes meio segundo

NENHUM_SENSOR EQU 0FFFFH

POSICAO_SEGUINTE EQU 0FFFFH
POSICAO_ACTUAL EQU 0FFFFH
POSICAO_ANTERIOR EQU 0FFFFH

VALOR_SENSOR_0 EQU 0H
VALOR_SENSOR_1 EQU 1H
VALOR_SENSOR_2 EQU 2H
VALOR_SENSOR_3 EQU 3H
VALOR_SENSOR_4 EQU 4H
VALOR_SENSOR_5 EQU 5H
VALOR_SENSOR_6 EQU 6H
VALOR_SENSOR_7 EQU 7H
VALOR_SENSOR_8 EQU 8H
VALOR_SENSOR_9 EQU 9H 

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

tabela_estados_troco:
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

valores_semaforos_0_7: ; tabela usada para alterar a cor dos semaforos
  WORD NENHUM

valores_semaforos_8_9: ; tabela usada para atribuir os valores aos semaforos
  WORD NENHUM 

ultimo_sensor_activo_comboio0_paragem: ; endereço onde guardamos o ultimo sensor pelo qual o comboio 0 passou endereço 
  WORD NENHUM 

ultimo_sensor_activo_comboio1_paragem: ; endereço onde guardamos o ultimo sensor pelo qual o comboio 1 passou que ficou registado para a paragem 
  WORD NENHUM

ultimo_sensor_comobio0_interrupcao: 
  WORD NENHUM 

ultimo_sensor_comboio1_interrupcao:
  WORD NENHUM

valor_interrupcao1: ; esta a off se a interrupcao estiver desligada, esta a on se a interrupcao estiver ligada
  WORD OFF

flag_interrupcao1_sensores: ; esta a off se for a primeira vez que se inicia a interrupcao
  WORD OFF

contador_interrupcao1_paragem: ; um contador que incrementa para contar o tempo que o comboio passa na estacao 
  WORD NENHUM

localizacao_comboio0:
  WORD POSICAO_SEGUINTE
  WORD POSICAO_ACTUAL 
  WORD POSICAO_ANTERIOR                                    

localizacao_comboio1:
  WORD POSICAO_SEGUINTE 
  WORD POSICAO_ACTUAL
  WORD POSICAO_ANTERIOR






;**************************************************************************************************************************************
;======================================================== Programa Principal ====~=====================================================
;**************************************************************************************************************************************
PLACE 0000H
MOV SP, SP_inicial
MOV BTE, tabela_interrupcoes

start:
  MOV  R0, 2                ; interrupção 0 activa enquanto houver eventos por ler ao nível 1
  MOV RCN, R0               ;(para não se perderem eventos caso surjam em sequência rápida e o programa não tenha tempo para os tratar logo que ocorram).   
     EI0                           ; faz enable da interrupcao zero
     EI                            
  CALL inicializar_comboios
  CALL por_semaforos_a_cinzento

ciclo:
  CALL verificar_mudanca_agulhas
  CALL verificar_mudanca_sensores
  CALL verificar_ultimo_sensor
  CALL verificar_alteracoes_posicao_e_estados
JMP ciclo







;**************************************************************************************************************************************
;======================================================== Rotinas de inicialização ====================================================
;**************************************************************************************************************************************
inicializar_comboios:
PUSH R0 
  MOV R0, COMBOIO_0             ;inicializa o comboio 0 com velocidade 3 sentido sentido positivo 
  CALL comboio_frente_R0
  MOV R0, COMBOIO_1
  CALL comboio_frente_R0        ; incializa o comboio 1 com velocidade 3 no sentido positivo 
POP R0
RET
;------------------------------------------------------------------------------------------------------

por_semaforos_a_cinzento:
PUSH R3
PUSH R4
PUSH R5
PUSH R8
  MOV R8, CINZENTO
  por_semaforo_8_a_cinzento:
    MOV R4, NUMERO_SEMAFORO_8
    CALL alterar_valor_semaforos
  por_semaforo_9_a_cinzento:
    MOV R4, NUMERO_SEMAFORO_9
    CALL alterar_valor_semaforos
POP R8
POP R5
POP R4
POP R3
RET
;---------------------------------------------------------------------------------------
alterar_valor_semaforos: ; R4 = numero do semaforo a ser mudado 
PUSH R3
PUSH R5
  MOV R3, SEMAFOROS 
  MOV R5, cores_semaforos
  CALL calcula_endereco
  CALL escrever 
POP R5 
POP R3 
RET 












;**************************************************************************************************************************************
;======================================================= verificar_mudanca_agulhas ====================================================
;**************************************************************************************************************************************
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
  MOV [R5], R8                                   ; actualiza o valor anterior 
  CALL agulhas
fim_verificar_mudanca_agulhas:
POP R9
POP R8
POP R5
POP R2
RET

;****************************************************************************************************************************
; Agulhas
;****************************************************************************************************************************
; Processo responsavel por alterar os valores das agulhas consoante os botoes de pressao 0-3
;
; Argumentos: Nenhum 
; Retorna: Nada 
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
  verificar_se_um_dos_4_butoes_foi_premido:
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

;=========================================================================================================

le_botoes:
PUSH R0
  leitura:
    BIT R0,0                                    ; testar o bit 0 que corresponde a verificar se o botao foi carregado 
      JNZ fim_le_butoes                              ; se o bit estiver a 1, o botao foi premido por isso mudamos o valor 
    CALL proximo_botao                          ; caso contrario passamos ao proximo botao 
    JMP leitura
  fim_le_butoes:
    CALL calcula_endereco
    CALL ver_estado_da_tabela
    CALL escrever
POP R0 
RET 
;-----------------------------------

proximo_botao:
  ADD R4, 1H                                  ; incrementar 1 ao contador
  SHR R0, 1                                   ; rodamos para passar ao proximo bit para testar
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
  verificar_mudanca_estado_tabela:
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
  mover_2_bits_para_escrever:
    MOV R7, R4                                  ; guardar o valor de R4 
    SHL R7, 2                                   ; shift em 2 bits do valor de R4 para poder escrever o numero (da agulha/semaforo) correcto 
  escrever_o_valor_na_tabela_e_endereco:
    MOVB [R5], R8                               ; escrever na tabela o sinal decidido 
    ADD R7, R8                                  ; atribui o sinal ao semaforo/agulha calculada
    MOVB [R3], R7                               ; escreve no semaforo/agulha
POP R8
POP R7
POP R5
POP R4
POP R3
RET 






















;**************************************************************************************************************************************
;======================================================= verificar_mudanca_sensores ====================================================
;**************************************************************************************************************************************

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

;**********************************************************************************************************************************
; Sensores
;**********************************************************************************************************************************
; Processo responsavel pela leitura dos Sensores que transmite ao LCD o sensor por qual cada comboio passou. 
; 
; Argumentos: Nenhum
; Return: Nada
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
    MOV R5, ultimo_sensor_activo_comboio0_paragem
    CALL escreve_sensor
    JMP fim_sensores
  escreve_sensor_comboio_1:
    MOV R3, LCD_INFERIOR
    MOV R5, ultimo_sensor_activo_comboio1_paragem
    CALL escreve_sensor
    JMP fim_sensores
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

;------------------------

escreve_sensor:
PUSH R7
PUSH R9
  MOVB [R3], R9
  MOV [R5], R7
POP R9
POP R7
RET
















;**************************************************************************************************************************************
;======================================================= verificar_ultimo_sensor ======================================================
;**************************************************************************************************************************************





;****************************************************************************************************************************************
; Rotina responsavel por controlar a actividade dos sensores e as suas consequencias 
;****************************************************************************************************************************************
; Argumentos : Nenhum            | Retorna: Nada 
;****************************************************************************************************************************************

verificar_ultimo_sensor:
PUSH R0
PUSH R5
  verificar_sensores_comboio0:
    MOV R0, COMBOIO_0
    MOV R5, ultimo_sensor_activo_comboio0_paragem       ;valor do sensor pelo qual o comboio passou
    CALL sensor_8_comboio
    CALL sensor_9_comboio
    CALL sensor_2_ou_5_comboio

  verificar_sensor_8_comboio1:
    MOV R0, COMBOIO_1
    MOV R5, ultimo_sensor_activo_comboio1_paragem 
    CALL sensor_8_comboio
    CALL sensor_9_comboio
    CALL sensor_2_ou_5_comboio
fim_verificar_ultimo_sensor:
POP R5
POP R0
RET

;****************************************************************************************************************************************
; Rotina do Sensor 8 passado pelo comboio (verifica se o ultimo sensor pelo qual o comboio foi o 8, se for entao liga passagem de nivel)
;****************************************************************************************************************************************
; Argumentos: R5 ( endereço com o numero do ultimo sensor pelo qual o comboio passou), R0 (numero do comboio)
; Retorna: Nada 
;****************************************************************************************************************************************
sensor_8_comboio: ; se o comboio passou pelo sensor 8, entao vamos ligar a passagem de nivel, caso contrario nao fazemos nada
PUSH R5
PUSH R8
PUSH R9
  MOV R8, [R5]
  MOV R9, VALOR_SENSOR_8

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


;****************************************************************************************************************************************
; Rotina Liga Passagem de Nivel (responsavel por alternar entre vermelho e cinzento a passagem de nivel)
;****************************************************************************************************************************************
; Argumentos: nenhum                  | retorna: Nada 
;****************************************************************************************************************************************
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
    JZ alterar_o_semaforo_9

  alterar_o_valor_semaforo8:
    MOV R0, VALOR_ALTERAR_SEMAFORO_8 
    CALL alterar_o_semaforo_8_9           ;rotina que vai alterar o valor dos semaforos em funcao do valor de R0
  alterar_o_semaforo_9:
    MOV R0, VALOR_ALTERAR_SEMAFORO_9
    CALL alterar_o_semaforo_8_9
  
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
;****************************************************************************************************************************************
; Rotina de alteracao dos semaforos 
;****************************************************************************************************************************************
; Argumentos: R0 (valor que altera o semaforo)
;****************************************************************************************************************************************
alterar_o_semaforo_8_9:
PUSH R0
PUSH R3
  MOV R3, valores_semaforos_8_9
  MOV [R3], R0
  CALL semaforos8F
POP R3
POP R0
RET

;****************************************************************************************************************************************
; Rotina do sensor 9 (verifica se o comboio passou pelo sensor 9 e se sim, desliga a passagem de nivel e poe os semaforos 8-9 a cinzento)
;****************************************************************************************************************************************
; Argumentos: R5 (ultimo sensor pelo qual o comoboio passou)
;****************************************************************************************************************************************
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
  MOV R9, VALOR_SENSOR_9
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

;***************************************************************************************************************************************
; rotinas auxiliares a verificacao dos sensores 
;***************************************************************************************************************************************
; Argumentos: R5 (endereço que contem o valor do ultimo sensor pelo qual o comboio passou), R0 (numero do comboio)
; Retorna: Nada 
;***************************************************************************************************************************************
sensor_2_ou_5_comboio:
PUSH R2
PUSH R4
PUSH R5
PUSH R6 
PUSH R8
PUSH R9
PUSH R10
  MOV R2, valor_interrupcao1     ; um contador que conta o numero de vezes que a interrupcao aconteceu
  MOV R4, [R2]
  MOV R6, ON
  MOV R8, [R5]                              ; numero do ultimo sensor activo (vem como argumento)
  MOV R9, VALOR_SENSOR_2                               ; ver se o sensor 2 esta ligado
  MOV R10, VALOR_SENSOR_5                              ; ver se o sensor 5 esta ligado 

  CMP R8, R9 
    JZ pre_espera_paragem 
  CMP R8, R10
    JNZ fim_sensor_2_ou_5_comboio
  pre_espera_paragem:
    EI1
    EI
    CMP R4, R6
      JNZ fim_sensor_2_ou_5_comboio
  CALL temporizador
  CALL espera_paragem  ; se for 2 ou 5 iniciamos uma paragem
fim_sensor_2_ou_5_comboio:
POP R10
POP R9
POP R8
POP R6
POP R5
POP R4
POP R2
RET

;****************************************************************************************************************************************
; Rotina temporizador ( incrementa um contador numa word em funcao da interrupcao 1)
;****************************************************************************************************************************************
; Argumentos: Nenhum                         | Retorna: Nada 
;****************************************************************************************************************************************
temporizador: ;incrementar o contador_interrupcao1_paragem e poe a OFF a word da interrupcao 
PUSH R2 
PUSH R3
PUSH R4
PUSH R7
  MOV R2, contador_interrupcao1_paragem
  MOV R3, valor_interrupcao1
  MOV R4, [R2]
  MOV R7, OFF

  ADD R4, 1
  MOV [R2], R4
  MOV [R3], R7
POP R7
POP R4
POP R3
POP R2
RET

;****************************************************************************************************************************************
; Rotina que espera na paragem ( responsavel pelo comboio estar para ou arrancar da paragem 5 ou 2)
;****************************************************************************************************************************************
; Argumentos R0 (Numero do Comboio) R5( numero do ultimo sensor activo )
;****************************************************************************************************************************************
espera_paragem: ;recebe o R1 que determina se é o comboio 1 ou 0 
PUSH R1
PUSH R2
PUSH R3
PUSH R5
  MOV R1, NENHUM_SENSOR                 ; valor que apaga o ultimos sensor 
  MOV R2, contador_interrupcao1_paragem ; se a flag da interrupcao 1 estiver off quer dizer que e a primeira vez que esta activa por isso muda apenas 1 semaforo
  MOV R3, 0H
  MOV R4,[R2]

  CMP R4,1
    JNZ verificar_contador
  para_o_comboio_na_paragem:
    CALL para_comboio_R0
    JMP fim_espera_paragem

  verificar_contador:
    CMP R4, 6
      JNZ fim_espera_paragem
  reiniciar_contador:
    MOV [R2], R3                            ; por o contador de novo a zero
    MOV [R5], R1                            ; apagar o ultimo sensor lido deste comboio para nao voltar a iniciar o loop 
  retornar_marcha_comboio:
    CALL comboio_frente_R0
fim_espera_paragem:
POP R5
POP R3
POP R2
POP R1
RET

































;**************************************************************************************************************************************
;=================================================== verificar_alteracoes_posicao_e_estados ===========================================
;**************************************************************************************************************************************
verificar_alteracoes_posicao_e_estados:
PUSH R8
PUSH R9 
  MOV R8, NUMERO_EVENTOS_SENSORES
  MOV R9, 0H
  CMP R8, R9 
    JZ fim_verificacao_alteracoes
  CALL actualizar_posicao_comboios
  CALL actualizar_estado_trocos
fim_verificacao_alteracoes:
POP R9
POP R8
RET 

;****************************************************************************************************************************************
; Rotina de Actualizar posicoes dos comboios (responsavel por encontrar a posição actual e anterior dos comboios)
;****************************************************************************************************************************************
; Argumentos: Nenhum      | Retorna: Nada  
;****************************************************************************************************************************************
actualizar_posicao_comboios:
PUSH R1
PUSH R2 
PUSH R3
PUSH R5
  actualizar_posicao_comboio0:
    MOV R1, localizacao_comboio0
    MOV R5, ultimo_sensor_comobio0_interrupcao
    CALL actualiza_posicao 
  actualizar_posicao_comboio1:
    MOV R1, localizacao_comboio1 
    MOV R5, ultimo_sensor_comboio1_interrupcao
    CALL actualiza_posicao 
fim_actualizar_posicao_comboios:
POP R5
POP R3
POP R2
POP R1
RET

;----------------------------------------------------------------------------------------

actualiza_posicao:   ;R1 endereco da tabela da localizaçao seguinte ; R5 ultimo sensor activo pelo comboio 
PUSH R1 
PUSH R2
PUSH R3
PUSH R5 
PUSH R7
PUSH R8
PUSH R9
PUSH R10 
  buscar_enderecos_da_tabela:
  MOV R2,R1              ;  2º endereço da tabela (posicao actual)                        
  ADD R2, 2
  MOV R3, R2
  ADD R3, 2              ; 3º endereço da tabela (posição anterior)
  
  MOV R7, [R2]
  MOV R8, [R1]
  MOV R9, [R5] 
  MOV R10, VALOR_SENSOR_7

  CMP R9, R10
  JGT fim_actualiza_posicao

  CMP R8, R9
  JZ fim_actualiza_posicao

  MOV [R3], R7                              ; actualiza o valor anterior para o valor que ate agora era o presente 
  MOV [R2], R8 
  MOV [R1], R9                              ; actualiza o valor actual para o novo valor actual 
fim_actualiza_posicao:
POP R10 
POP R9
POP R8
POP R7 
POP R5
POP R3
POP R2
POP R1  
RET  




;****************************************************************************************************************************************
; Rotina que actualiza o estado dos troços
;****************************************************************************************************************************************
;
;****************************************************************************************************************************************

actualizar_estado_trocos:
PUSH R0
PUSH R2
PUSH R3 
PUSH R5
PUSH R6
PUSH R7
  MOV R5, localizacao_comboio0
  MOV R6, tabela_estados_troco
  MOV R1, [R5]                      ; valor da localizacao actual do comboio 
  ADD R5, 2                         ; endereco do valor anterior 
  MOV R2, [R5]                      ; valor da localizacao anterior do comboio 
  ADD R5, 2
  MOV R3, [R5]
  reserver_o_troco_seguinte:
    MOV R7, RESERVADO
    MOV R0, R1
    CALL alterar_o_troco 
  ocupar_o_troco_actual:
    MOV R7, OCUPADO
    MOV R0, R2                          ; colocar a localizacao do comboio no argumento R0 
    CALL alterar_o_troco
  desocupar_o_troco_anterior:
    MOV R7, DESOCUPADO                  ; o estado R7 entra como argumento na alteracao do troco 
    MOV R0, R3                          ; colocar a localizacao do comboio no argumento R0 
    CALL alterar_o_troco 
fim_actualizar_estado_trocos:
POP R7
POP R6
POP R5
POP R3
POP R2
POP R0 
RET 


;-------------------------------------
alterar_o_troco: ; Argumentos: R0(numero do troco), R6(endereco dos estados dos trocos), R7 (estado a escrever) 
PUSH R0
PUSH R4
PUSH R6
PUSH R7 
PUSH R8

  ADD R6, R0               ;  soma o numero do troco a tabela para obter o endereco de escrita na tabela do correcto troco 
  MOV R8, [R6]
  CMP R8, R7                ; se o valor a escrever for igual ao que ja la esta, entao nao escrevemos 
    JZ fim_alterar_troco 
  
  MOV [R6], R7              ; Ocupa ou Desocupa o Troco 
  CALL alterar_semaforo_correspondente
  MOV R4, R0
  CALL debugging_lights 
fim_alterar_troco:
POP R8
POP R7
POP R6
POP R4
POP R0
RET 
;-------------------------------------

alterar_semaforo_correspondente: ; Argumentos: R0 (numero do semaforo) R7 (estado a escrever do troco)
PUSH R0
PUSH R3
PUSH R4 
PUSH R7 
PUSH R8 
  CMP R7, OCUPADO
    JZ por_semaforo_a_vermelho
  por_semaforo_a_verde:
    MOV R8, VERDE
    MOV R4, R0
    CALL alterar_valor_semaforos 
    JMP fim_alterar_semaforo_correspondente
  por_semaforo_a_vermelho:
    MOV R8, VERMELHO
    MOV R4, R0
    CALL alterar_valor_semaforos
fim_alterar_semaforo_correspondente:
POP R8
POP R7
POP R4
POP R3
POP R0 
RET 














;**************************************************************************************************************************************
;================================================ Rotinas Auxiliares ao Programa ======================================================
;**************************************************************************************************************************************
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
  MOV R4, 8H                                  ; inicializar o contador a 8
  MOV R5, cores_semaforos                     ; colocar no argumento R5 da funcao o endereço da tabela 
  MOV R6, MASCARA_SEMAFORO_8_9
  MOV R9, CINZENTO
  MOV R10, VERMELHO
  verificar_se_os_4_butoes_foram_premidos:
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


debugging_lights:
PUSH R3 
PUSH R4 
MOV R3, 8010H
  cmp_0_1: 
    CMP R4, 2
      JGT cmp2
    MOV [R3], R4
    JMP fim_debugging_lights
  cmp2:
    CMP R4, 2H
      JNZ cmp3
    MOV R4, 4H
    MOV [R3], R4
    JMP fim_debugging_lights
  cmp3:
    CMP R4, 3H
      JNZ cmp4
    MOV R4,8H
    MOV [R3],R4 
    JMP fim_debugging_lights 
  cmp4:
    CMP R4, 4H
      JNZ cmp5
    MOV R4, 10H
    MOV [R3], R4
    JMP fim_debugging_lights
  cmp5:
    CMP R4, 5H
      JNZ cmp6
    MOV R4, 20H
    MOV [R3], R4
    JMP fim_debugging_lights
  cmp6:
    CMP R4, 6H
      JNZ cmp7
    MOV R4, 40H
    MOV [R3], R4
    JMP fim_debugging_lights
  cmp7:
    CMP R4, 7H
      JNZ fim_debugging_lights
    MOV R4, 80H
    MOV [R3], R4
fim_debugging_lights:
POP R4
POP R3
RET 


;*****************************************************************************************************************************
; Rotina de controle do comboio 
;*****************************************************************************************************************************
; Argumentos: R0 (numero do comboio a ser controlado)      |  Retorna: Nada 
;*****************************************************************************************************************************
para_comboio_R0:
PUSH R7
  MOV R7, VALOR_COMBOIO_PARADO
  CALL calcula_e_escreve_valor_comboio
POP R7 
RET 
;------------------------------------------------------------------------------------------------------------------------------
comboio_frente_R0:
PUSH R7
  MOV R7, VALOR_COMBOIO_A_ANDAR
  CALL calcula_e_escreve_valor_comboio
POP R7
RET 

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
  filtrar_e_verificar_bit:
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

;********************************************************************************************************************************
; Interrupcoes                                                                                                                  ;
;********************************************************************************************************************************

interrupcao0:
PUSH R1
PUSH R2 
PUSH R3
MOV R3, INFORMACAO_SENSORES
MOVB R1, [R3]
MOVB R2, [R3]
  BIT R1, 0                                   ; nao contamos o bit a 1 que e a parte de tras da carruagem 
    JNZ fim_interrupcao0
  BIT R1, 1                                   ; bit que diz qual o comboio 
    JNZ sensor_comboio_1
  sensor_comboio_0: 
  MOV R3, ultimo_sensor_comobio0_interrupcao
  MOV [R3], R2
  JMP fim_interrupcao0
  sensor_comboio_1:
  MOV R3, ultimo_sensor_comboio1_interrupcao
  MOV [R3], R2 

fim_interrupcao0:
POP R3
POP R2
POP R1 
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
