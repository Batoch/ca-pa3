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

#---------------------------------------------------------------------
#  int decode(const char *inp, int inbytes, char *outp, int outbytes)
#  a0:		inp
#  a1:		inbytes
#  a2:		outp
#  a3:		outbytes
#---------------------------------------------------------------------
	.globl	decode
decode:
			# Saving everything to be able to use a0-a5
			sw    a0, 0(sp)
			sw    a1, -4(sp)
			sw    a2, -8(sp)
			sw    a3, -12(sp)

			# To Big endian
			li		a5, 0										# Indice in inp to transforme to big endian

ToBigEndian:
			blt		a1, a5, EndToBigEndian						# If Indice is out of scope, then the convertion is finished
			lw		a4, 0(a0)    								# Loading the 8-bit word pointed by a0 in a4

			li		a3, 0xFF000000
			and		a3, a3, a4
			srli	a3, a3, 24
			mv		a2, a3

			li		a3, 0x00FF0000
			and		a3, a3, a4
			srli	a3, a3, 8
			or		a2, a2, a3

			li		a3, 0x0000FF00
			and		a3, a3, a4
			slli	a3, a3, 8
			or		a2, a2, a3

			li		a3, 0x000000FF
			and		a3, a3, a4
			slli	a3, a3, 24
			or		a2, a2, a3

			sw		a4, 0(a0)    								# Save the 8-bit word Big endian in a4 (Replace from Little to Big)
			addi	a0, a0, 4									# a0 point to the next 8-bit word
			addi	a5, a5, 4									# i + 4
			beq		zero, zero, ToBigEndian						# Goto loop2

EndToBigEndian:

			lw		a0, 0(sp)									# Restore a0
			lw		a2, 0(a0)									# First half of rankTable in BigEndian
			sw		a2, -16(sp)									# Put the first half of the rankTable in -16(sp)

			# End To Big endian

			# Padding

			addi	a0, a0, 4
			lw		a4, 0(a0)
			li		a5, 0xF0000000
			and		a5, a5, a4
			slli	a5, a5, 28
			sw		a5, -24(sp)									# Put the Padding in -24(sp)

			# The Padding is in A5 and -24(sp)

			## Creating the rankTable (-16(sp) and -20(sp))

			li		a0, 0										# a = 0
			li		a1, 0										# i1 = 0
			li		a2, 0										# i2 = 0
			sw		a0, -20(sp)									# rankTable (second part) = 0


Loop1:
			# If indice rankTable2 > 7 (if finished)
			li		a5, 8
			beq		a5, a2, Endloop1							# if i2 = 8 goto Endloop1
Loop2:
			# If indice rankTable1 > 7 (if finished looking for a in rankTable1, and not inside)
			li		a5, 8
			beq		a5, a1, Endloop2							# if i1 = 8 goto Endloop2
Loop3:
			# If a = rankTable1[i1]
			li		a3, 0x0000000F								# Mask
			sw		a1, -24(sp)									# Save i1
			slli	a1, a1, 2									# i1 *= 4
			sll		a3, a3, a1									# 0x0000000F << i1
			lw		a4, -16(sp)									# rankTable in A4
			and		a3, a3, a4									# put rankTable[i1] in A3
			srl		a3, a3, a1									# A3 >> A1
			lw		a1, -24(sp)									# Restore i1

			bne		a3, a0, Endloop3							# if a != rankTable1[i1] goto Endloop3
			addi	a0, a0, 1									# a++
			li		a1, -1										# i1 = -1 (to compensate the +1, so have 0 on i1)
Endloop3:
			addi	a1, a1, 1									# i1++
			beq		a0, a0, Loop2								# Goto loop2
Endloop2:
			# rankTable2[i2] = a
			li		a5, 7
			sub 	a4, a5, a2									# indice = 7 - i2
			slli	a4, a4, 2									# indice *= 4

			sw		a0, -28(sp)									# Save a
			sll		a0, a0, a4									# A << indice
			lw		a5, -20(sp)									# rankTable2 in A5
			or		a5, a5, a0	  								# rankTable2[i] = a
			sw		a5, -20(sp)									# Save rankTable2
			lw		a0, -28(sp)									# Restore a

			addi	a0, a0, 1									# a++
			addi	a2, a2, 1									# i2++
			li		a1, 0										# i1 = 0
			beq		a0, a0, Loop1								# Goto loop1
Endloop1:
			lw		a4, -16(sp)									# rankTable1 in A4
			lw		a5, -20(sp)									# rankTable2 in A5
			lw		a3, -24(sp)








ret
