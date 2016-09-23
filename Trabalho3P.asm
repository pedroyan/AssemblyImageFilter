.data

memory_buffer:		.space 4
tamnho_Imagem:		.word 12288
nomeArquivo:		.asciiz "lenaeye.raw"

titulo: 		.asciiz "\n********* Selecione uma opcao *************\n\n"
carregaImagem_menu: 	.asciiz "1 - Carrega imagem\n"
getPixel_menu:	 	.asciiz "2 - Ler Pixel\n"
setPixel_menu: 		.asciiz "3 - Set Pixel\n"
greyFilter_menu: 	.asciiz "4 - 255 Tons de Cinza\n"
exit_menu: 		.asciiz "5 - Exit\n"
input_menu:		.asciiz "Digite o valor correspondente a operacao desejada: "

.text
menu:
	addi $v0, $zero, 4 
	la $a0, titulo 
	syscall
	
	addi $v0, $zero, 4 
	la $a0, carregaImagem_menu 
	syscall
	
	addi $v0, $zero, 4 
	la $a0, getPixel_menu 
	syscall
	
	addi $v0, $zero, 4 
	la $a0, setPixel_menu 
	syscall
	
	addi $v0, $zero, 4 
	la $a0, greyFilter_menu
	syscall
	
	addi $v0, $zero, 4 
	la $a0, exit_menu 
	syscall
	
	addi $v0, $zero, 4 
	la $a0, input_menu
	syscall
	
	li $v0, 5
	syscall 
	
	beq $v0, 1, loadImg 
	#beq $v0, 2, get_pixel # -> get_pixel
	#beq $v0, 3, set_pixel # -> set_pixel
	#beq $v0, 4, grey # -> grey
	beq $v0, 5, exit # -> exit
	
	j menu # loop

loadImg:
	#open
	li $v0, 13
	la $a0, nomeArquivo
	addi $a1,$zero,0
	addi $a2,$zero,0
	syscall
	
	#carrega pro buffer
	move $t2,$v0
	addi $t0,$zero,0x10040000 
	li $t1,0
	la $t3,memory_buffer
	jal LoopBuffer
	j menu
	

LoopBuffer:
	#t0: Area da Heap
	#t1: variavelTemporaria
	#t2: fileDescriptor
	#t3: memoryBuffer
	#v0: Retorno da função fread. se 0 = end of file
	li $v0, 14
	move $a0, $t2
	move $a1,$t3
	addi $a2, $zero, 3
	syscall
	beq $v0, $zero, retorno
	lw $t1, 0($t3)
	sw $t1, 0($t0)
	addi $t0,$t0,4
	j LoopBuffer

retorno:
	jr $ra
exit:
	li $v0,10
	syscall
