.data

memory_buffer:		.space 1228
tamnho_Imagem:		.word 12288
nomeArquivo:		.asciiz "lenaeye.raw"

.text
loadImg:
	#open
	li $v0, 13
	la $a0, nomeArquivo
	addi $a1,$zero,0
	addi $a2,$zero,0
	syscall
	
	#carrega pro buffer
	move $t2,$v0
	li $t0,0
	li $t1,0
	la $t3,memory_buffer
	jal LoopBuffer
	
	addi $t0,$zero,0
	la $t1,memory_buffer 
	add $t2, $zero, 0x10040000
	add $t3, $zero, $a2
	j loopLeitura

LoopBuffer:
	#t0: condicaoParada
	#t1: i
	#t2: fileDescriptor
	#t3: memoryBuffer
	li $v0, 14
	move $a1,$t3
	addi $a2, $zero, 4
	syscall

loopLeitura:
	# t0: i
	# t1: Ponteiro da memoria do buffer que contém a imagem Lida
	# t2: Regiao de memoria da heap (onde vão ser armazenados os bytes)
	# t3: Condição de parada do loop
	# t4: Byte lido
	beq $t0,$t3, exit
	
	#zero1
	sb $zero, 3($t2)
	
	#R1
	lb $t4, 3($t1)
	sb $t4, 2($t2)
	
	#G1
	lb $t4, 2($t1)
	sb $t4, 1($t2)
	
	#B1
	lb $t4, 1($t1)
	sb $t4, 0($t2)
	
	lw $t4, 0($t2)
	sw $t4, 0($t2)
	addi $t2, $t2, 4 ## passa uma word
	addi $t0, $t0, 3 ## Leu 1 RGB -> i+3
	sb $zero, 3($t2) # zero2
	
	#R2
	lb $t4, 0($t1)
	sb $t4, 2($t2)
	
	#G2
	addi $t1, $t1, 4 ##next word -> imagem lida
	lb $t4, 3($t1)
	sb $t4, 1($t2)
	
	#B2
	lb $t4, 2($t1)
	sb $t4, 0($t2)
	
	#zero3
	lw $t4, 0($t2)
	sw $t4, 0($t2)
	addi $t2, $t2, 4 ## passa uma word
	addi $t0, $t0, 3 ## Leu 1 RGB -> i+3
	sb $zero, 3($t2)
	
	#R3
	lb $t4, 1($t1)
	sb $t4, 2($t2)
	
	#G3
	lb $t4, 0($t1)
	sb $t4, 1($t2)
	
	#B3
	addi $t1, $t1, 4 ##next word -> imagem lida
	lb $t4, 3($t1)
	sb $t4, 0($t2)
	
	#zero4
	lw $t4, 0($t2)
	sw $t4, 0($t2)
	addi $t2, $t2, 4 ## passa uma word
	addi $t0, $t0, 3 ## Leu 1 RGB -> i+3
	sb $zero, 3($t2)
	
	#R4
	lb $t4, 2($t1)
	sb $t4, 2($t2)
	
	#G4
	lb $t4, 1($t1)
	sb $t4, 1($t2)
	
	#B4
	lb $t4, 0($t1)
	sb $t4, 0($t2)
	
	lw $t4, 0($t2)
	sw $t4, 0($t2)
	addi $t2, $t2, 4 ## passa uma word
	addi $t0, $t0, 3 ## Leu 1 RGB -> i+3
	addi $t1, $t1, 4 ##next word -> imagem lida
	
	j loopLeitura
exit:
	li $v0,10
	syscall
