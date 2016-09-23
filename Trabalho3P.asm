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
digiteValorX:		.asciiz "\nDigite o valor de X:"
digiteValorY:		.asciiz "\nDigite o valor de Y:"
digiteValorR:		.asciiz "\nDigite o valor de R:"
digiteValorG:		.asciiz "\nDigite o valor de G:"
digiteValorB:		.asciiz "\nDigite o valor de B:"
red:			.asciiz "\nRed:"
green:			.asciiz "\nGreen:"
blue:			.asciiz "\nBlue:"

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
	beq $v0, 2, getPixel 
	beq $v0, 3, setPixel 
	beq $v0, 4, grey 
	beq $v0, 5, exit 
	
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
	
	#fecha arquivo
	move $a0,$t2
	li $v0,16
	syscall
	j menu
	
getPixel:
	addi $v0, $zero, 4 
	la $a0, digiteValorX
	syscall
	
	li $v0, 5
	syscall
	move $t0,$v0
	
	addi $v0, $zero, 4 
	la $a0, digiteValorY
	syscall
	
	li $v0, 5
	syscall
	move $a1,$v0
	move $a0,$t0
	addi $a2,$zero,0x10040000
	jal GetPixelAddress
	
	lbu $t0,2($v0) #red
	lbu $t1,1($v0) #green
	lbu $t2,0($v0) #Blue
	
	addi $v0, $zero, 4 
	la $a0, red 
	syscall
	
	addi $v0, $zero, 1 
	move $a0, $t0 
	syscall
	
	addi $v0, $zero, 4 
	la $a0, green 
	syscall
	
	addi $v0, $zero, 1 
	move $a0, $t1 
	syscall
	
	addi $v0, $zero, 4 
	la $a0, blue 
	syscall	
	
	addi $v0, $zero, 1 
	move $a0, $t2 
	syscall
	
	j menu

setPixel:
	addi $v0, $zero, 4 
	la $a0, digiteValorX
	syscall
	
	li $v0, 5
	syscall
	move $t0,$v0
	
	addi $v0, $zero, 4 
	la $a0, digiteValorY
	syscall
	
	li $v0, 5
	syscall
	move $a1,$v0
	move $a0,$t0
	addi $a2,$zero,0x10040000
	jal GetPixelAddress
	
	move $t4,$v0
	
	#t3: MemoryBuffer
	#t4: PixelAddress
	la $t3, memory_buffer
	sw $zero,0($t3) # zera buffer
	
	addi $v0, $zero, 4 
	la $a0, digiteValorR
	syscall
	
	li $v0, 5
	syscall
	sb $v0,2($t3)
	
	addi $v0, $zero, 4 
	la $a0, digiteValorG
	syscall
	
	li $v0, 5
	syscall
	sb $v0,1($t3)
	
	addi $v0, $zero, 4 
	la $a0, digiteValorB
	syscall
	
	li $v0, 5
	syscall
	sb $v0,0($t3)
	
	lw $t0,0($t3)
	sw $t0,0($t4)
	
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
	addi $s7,$s7,3 #tamanhoDoArquivo
	lw $t1, 0($t3)
	sw $t1, 0($t0)
	addi $t0,$t0,4
	j LoopBuffer

GetPixelAddress:
	#a0 -> s0: PosicaoX
	#a1 -> s1: PosicaoY
	#a2 -> s2: Endereço base da Heap
	addi $sp,$sp, -4
	sw $ra, 0($sp)
	move $s0,$a0
	move $s1,$a1
	move $s2,$a2
	
	move $t0,$a1 #PosicaoY
	move $t1,$a2 #enderecoHeap
	li $t2,0     #Zera contador
	jal GetLinePixel
	move $s3,$v0
	
	move $t0,$a0 #PosicaoX
	move $t1,$s3 #enderecoHeap na linha correta
	li $t2,0     #Zera contador
	jal GetColumnPixel
	
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	j retorno #valor final já está em V0

GetLinePixel:
	#Input -> t0: PosicaoY
	#Input -> t1: enderecoHeap
	#t2: contadorY
	#t3: comparador
	#v0: endereçoHeap_CoordY
	
	slt $t3,$t2,$t0
	beq $t3,$zero,ReturnValue
	addi $t1,$t1,256 #64*4
	addi $t2,$t2,1
	j GetLinePixel	
	
GetColumnPixel:
	#Input -> t0: PosicaoX
	#Input -> t1: enderecoHeap
	#t2: contadorX
	#t3: comparador
	#v0: endereçoHeap_CoordY
	slt $t3,$t2,$t0
	beq $t3,$zero,ReturnValue
	addi $t1,$t1,4
	addi $t2,$t2,1
	j GetColumnPixel
grey:
	addi $t2,$zero,0
	addi $t0,$zero,0x10040000
	la $t7, memory_buffer
	sw $zero, 0($t7)
	jal tonsDeCinza
	j menu

tonsDeCinza:
	#Input -> t0: enderecoHeap
	#t1: SomaDaMedia
	#t2: contador
	#t3: comparador
	#t4: R
	#t5: G
	#t6: B
	#t7: Buffer
	#s7: tamanho do arquivo (variável global)
	
	slt $t3,$t2,$s7
	beq $t3,$zero,retorno
	
	lbu $t4,2($t0)
	lbu $t5,1($t0)
	lbu $t6,0($t0)
	
	add $t1,$t4,$t5
	add $t1,$t1,$t6
	
	div $t1,$t1,3
	#montar rgb no memory buffer ($t7)
	sb $t1,2($t7)
	sb $t1,1($t7)
	sb $t1,0($t7)
	lw $t8,0($t7)
	
	sw $t8,0($t0) 
	
	addi $t0,$t0,4 
	addi $t2,$t2,1
	j tonsDeCinza	
ReturnValue:
	move $v0,$t1
	jr $ra
retorno:
	jr $ra
exit:
	li $v0,10
	syscall
