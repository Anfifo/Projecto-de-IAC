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

SELECAO_COMBOIO     EQU 8018H                     ; (W) endereço de escrita que escolhe comboio e a operacao a executar sobre este
OPERACAO_COMBOIO    EQU 801AH                     ; (W) endereço de escrita onde alteramos o sentido e velocidade do comboio seleccionado na operacao de comboios
BARRAS_VELOCIDADE   EQU 8004H                     ; (R) endereço de leitura dos "sliders" (superior e inferior) do controle dos comboios

TECLADO07 EQU 8006H                               ; (R) endereço de leitura das teclas de 0 a 7, cada posicao do bit corresponde a um semaforo 7654 3210
TECLADO8F EQU 8008H                               ; (R) endereço de leitura das teclas de 0 a 15, cada posicao do bit corresponde a um semaforo **** **98
SEMAFOROS EQU 8012H                               ; (W) endereço de escrita que altera os semaforos, Os bits 7 a 2 indicam o número do semáforo. Os bits 1 e 0 indicam a cor

BOTOES_PRESSAO  EQU 800CH                         ; (R) endereço de leitura dos botoes de pressao, a 1 on, 0 off
AGULHAS         EQU 8016H                         ; (W) endereço de escrita dos estados da agulhas de 7 a 2 numero agulha, 1-0 estado da agulha (01=esquerda 10=direita)

NUMERO_EVENTOS_SENSORES EQU 801CH                 ; (R) le o numero de eventos lidos pelos sensores, cada evento corresponde a 2 valores no porto na INFORMACAO_SENSORES
INFORMACAO_SENSORES     EQU 801EH                 ; (R) le a informacao dada pelo sensor, qual
LCD_SUPERIOR  EQU 8000H                           ; (W) escreve informacao no LCD superior 
LCD_INFERIOR  EQU 8002H                           ; (W) escrever informacao no LCD inferior

COMBOIO_0 EQU 0H                                  ; Valor que corresponde ao comboio numero 0 (azul)
COMBOIO_1 EQU 10H                                 ; Valor que corresponde ao comboio numero 1 (verde)
SENTIDO_NEGATIVO_COMBOIO EQU 80H                  ; Valor que corresponde ao sentido negativo de um comboio

ESQUERDA EQU 1H                                   ; Valor do estado da agulha quando esta em modo "esquerda"
DIREITA  EQU 2H                                   ; Valor do estado da agulha quando esta em modo "direita"

CINZENTO EQU 0H                                   ; Valor da cor Cinzenta no semaforo
VERMELHO EQU 1H                                   ; Valor da cor Vermelha no semaforo
VERDE    EQU 2H                                   ; Valor da cor Verde no semaforo30H                 

TRANSFORMADOR_ASCII EQU 30H                       ; Valor necessario para no sensor transformar a informacao correcta ASCII dos numeros

DESOCUPADO EQU 0H                                 ; quando o troco se encontra desocupado
OCUPADO EQU 1H                                    ; quando o troco se encontra ocupado
RESERVADO EQU 2H

NENHUM EQU 0H
OFF EQU 0H
ON EQU 1H

MASCARA_VELOCIDADE_ANTES_DE_VERIFICAR  EQU 0BH
MASCARA_VELOCIDADE_DEPOIS_DE_VERIFICAR EQU 83H                                                                        
MASCARA_BOTOES_AGULHAS EQU 0FH                   ; filtrar os bits que nao sejam os primeiros 4 das agulhas, pois so temos 4 agulhas para mudar 
MASCARA_SEMAFORO_8_9 EQU 3H                      ; filtrar os bits que nao sejam os primeiros 2 pois so temos 2 semaforos, 8 e 9

VALOR_COMBOIO_A_ANDAR EQU 03H                    ; corresponde a 00000011b
VALOR_COMBOIO_PARADO EQU 00H

VALOR_ALTERAR_SEMAFORO_8 EQU 1H
VALOR_ALTERAR_SEMAFORO_9 EQU 2H

NUMERO_SEMAFORO_8 EQU 8H
NUMERO_SEMAFORO_9 EQU 9H

VALOR_3_SEGUNDOS EQU 6H                          ; 3 segundos correspondem a 6 vezes meio segundo

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

pilha:      TABLE 200H                          ; espaco reservado para a pilha (200H bytes, pois sao 100H words)
SP_inicial:                                     ; este e o endereco (1200H) com que o SP deve ser inicializado.
                                                ; O 1º end. de retorno será armazenado em 11FEH (1200H-2H)

estados_agulhas:                                ; tabela para os estados das agulhas (DIREITA e ESQUERDA).
                                                ; 01 ESQUERDA, 10 DIREITA
  STRING    DIREITA                             ; agulha 0
  STRING    DIREITA                             ; agulha 1
  STRING    DIREITA                             ; agulha 2
  STRING    DIREITA                             ; agulha 3

cores_semaforos:                                ; tabela para as cores dos semáforos (VERDE, CINZENTO ou VERMELHO).
                                                ; 00 cinzento, 01 vermelho, 10 verde, 11 amarelo.
  STRING    VERDE                               ; cor do semáforo 0
  STRING    VERDE                               ; cor do semáforo 1
  STRING    VERDE                               ; cor do semáforo 2
  STRING    VERDE                               ; cor do semáforo 3
  STRING    VERDE                               ; cor do semáforo 4
  STRING    VERDE                               ; cor do semáforo 5
  STRING    VERDE                               ; cor do semáforo 6
  STRING    VERDE                               ; cor do semáforo 7
  STRING    VERDE                               ; cor do semáforo 8
  STRING    VERDE                               ; cor do semáforo 9

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

valor_velocidade_comboio0:
  WORD VALOR_COMBOIO_A_ANDAR

valor_velocidade_comboio1:
  WORD VALOR_COMBOIO_A_ANDAR

valores_semaforos_8_9:                          ; tabela usada para atribuir os valores aos semaforos
  WORD NENHUM 

ultimo_sensor_activo_comboio0:                  ; endereço onde guardamos o ultimo sensor pelo qual o comboio 0 passou
  WORD NENHUM 

ultimo_sensor_activo_comboio0_tras:             ; endereco onde guardamos o ultimo sensor pela qual a traseira do comboio 0 passou
  WORD NENHUM

ultimo_sensor_activo_comboio1:                  ; endereço onde guardamos o ultimo sensor pelo qual o comboio 1 passou
  WORD NENHUM

ultimo_sensor_activo_comboio_1_tras:            ; endereço no qual guardamos o ultimo sensor pelo qual a traseira do comboio 1 passou
  WORD NENHUM

valor_interrupcao1:                             ; esta a off se a interrupcao estiver desligada, esta a on se a interrupcao estiver ligada
  WORD OFF

flag_interrupcao1_sensores:                     ; esta a off se for a primeira vez que se inicia a interrupcao
  WORD OFF

contador_interrupcao1_paragem:                  ; contador de tempo
  WORD 0H

posicao_seguinte_comboio0:                      ; posicao para qual o comboio se dirige
  WORD NENHUM_SENSOR
posicao_actual_comboio0:                        ; posicao na qual o comboio esta actualmente 
  WORD NENHUM_SENSOR
posicao_anterior_comboio0:                      ; posicao da qual o comboio veio 
  WORD NENHUM_SENSOR                       

posicao_seguinte_comboio1:
  WORD NENHUM_SENSOR
posicao_actual_comboio1:
  WORD NENHUM_SENSOR
posicao_anterior_comboio1:
  WORD NENHUM_SENSOR       


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

ciclo:
CALL verificar_mudanca_agulhas
CALL verificar_mudanca_sensores
CALL verificar_ultimo_sensor
CALL actualizar_posicao_comboios
CALL gerir_circulacao_comboios

JMP ciclo








;**************************************************************************************************************************************
;======================================================= Rotinas de Inicializacao =====================================================
;**************************************************************************************************************************************


;**************************************************************************************************************
; processo responsavel por iniciar o movimento dos comboios com velocidade 3
; Argumentos: Nenhum             | Retorna: Nada
;***************************************************************************************************************
inicializar_comboios:
PUSH R0 
  MOV R0, COMBOIO_0                         ;inicializa o comboio 0 com velocidade 3 sentido sentido positivo 
  CALL comboio_frente_R0
  MOV R0, COMBOIO_1
  CALL comboio_frente_R0                    ; incializa o comboio 1 com velocidade 3 no sentido positivo 
POP R0
RET
;**************************************************************************************************************
; Rotina reponsavel por parar o movimento dos comboios
; Argumentos: R0 (numero do comboio) | Retorna: Nada 
;***************************************************************************************************************
para_comboio_R0:
PUSH R7
  MOV R7, VALOR_COMBOIO_PARADO
  CALL calcula_e_escreve_valor_comboio
POP R7 
RET 
;**************************************************************************************************************
; Rotina responsavel por colocar o comboio R0 em movimento (velocidade 3)
; Argumentos: R0 (numero do comboio) | Retorna: Nada 
;***************************************************************************************************************
comboio_frente_R0:
PUSH R7
  MOV R7, VALOR_COMBOIO_A_ANDAR
  CALL calcula_e_escreve_valor_comboio
POP R7
RET 
;**************************************************************************************************************
; Rotina responsavel por inicializar os semaforos 8 e 9 a cinzento 
; Argumentos: Nenhum              | Retorna: Nada 
;***************************************************************************************************************
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
;**************************************************************************************************************
; Rotina responsavel por alterar o valor de um semaforo
; Argumentos : R4 (numero do semaforo a ser mudado)    | Retorna: Nada 
;***************************************************************************************************************
alterar_valor_semaforos:          ; R4 = numero do semaforo a ser mudado 
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
;=================================================== Verificar mudança das agulhas ====================================================
;**************************************************************************************************************************************

;**************************************************************************************************************
; Rotina responsavel por verificar alteracao das agulhas e chamar esta caso haja diferença 
; Argumentos: Nenhum              | Retorna: Nada 
;***************************************************************************************************************
verificar_mudanca_agulhas:                  
PUSH R2
PUSH R5
PUSH R8
PUSH R9
  MOV R2, BOTOES_PRESSAO
  MOV R5, valores_anteriores_agulhas
  MOVB R8, [R2]
  MOV R9, [R5]
  comparar_valor_anterior_das_agulhas_com_o_actual:
    CMP R8,R9
      JZ fim_verificar_mudanca_agulhas                  ; caso nao haja mudanca saltamos para os Sensores
    MOV [R5], R8                                        ; escreve na tabela o valor anterior
    CALL agulhas
fim_verificar_mudanca_agulhas:
POP R9
POP R8
POP R5
POP R2
RET
;***************************************************************************************************************
; Rotina responsavel por alterar as agulhas 
; Argumentos: Nenhum            | Retorna: Nada 
;***************************************************************************************************************
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
  MOV R4, 0H                                            ; inicializar o contador a 0 
  MOV R5, estados_agulhas                               ; movemos o endereco dos estados_agulhas (tabela) para o R5
  MOV R6, MASCARA_BOTOES_AGULHAS                        ; filtrar os bits maiores que 4 pois apenas temos 4 agulhas
  MOV R9, DIREITA
  MOV R10, ESQUERDA

  comparar_mudanca_agulhas:
    MOVB R0, [R1]
    AND R0, R6                                          ; aplicar a mascara para ter a certeza que so trabalhamos com os 4 bits dos 4 botoes 
    CMP R0, 0
      JZ fim_agulhas                                    ; se for 0 entao nao ha valores para atribuir
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
;**************************************************************************************************************
; Responsavel por executar a leitura de botoes representados em forma de numero 
; Argumentos: R0 (valor/numero a ser lido)      | Retorna: nada 
;***************************************************************************************************************
le_botoes:
PUSH R0
  leitura:
    BIT R0,0                                          ; testar o bit 0 que corresponde a verificar se o botao foi carregado 
      JNZ muda_valor                                  ; se o bit estiver a 1, o botao foi premido por isso mudamos o valor 
    CALL proximo_botao                                ; caso contrario passamos ao proximo botao 
    JMP leitura
  muda_valor:
    CALL calcula_endereco
    CALL ver_estado_da_tabela
    CALL escrever
POP R0 
RET 
;**************************************************************************************************************
; Rotina responsavel por contar o numero de vezes que fazemos shift a um numero. (contador)
; Argumentos: R4 (contador/numero de vezes feito shift), R0 (numero ao qual fazemos shift) 
; Retorna: R4 ( R4 <- R4+1 ), R0 (SHR R0,1)
;***************************************************************************************************************
proximo_botao:
  ADD R4, 1H                                          ; incrementar 1 ao contador
  SHR R0, 1                                           ; rodamos para passar ao proximo bit para testar
RET
;**************************************************************************************************************
; Rotina responsavel por calcular um endereço de uma tabela com base num numero (contador/R4)
; Argumentos: R4 (contador), R5 (endereço de um tabela)  | Retorna: R4 (R4 <- R4+R5) 
;***************************************************************************************************************
calcula_endereco:
PUSH R4
  ADD R5, R4                                          ; somamos o numero de bits que contamos para saber o endereco de estado a que acede
  POP R4
RET
;**************************************************************************************************************
; Rotina responsavel por comparar 3 valores e retornar o que seja diferente dos outros 2
; Argumentos: R5 (endereço de uma tabela/valor), R9 (um valor), R10 (outro valor)   
; Retorna: R8 (com o valor que seja diferente do valor em [R5])
;***************************************************************************************************************
ver_estado_da_tabela:
PUSH R5
PUSH R9
PUSH R10
  MOVB R8, [R5]
  CMP R8, R9                                          ; se o valor de [R5] for R10, ele retorna o R9 (e vice versa)
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
;**************************************************************************************************************
; Rotina responsavel por escrever o valor calculado (R7) num endereço de escrita(R3) e numa tabela(R5) 
; Argumentos: R4 (contador/numero do semaforo/agulha), R5(endereço da tabela), R8 (cor/estado a ser escrito/somado)
; Retorna: Nada 
;***************************************************************************************************************
escrever:
PUSH R3
PUSH R4
PUSH R5
PUSH R7
PUSH R8

  MOV R7, R4                                        ; guardar o valor de R4 
  SHL R7, 2                                         ; shift em 2 bits do valor de R4 para poder escrever o numero (da agulha/semaforo) correcto 
  MOVB [R5], R8                                     ; escrever na tabela o estado/cor decidido/a  
  ADD R7, R8                                        ; atribui o sinal ao semaforo/agulha calculada
  MOVB [R3], R7                                     ; escreve no semaforo
POP R8
POP R7
POP R5
POP R4
POP R3
RET 
;**************************************************************************************************************



















;**************************************************************************************************************************************
;======================================================== Verificar Mudanca Sensores ==================================================
;**************************************************************************************************************************************

;**************************************************************************************************************
; Rotina responsavel por verificar se existiram eventos, caso existam, chama a rotina para guardar os sensores 
; Argumentos: Nenhum              | Retorna: Nada 
;***************************************************************************************************************
verificar_mudanca_sensores:                       ; iniciar a leitura dos sensores caso haja pelo menos 1 evento
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
; Processo responsavel pela leitura dos Sensores que transmite ao LCD o sensor por qual cada comboio passou.  
; Argumentos: Nenhum          | Retorna: Nada
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
  MOVB R8, [R1]                                 ; 1º byte (informacão sobre o comboio que passou)
  MOVB R9, [R1]                                 ; 2º byte (valor do sensor pelo qual passou)
  MOV R7, R9                                    ; numero do sensor passado nao transformado em ascii
  transformar_para_ascii:
    MOV R0, TRANSFORMADOR_ASCII                 ; somar 30H para transformar em codigo ASCII os numeros 0-9
    ADD R9,R0

  decidir_accao_sobre_os_sensores:
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
;**************************************************************************************************************
; Rotina responsavel por escrever o sensor nos endereços correctos 
; Argumentos: R3(endereco do LCD), R5(endereço para escrever o numero do sensor), R7 (numero do sensor), R9(numero ascii)
; Retorna: Nada 
;***************************************************************************************************************
escreve_sensor:
PUSH R7
PUSH R9
  MOVB [R3], R9
  MOV [R5], R7
POP R9
POP R7
RET
;**************************************************************************************************************
















;**************************************************************************************************************************************
;================================================== Verificar Ultimo Sensor activo ====================================================
;**************************************************************************************************************************************

;**************************************************************************************************************
; Rotina responsavel por ver se o ultimos sensor pelo qual o comboio  passou foi o 2,5,8 ou 9
; Argumentos: Nenhum        | Retonar: Nada 
;***************************************************************************************************************
verificar_ultimo_sensor:
PUSH R1
PUSH R5
  verificar_sensores_comboio0:
    MOV R0, COMBOIO_0
    MOV R5, ultimo_sensor_activo_comboio0
    CALL sensor_8_comboio
    CALL sensor_9_comboio
    CALL sensor_2_ou_5_comboio 
  verificar_sensores_comboio1:
    MOV R0, COMBOIO_1
    MOV R5, ultimo_sensor_activo_comboio1
    CALL sensor_8_comboio
    CALL sensor_9_comboio
    CALL sensor_2_ou_5_comboio
fim_verificar_ultimo_sensor:
POP R5
POP R1
RET
;**************************************************************************************************************
; Rotina responsavel por verificar se o comboio passou pelo sensor 8, se sim, activa a passagem de nivel 
; Argumentos: R0(numero do comboio), R5(endereço com o numero do ultimo sensor) | Retorna: Nada 
;***************************************************************************************************************
sensor_8_comboio:                               ; se o comboio passou pelo sensor 8, entao vamos ligar a passagem de nivel, caso contrario nao fazemos nada
PUSH R5
PUSH R8
PUSH R9
  MOV R8, [R5]
  MOV R9, 08H
  verificar_se_passou_pelo_sensor_8:
    CMP R8, R9
      JNZ fim_sensor_8_comboio                  ; se nao for o 8, nao fazemos nada nesta rotina
    EI1
    EI
    CALL ligar_passagem_de_nivel                ; se for o 8 activamos a interrupcao e ligamos a passagem de nivel
fim_sensor_8_comboio:
POP R9
POP R8
POP R5
RET
;**************************************************************************************************************
; Rotina responsavel pelo funcionamento dos semaforos da passagem de nivel enquanto o comboio esta entre o sensor 8 e 9
; Argumentos: Nenhum |Retorna: Nada 
;***************************************************************************************************************
ligar_passagem_de_nivel:                        ; activamos a passagem de nivel, a primeira vez da passagem de nivel so activa um semaforo para a mudanca ser alternada entre os semaforos
PUSH R2
PUSH R3
PUSH R5
PUSH R6
PUSH R7
PUSH R8
  MOV R2, flag_interrupcao1_sensores            ; se a flag da interrupcao 1 estiver off quer dizer que e a primeira vez que esta activa por isso muda apenas 1 semaforo
  MOV R3, valor_interrupcao1                    ; se houve uma interrupcao activa este valor vai estar a on
  MOV R6, OFF
  MOV R7, ON
  MOV R8,[R2]
  MOV R9,[R3]
  ver_flag_e_valor:
    CMP R9, OFF
      JZ fim_ligar_passagem_de_nivel
    CMP R8, OFF
      JZ segundo
  primeiro:
    CALL alterar_o_semaforo_8
  segundo:
    CALL alterar_o_semaforo_9
  MOV [R2], R7                                  ; flag interrupcao ON porque ja activou mais de uma vez
  MOV [R3], R6                                  ; valor da interrupcao foi usado por isso poe a OFF 
fim_ligar_passagem_de_nivel:
POP R8
POP R7
POP R6
POP R5
POP R3
POP R2
RET 
;**************************************************************************************************************
; Rotina responsavel por alterar a cor do semaforo 8
; Argumentos: Nenhum      | Retorna: Nada 
;***************************************************************************************************************
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
;**************************************************************************************************************
; Rotina responsavel por alterar a cor do semaforo 9
; Argumentos: Nenhum     | Retorna: Nada
;***************************************************************************************************************
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
;**************************************************************************************************************
; Rotina responsavel por verificar se o ultimo sensor pelo qual o comboio passou é o 9, se sim desliga a passagem de nivel
; Argumentos: R0 (numero do comboio), R5(endereço com o valor do ultimo sensor por onde passou)   |Retorna: Nada
;***************************************************************************************************************
sensor_9_comboio:
PUSH R2
PUSH R3
PUSH R5
PUSH R8
PUSH R9
PUSH R10
  MOV R2, flag_interrupcao1_sensores         ; voltar a por a flag a off, para quando um comboio passar pela primeira vez 
  MOV R3, OFF
  MOV R8, [R5]
  MOV R9, 09H
  MOV R10, [R2]
  decidir_accao_por_comparacao:
    CMP R8, R9
      JNZ fim_sensor_9_comboio                ; se nao for o 9, nao fazemos nada nesta rotina
    CMP R10, R3
      JZ fim_sensor_9_comboio                 ; se ele ja estiver a OFFF nao fazemos nada nesta rotina
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
;**************************************************************************************************************
; Rotina responsavel por verificar se o comboio esta numa paragem (sensor 2 ou 5), se sim, obriga este a parar 3segundos
; Argumentos: R0 (numero do comboio), R5(endereco do ultimo sensor)   | Retorna: Nada 
;***************************************************************************************************************
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
  MOV R2, valor_interrupcao1                  ; um contador que conta o numero de vezes que a interrupcao aconteceu
  MOV R4, [R2]
  MOV R6, ON
  MOV R8, [R5]                                ; numero do ultimo sensor activo (vem como argumento)
  MOV R9, VALOR_SENSOR_2                      ; ver se o sensor 2 esta ligado
  MOV R10, VALOR_SENSOR_5                     ; ver se o sensor 5 esta ligado 
  verificar_se_esta_numa_paragem:
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
  CALL espera_paragem                         ; se for 2 ou 5 iniciamos uma paragem
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
;**************************************************************************************************************
; Rotina responsavel por contar o tempo atraves da interrupcao 1 que activa a cada 1/2 segundo.
; Argumentos: Nenhum  | Retorna:  [R2] <- [R2]+1  ,   [R3] <- OFF
;***************************************************************************************************************
temporizador:                                 ; incrementar o contador_interrupcao1_paragem e poe a OFF a word da interrupcao 
PUSH R2 
PUSH R3
PUSH R4
PUSH R7
  MOV R2, contador_interrupcao1_paragem
  MOV R3, valor_interrupcao1
  MOV R4, [R2] 
  MOV R7, OFF
  incrementar_o_contador_de_tempo:
    ADD R4, 1                                 ; incrementa o valor do contador de tempo     
    MOV [R2], R4
    MOV [R3], R7                              ; consome uma interrupcao para incrementar o tempo, por isso coloca a valor dela a OFF
POP R7
POP R4
POP R3
POP R2
RET
;**************************************************************************************************************
; Rotina responsavel por parar ou por o comboio a andar dependendo do contador (verifica se o tempo ja passou)
; Argumentos: R1 (numero do comboio)     | Retorna: Nada 
;***************************************************************************************************************
espera_paragem:                               ; recebe o R1 que determina se é o comboio 1 ou 0 
PUSH R1
PUSH R2
PUSH R3
PUSH R5
PUSH R6
PUSH R7
PUSH R8
  MOV R1, NENHUM_SENSOR
  MOV R2, contador_interrupcao1_paragem       ; se a flag da interrupcao 1 estiver off quer dizer que e a primeira vez que esta activa por isso muda apenas 1 semaforo
  MOV R3, 0H
  MOV R4,[R2]
  MOV R6, VALOR_3_SEGUNDOS
  verifica_se_esta_no_inicio:
    CMP R4,1                                  ; se o contar estiver a 1 entao, estamos no incio e entao paramos o comboio 
      JNZ verificar_contador
    para_o_comboio_R0:
      MOV R7, VALOR_COMBOIO_PARADO
      CALL calcula_e_escreve_valor_comboio
      JMP fim_espera_paragem
  verificar_contador:
    CMP R4, R6                                ; ve se o contador ja chegou a 6 (o que corresponde a 3 segundos), se sim entao
      JNZ fim_espera_paragem 
  dar_reset_ao_sensor_e_contador_e_por_comboio_a_andar:
    MOV [R2], R3                              ; por o contador de novo a zero
    MOV [R5], R1                              ; apagar o ultimo sensor lido deste comboio para nao voltar a iniciar o loop 
    poe_comboio_frente_R0:
      MOV R7, VALOR_COMBOIO_A_ANDAR
      CALL calcula_e_escreve_valor_comboio
fim_espera_paragem:
POP R8
POP R7
POP R6
POP R5
POP R3
POP R2
POP R1
RET





;****************************************************************************************************************************************
;============================================= actualizar_posicao_comboios ==============================================================
;****************************************************************************************************************************************


;****************************************************************************************************************************************
; Rotina de Actualizar posicoes dos comboios (responsavel por encontrar a posição actual e anterior dos comboios)
; Argumentos: Nenhum      | Retorna: Nada  
;****************************************************************************************************************************************
actualizar_posicao_comboios:
PUSH R0
PUSH R1
PUSH R2 
PUSH R3
PUSH R5
PUSH R7
PUSH R8 
PUSH R9
  actualizar_posicao_comboio0:                   ; mover os enderecos para os registos para poderem ser usados
    MOV R0, COMBOIO_0
    MOV R1, posicao_seguinte_comboio0
    MOV R2, posicao_actual_comboio0
    MOV R3, posicao_anterior_comboio0
    MOV R5, ultimo_sensor_activo_comboio0
    CALL actualiza_posicao 
  actualizar_posicao_comboio1:
    MOV R0, COMBOIO_1
    MOV R1, posicao_seguinte_comboio1
    MOV R2, posicao_actual_comboio1
    MOV R3, posicao_anterior_comboio1  
    MOV R5, ultimo_sensor_activo_comboio1
    CALL actualiza_posicao 
fim_actualizar_posicao_comboios:
POP R9
POP R8
POP R7
POP R5
POP R3
POP R2
POP R1
POP R0 
RET

;******************************************************************************************************************
; Rotina 
; Argumentos: R1 (endereço da tabela da localização seguinte), R5(ultimo sensor activo pelo comboio)
; Retorna: Nada 
;******************************************************************************************************************
actualiza_posicao: 
PUSH R1 
PUSH R2
PUSH R3
PUSH R5 
PUSH R10 
  buscar_enderecos_da_tabela:
    MOV R7, [R5]                               ; novo valor seguinte 
    MOV R8, [R1]                               ; novo valor actual  
    MOV R9, [R2]                               ; novo valor anterior 
    MOV R10, VALOR_SENSOR_8
  comparacoes:
    CMP R9, R10
      JGT fim_actualiza_posicao                ; so ha 8 trocos e o sensor 8 nao conta como troço
    CMP R7, R8
      JZ fim_actualiza_posicao                 ; se a posicao a escrever for a mesma que era antes, entao nao escrevemos 
  actualizacao_dos_valores:
    MOV [R3], R9                               ; actualiza o valor anterior  
    MOV [R2], R8                               ; actualiza o valor actual
    MOV [R1], R7                               ; actualiza o valor seguinte 
  CALL actualizar_estado_trocos                ; chamar rotina que actualiza os estados dos trocos 
fim_actualiza_posicao:
POP R10 
POP R5
POP R3
POP R2
POP R1  
RET  

;**************************************************************************************************************
; Rotina responsavel por actualizar os estados dos trocos. 
; Argumentos: R7(valor da localizacao seguinte), R8(valor da localizacao actual) ,R9(valor da localizacao anteriior)   
; Retorna: Nada 
;***************************************************************************************************************
actualizar_estado_trocos:
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
  MOV R6, tabela_estados_troco
  reserver_o_troco_seguinte:
    MOV R10, R7
    CALL verificar_estado_troco_seguinte 
  ocupar_o_troco_actual:
    MOV R7, OCUPADO
    MOV R10, R8                             ; colocar a localizacao do comboio no argumento R0 
    CALL alterar_o_troco
  desocupar_o_troco_anterior:
    MOV R7, DESOCUPADO                      ; o estado R7 entra como argumento na alteracao do troco 
    MOV R10, R9                             ; colocar a localizacao do comboio no argumento R0 
    CALL alterar_o_troco 
fim_actualizar_estado_trocos:
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

;**************************************************************************************************************
; Rotina que verifica se o comboio pode ou nao avancar para o seguinte troco, caso nao possa para este. 
; Argumentos: R0 (numero do comboio), R6(tabela dos trocos), R10 (posicao/troco)  | Retorna: Nada 
;***************************************************************************************************************
verificar_estado_troco_seguinte: 
PUSH R6
PUSH R8
PUSH R9
PUSH R10 
  ADD R6, R10                               ; somamos a tabela dos trocos o numero do troco de que estamos a tratar 
  MOV R8, [R6]
  MOV R9, OCUPADO 
  ver_se_o_troco_esta_ocupado:              ; se o troco seguinte esta ocupado o comboio para 
    CMP R8,R9 
      JNZ fim_verificar_estado_troco
    CALL para_comboio_R0 
fim_verificar_estado_troco:
POP R10
POP R9
POP R8
POP R6
RET 

;**************************************************************************************************************
; Rotina responsavel pela alteracao dos trocos 
; Argumentos: R0(numero do troco), R6(endereco dos estados dos troco), R7(estado a escrever)  | Retorna: Nada 
;***************************************************************************************************************
alterar_o_troco:  
PUSH R0
PUSH R4
PUSH R6
PUSH R7 
PUSH R8
  ADD R6, R0                               ;  soma o numero do troco a tabela para obter o endereco de escrita na tabela do correcto troco 
  MOV R8, [R6]
  CMP R8, R7                               ; se o valor a escrever for igual ao que ja la esta, entao nao escrevemos 
    JZ fim_alterar_troco 
  MOV [R6], R7                             ; Ocupa ou Desocupa o Troco 
  CALL alterar_semaforo_correspondente
fim_alterar_troco:
POP R8
POP R7
POP R6
POP R4
POP R0
RET 

;**************************************************************************************************************
; Rotina responsavel por alterar o semaforo do troco em questao 
; Argumentos: R0 (numero do semaforo/troco), R7(estado a escrever no troco)  | Retorna: Nada 
;***************************************************************************************************************
alterar_semaforo_correspondente: 
PUSH R0
PUSH R3
PUSH R4 
PUSH R7 
PUSH R8 
PUSH R9
  MOV R9, VALOR_SENSOR_8  
  CMP R0, R9
    JZ fim_alterar_semaforo_correspondente ; nao nos interessa se for o troco 8 pois é a passagem de nivel 
  CMP R7, OCUPADO                          ; se o troco estiver ocupado pomos o semaforo a vermelho 
    JZ por_semaforo_a_vermelho
  por_semaforo_a_verde:
    MOV R8, VERDE                          ; caso contrario pomos o semaforo a verde 
    MOV R4, R0
    CALL alterar_valor_semaforos 
    JMP fim_alterar_semaforo_correspondente
  por_semaforo_a_vermelho:
    MOV R8, VERMELHO
    MOV R4, R0
    CALL alterar_valor_semaforos
fim_alterar_semaforo_correspondente:
POP R9 
POP R8
POP R7
POP R4
POP R3
POP R0 
RET 









;****************************************************************************************************************************************
;================================================ Gerir Circulacao Comboios ==============================================================
;****************************************************************************************************************************************


;**************************************************************************************************************
; Rotina que gere a circulacao de comboios que ve quando os comboios que pararam num vermelho podem avancar 
; Argumentos: Nenhum  | Retorna: Nada 
;***************************************************************************************************************

gerir_circulacao_comboios:
RET 

MOV R5, tabela_estados_troco
MOV R6, posicao_seguinte_comboio0
MOV R9, OCUPADO
MOV R10, DESOCUPADO


MOV R4, [R6] 
ADD R5, R6

MOV R8, [R5]
CMP R8, R9

MOV R6, posicao_seguinte_comboio1










;**************************************************************************************************************************************
;==================================================== Rotinas Auxiliares ao Programa ==================================================
;**************************************************************************************************************************************


;**************************************************************************************************************
; Rotina responsavel por alterar a velocidade/direccao de um comboio
; Argumentos: R0 (numero do comboio), R7 (valor a colocar no comboio)    | Retorna: Nada 
;***************************************************************************************************************
calcula_e_escreve_valor_comboio:
PUSH R0
PUSH R3
PUSH R7
PUSH R8
PUSH R9
PUSH R10
  MOV R2, SELECAO_COMBOIO
  MOV R3, OPERACAO_COMBOIO
  MOV R8,  MASCARA_VELOCIDADE_ANTES_DE_VERIFICAR
  MOV R9,  MASCARA_VELOCIDADE_DEPOIS_DE_VERIFICAR
  MOV R10, SENTIDO_NEGATIVO_COMBOIO                 ; corresponde ao valor 80H
  filtra_bits_desncessarios:
    AND R7, R8                                      ; aplicar a mascara para filtrar os bits desncessarios 
    BIT R7, 3                                       ; ler o bit 3 para ver a direcao dele
    JZ escreve_comboio                              ; se o bit for zero saltamos para nao por o seu sentido negativo
    por_sentido_negativo_do_comboio:                 
      ADD R7, R10 
  escreve_comboio: 
    AND R7,R9                                       ; limpar os bits nao necessarios
    MOVB [R2],R0                                    ; escolher o comboio e operacao de mudar sentido
    MOVB [R3],R7                                    ; escrever a mudanca de sentido ou velocidade
  
  guarda_valor_da_velocidade:
    MOV R8, COMBOIO_1
    CMP R0, R8
      JZ guarda_comboio1
    guarda_comboio0:                                ; guarda a velocidade do comboio numa word para sabermos se esta parado ou a andar
      MOV R3, valor_velocidade_comboio0
      MOV [R3], R7
      JMP fim_calcula_e_escreve_valor_comboio
    guarda_comboio1:
      MOV R3, valor_velocidade_comboio1
      MOV [R3], R7 
fim_calcula_e_escreve_valor_comboio:
POP R10
POP R9
POP R8
POP R7
POP R3 
POP R0
RET


;***************************************************************************************************************************
; Processo responsavel por escrever os valores dos semaforos 8 e 9
; Argumentos: Nenhum    | Retorna: Nada
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
  MOV R4, 8H                                      ; inicializar o contador a 8
  MOV R5, cores_semaforos                         ; colocar no argumento R5 da proxima funcao o endereço da tabela 
  MOV R6, MASCARA_SEMAFORO_8_9
  MOV R9, CINZENTO
  MOV R10, VERMELHO
  MOV R0, [R2]                                    ; mover os valores da word valores_semaforos_8_9 para o R0 
  AND R0, R6
  verifica_se_ha_mudanca_a_aplicar:
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


;********************************************************************************************************************************
; Interrupcoes                                                                                                                  ;
;********************************************************************************************************************************

interrupcao0:
RFE

;interrupcao0:                                    ; apesar de bem feita, foi impossivel o uso desta interrupção pois por alguma razao havia conflicto com a interrupcao do clock 
;PUSH R1                      
;PUSH R2 
;PUSH R3

;MOV R3, INFORMACAO_SENSORES
;MOVB R1, [R3]
;MOVB R2, [R3]
;  BIT R1, 0                                      ; nao contamos o bit a 1 que e a parte de tras da carruagem 
;    JNZ parte_tras
;  parte_frente:
;  BIT R1, 1                                      ; bit que diz qual o comboio 
;    JNZ sensor_comboio_1
;    sensor_comboio_0: 
;      MOV R3, ultimo_sensor_comboio0_interrupcao
;      MOV [R3], R2
;      JMP fim_interrupcao0
;    sensor_comboio_1:
;      MOV R3, ultimo_sensor_comboio1_interrupcao
;      MOV [R3], R2  
;      JMP fim_interrupcao0
;
;  parte_tras:
;  BIT R1, 1                                      ; escreve a parte de tras 
;    JNZ sensor_comboio_1_tras 
;    sensor_comboio_0_tras: 
;      MOV R3, ultimo_sensor_comboio0_interrupcao_parte_tras
;      MOV [R3], R2
;      JMP fim_interrupcao0
;    sensor_comboio_1_tras:
;      MOV R3, ultimo_sensor_comboio1_interrupcao_parte_tras
;      MOV [R3], R2
;fim_interrupcao0:
;POP R3
;POP R2
;POP R1 
;RFE


;**************************************************************************************************************
; Interrupcao que coloca o valor ON numa word para avisar que esta foi activa e depois pode ser consumida para
; incrementar o contador de tempo 
; Argumentos: Nada  | Retorna: Nada 
;***************************************************************************************************************

interrupcao1:
PUSH R3
PUSH R7
  MOV R7, ON
  MOV R3, valor_interrupcao1
  MOV [R3], R7
POP R7
POP R3
RFE
