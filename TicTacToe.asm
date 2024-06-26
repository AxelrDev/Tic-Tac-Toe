.data
display: .space 1024
table: .space 36
user: .asciiz "Jugador " #No sirvio
next: .asciiz "\n"
num: .asciiz "Ingresar número de jugada (0-8): "
win: .asciiz "Gana el jugador "
play_again: .asciiz "¿Quieres jugar de nuevo? (s/n): "
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
    li $t5, 4 #Calcula posiciones del tablero
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

    li $t0, 0x00FF00
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
    
# Inicializa el array de jugadas del tablero con 0`s.
initTable:
    sw $t1, table($t0)
    addi $t0,$t0,4
    bne $t0,40,initTable
    
    jr $ra

# Maneja el movimiento del jugador. Verifica si la celda seleccionada está vacía antes de realizar el movimiento. 
#Si la celda está vacía, guarda el número del jugador en la celda correspondiente del tablero. Además, revisa si 
#la entrada está dentro de los limites (0-8) si no vuelve al preguntar.
playerMovement:
    blt $t2, 0, game
    bgt $t2, 8, game
    
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
    li $t7, 0
    li $t2,0
    li $t8,12
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
    
tie:
    addi $t9,$t9,1
    bne $t9,9 finishWinner
    li $v0, 4           
    la $a0, tiePlay
    syscall
    
    j playAgain
   
    
WinnerName:

    li $v0, 4           
    la $a0, win
    syscall
    
    li $v0, 1            
    move $a0, $t4        
    syscall
    
    li $v0, 4           
    la $a0, next
    syscall
    
playAgain:

    li $v0, 4               
    la $a0, play_again      
    syscall                 

    li $v0, 12              
    syscall    
    move $t1,$v0
    
    li $v0, 4           
    la $a0, next
    syscall
            
    li $t0, 's'            
    beq $t1, $t0, replayTable      
   
    j exit 
    
finishWinner:
    jr $ra

#Solicita y procesa la entrada del usuario. Imprime mensajes solicitando la entrada del usuario y lee el número 
#ingresado. Actualiza el registro $t2 con el valor leído.
userInput:


    li $v0, 4           
    la $a0, user
    syscall
    
    li $v0, 4           
    la $a0, player
    syscall
    
    li $v0, 1            
    move $a0, $t4        
    syscall
    
    li $v0, 4           
    la $a0, next
    syscall
    
    li $v0, 4            
    la $a0, num       
    syscall

    li $v0, 5           
    syscall
    move $t2, $v0      
    
    jr $ra  

#Alterna entre los jugadores. Cambia el jugador actual alternando entre el jugador 1 y el jugador 2. 
changePlayer:
    beq $t4,1, player2
player1:
li $t0, 0x00FF00
li $t4, 1
j finishPlayer

player2:
li $t0, 0xFFFF00
li $t4, 2

finishPlayer:
jr $ra

#Selecciona la celda correspondiente al movimiento. Calcula la posición en el display para la celda seleccionada por el 
#jugador. Ajusta las coordenadas para dibujar el movimiento en la pantalla.
selected:
    blt $t2, 3, firstLine
    blt $t2, 6, secondLine
    blt $t2, 9, ThirdLine

firstLine:
    li $t1, 136
    j draw
secondLine:
    li $t1, 396
    j draw
ThirdLine:
    li $t1, 720
    j draw
    
draw:
    mult $t2,$t3
    mflo $t2
    add $t1,$t1,$t2 
    j finishSelectd
    
finishSelectd:
    jr $ra


#Dibuja el movimiento en la pantalla. Escribe el color correspondiente en la posición calculada del display.
drawMovement:
    sw $t0, display($t1)
    jr $ra

#Dibuja líneas verticales en el tablero. Dibuja una línea vertical en la posición especificada del display. 
#Repite el proceso hasta completar la línea. 
createVerticalLine:
    sw $t0, display($t1)
    addi $t1, $t1, 64
    blt $t1, 1024, createVerticalLine
    
    jr $ra
    
#Dibuja líneas horizontales en el tablero. Dibuja una línea horizontal en la posición especificada del display. 
#Repite el proceso hasta completar la línea. 
createHorizontalLine:
    sw $t0, display($t1)
    addi $t1, $t1, 4
    addi $t2, $t2, 1
    bne $t2, 16, createHorizontalLine
    
    jr $ra

#Reinicia display a color negro   
replayTable:
    li $t1, 0
    li $t0, 0x000000               
replayTableLoop:
   sw $t0, display($t1)
   addi $t1, $t1,4
   beq $t1,1024,main
   
   j replayTableLoop
               

exit:
    li $v0, 10
    syscall
