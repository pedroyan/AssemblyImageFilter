.data

memory_buffer:		.space 4
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
	addi $t0,$zero,0x10040000 
	li $t1,0
	la $t3,memory_buffer
	jal LoopBuffer
	

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
	beq $v0, $zero, exit
	lw $t1, 0($t3)
	sw $t1, 0($t0)
	addi $t0,$t0,4
	j LoopBuffer
	
exit:
	li $v0,10
	syscall
