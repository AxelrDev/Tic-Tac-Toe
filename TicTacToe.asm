.data
display: .space 1024 #Para el bitmap
table: .space 36 #Para las respuestas de las casillas
user: .asciiz "Jugador " #No sirvio
next: .asciiz "\n"
num: .asciiz "Ingresar nÃºmero de jugada (0-8): "
win: .asciiz "Gana el jugador "
play_again: .asciiz "Â¿Quieres jugar de nuevo? (s/n): "
player: .asciiz "Jugador "
tiePlay: .asciiz "Empate \n"

.text
.globl main

#Es el punto de entrada del programa. Este inicializa el juego llamando a initTable y llama las funciones correspondientes para 
#crear el tablero. Además, junto con Game realiza la lógica principal del juego, donde pide la entrada al usuario, coloca la ficha 
#y revisa el ganador.
main:
    li $t0,0
    li $t1,0
    li $t5, 4   #Calcula posiciones del tablero
    li $t9,0 # Contador de jugadas
    jal initTable
    li $t0, 0xFFFFFF #Blanco 
    li $t1, 20
    jal createVerticalLine
    li $t1, 320
    li $t2, 0
    jal createHorizontalLine
    li $t1, 40
    jal createVerticalLine
    li $t1, 640
    li $t2, 0
    jal createHorizontalLine

    li $t0, 0x00FF00  #Para el primero jugador(verde)
    li $t4, 1
#realiza la lógica principal del juego, donde pide la entrada al usuario, coloca la ficha, cambia de usuario y revisa el ganador.
game:
    li $t3, 20  #calcula los desplazamientos en el tablero
    jal userInput
    jal playerMovement
    jal selected
    jal drawMovement
    jal winner
    jal changePlayer
    
    j game
# Inicializa el tablero y deja el espacio con 0`s.
initTable:
    sw $t1, table($t0)
    addi $t0,$t0,4
    bne $t0,40,initTable
# Maneja el movimiento del jugador. Verifica si la celda seleccionada está vacía antes de realizar el movimiento. 
#Si la celda está vacía, guarda el número del jugador en la celda correspondiente del tablero. Además, revisa si 
#la entrada está dentro de los limites (0-8) si no vuelve al preguntar.
playerMovement:
    blt $t2, 0, game #limite
    bgt $t2, 8, game #limite
    
    mult $t2,$t5
    mflo $t1
    lw $t6, table($t1)
    bge $t6,1,game
    sw $t4, table($t1)
    jr $ra
#Verifica si hay un ganador. Verifica si algún jugador ha ganado comprobando las filas, columnas y diagonales. 
#Si encuentra tres celdas consecutivas con el mismo valor, declara al ganador. Además, revisa si hay empate y 
#pregunta si desea reiniciar el juego. 
winner:
    li $t7, 0 #contador de celdas consecutivas
    li $t2,0 # contador de celdas
    li $t8,12 #desplazamiento a la siguiente linea
verifyLine:
    lw $t6, table($t2)
    bne $t6,$t4, nextLine
    addi $t2,$t2,4
    addi $t7,$t7,1
    beq  $t7,3, WinnerName
    j verifyLine
nextLine:
    move $t2,$t8
    bgt $t2,40,column
    li $t7,0
    addi $t8,$t8,12
    j verifyLine
    
column:
    li $t7, 0
    li $t2,0
    li $t8,4

verifyColumn:
    lw $t6, table($t2)
    bne $t6,$t4, nextColumn
    addi $t2,$t2,12
    addi $t7,$t7,1
    beq  $t7,3, WinnerName
    j verifyColumn
nextColumn:
    move $t2,$t8
    bgt $t2,40,diagonal
    li $t7,0
    addi $t8,$t8,4
    j verifyColumn
diagonal:
    li $t7, 0
    li $t2,0
    li $t8,16
verifyDiagonal:
    lw $t6, table($t2)
    bne $t6,$t4, nextDiagonal
    add $t2,$t2,$t8
    addi $t7,$t7,1
    beq  $t7,3, WinnerName
    j verifyDiagonal
nextDiagonal:
    subi $t8,$t8,8
    move $t2,$t8
    beq $t8,0,tie
    li $t7,0
    j verifyDiagonal
