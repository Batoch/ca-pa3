#----------------------------------------------------------------
#
#  4190.308 Computer Architecture (Fall 2020)
#
#  Project #3: RISC-V Assembly Programming
#
#  October 26, 2020
#
#  Injae Kang (abcinje@snu.ac.kr)
#  Sunmin Jeong (sunnyday0208@snu.ac.kr)
#  Systems Software & Architecture Laboratory
#  Dept. of Computer Science and Engineering
#  Seoul National University
#
#----------------------------------------------------------------


	.text
	.align	2

	.globl	_start
_start:
	lui	sp, 0x80020
	call	main
	ebreak

# mul8 - Get num in {1, 2, 3} and return num * 8
mul8:
	addi	sp, sp, -8
	sw	s2, 0(sp)
	sw	s3, 4(sp)

	mv	s2, zero
	mv	s3, zero

inc8:
	addi	s3, s3, 8
	addi	s2, s2, 1
	blt	s2, a0, inc8

	mv	a0, s3

	lw	s3, 4(sp)
	lw	s2, 0(sp)
	addi	sp, sp, 8
	ret

main:
	#--------------------------------------------------
	#  t0:		loop index
	#  t1:		number of test cases
	#  t2:		indirect pointer to test cases
	#  t3:		indirect pointer to answer
	#  t6:		result
	#  s1:		word size
	#--------------------------------------------------

	addi	sp, sp, -16
	sw	ra, 0(sp)

	addi	sp, sp, -0x100
	mv	t0, zero
	li	t1, 6
	la	t2, test
	la	t3, ans
	mv	t6, zero
	li	s1, 4

loop:
	lw	t4, 0(t2)
	addi	a0, t4, 4
	lw	a1, 0(t4)
	mv	a2, sp
	li	a3, 0x100
	call	decode

	lw	t4, 0(t3)
	lw	a1, 0(t4)
	bne	a0, a1, fail
	mv	t5, zero

cmp:
	add	s2, sp, t5
	add	s3, t4, t5
	lw	s4, 0(s2)
	lw	s5, 4(s3)
	sub	s6, a1, t5
	bge	s6, s1, fword
	mv	a0, s6
	call	mul8
	li	s7, -1
	sll	s7, s7, a0
	not	s7, s7
	and	s4, s4, s7
	and	s5, s5, s7

fword:
	bne	s4, s5, fail
	addi	t5, t5, 4
	blt	t5, a1, cmp
	j	update

fail:
	li	t5, 1
	sll	t5, t5, t0
	or	t6, t6, t5

update:
	addi	t0, t0, 1
	addi	t2, t2, 4
	addi	t3, t3, 4
	blt	t0, t1, loop

	addi	sp, sp, 0x100

	lw	ra, 0(sp)
	addi	sp, sp, 16
	ret
