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

main:
    li $t0,0
    li $t1,0
    li $t5, 4
    li $t9,0
    jal initTable
    li $t0, 0xFFFFFF
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
