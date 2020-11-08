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
			sw    a0, -64(sp)
			sw    a1, -4(sp)
			sw    a2, -8(sp)
			sw    a3, -12(sp)

			# To Big endian
			li		a5, 0										# Indice in inp to transforme to big endian
ToBigEndian:
			blt		a1, a5, EndToBigEndian						# If Indice (a5) is out of scope, then the convertion is finished
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

			sw		a2, 0(a0)    								# Save the 8-bit word Big endian in a4 (Replace from Little to Big)
			addi	a0, a0, 4									# a0 point to the next 8-bit word
			addi	a5, a5, 4									# i + 4
			beq		zero, zero, ToBigEndian						# Goto loop2

EndToBigEndian:

			lw		a0, -64(sp)									# Restore a0
			lw		a2, 0(a0)									# First half of rankTable in BigEndian
			sw		a2, -16(sp)									# Put the first half of the rankTable in -16(sp)

			# End To Big endian

			# Padding

			addi	a0, a0, 4
			lw		a4, 0(a0)
			li		a5, 0xF0000000
			and		a5, a5, a4
			srli	a5, a5, 28
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
			sw		a1, -52(sp)									# Save i1
			slli	a1, a1, 2									# i1 *= 4
			sll		a3, a3, a1									# 0x0000000F << i1
			lw		a4, -16(sp)									# rankTable in A4
			and		a3, a3, a4									# put rankTable[i1] in A3
			srl		a3, a3, a1									# A3 >> A1
			lw		a1, -52(sp)									# Restore i1

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

			#--------------------------------------------------
			#  a0:		Data pointer (inp)
			#  a1:		Data index
			#  a2:		moving windowed array
			#	 -32(sp) Index of data stored
			#	 -36(sp) outp
			#	 -40(sp) Keep track of how much data pointer is far from initial
			#--------------------------------------------------
			lw    a0, -8(sp)
			sw		a0, -36(sp)
			li		a1, 0
			sw		a1, 0(a0)									# Init out
			sw		a1, -32(sp)									# Init index of data stored



			lw		a0, -64(sp)										# Initialize data pointer


			addi	a0, a0, 4										# Skipping rankedtab
			li		a1, 4
			sw		a1, -40(sp)									# init index Datapointer

			li		a1, 4												# i = 4 (skip padding)
Decode:
			# If indice >= 32, then we need to look for the next set of datas
			li		a5, 33
			blt		a1, a5, Indiceinf32						# If a1 > a5 jmp	(if 33 <= i)
			addi	a1, a1, -32
			addi	a0, a0, 4
			lw		a3, -40(sp)									# index Datapointer in a3
			addi	a3, a3, 4
			sw		a3, -40(sp)									# save Datapointer in a3
Indiceinf32:

			lw		a2, -4(sp)									# Loading inbyte in
			lw		a3, -40(sp)									# index Datapointer in a3

			srli	a4, a1, 3										# a4 = a1 (i) / 8 (how many bytes)
			add		a4, a4, a3

			bge		a4, a2, EndDecode						# If a2 =< a0 (inbyte =< Datapointer index + i/8) then decode is finished

			# Creating a moving windowed array
			lw		a3, 0(a0)									# Loading First values in a3

			sll		a3, a3, a1									# Tab1 << i
			li		a2, 0												# Initialize moving windowed array
			or		a2, a2, a3									# Tabtmp = Tab1

			lw		a3, 4(a0)									# Loading Secondvalues in a3
			li		a4, 32
			sub		a4, a4, a1									# a4 = 32-i
			srl		a3, a3, a4									# Tab2 >> 32-i
			or		a2, a2, a3									# Tabtmp += Tab2
			# moving windowed array in a2

			srl		a3, a2, 31									# Taking the last bit
			beq		a3, zero, Val0							# Goto Val0 if the value start with 0

			srl		a3, a2, 30									# Taking the 2 last bit
			li		a4, 0x00000001
			and		a3, a3, a4									# Taking the bit before the last bit
			beq		a3, zero, Val10							# Goto Val10 if the value start with 10
			beq		zero, zero, Val11						# Goto Val11 if the value start with 11

Val0:
			li		a3, 3												# Nb of bytes to read = 3
			beq		zero, zero, EndVal					# Goto EndVal
Val10:
			li		a3, 4												# Nb of bytes to read = 4
			beq		zero, zero, EndVal					# Goto EndVal
Val11:
			li		a3, 5												# Nb of bytes to read = 5
			#beq		zero, zero, EndVal				# Goto EndVal
EndVal:
			# Number of bits to read is now in a3
			li		a4, 0												# Value of the current char to read
			li		a5, 32
			sub		a5, a5, a3									# a5 = 32-Nb of bytes to read
			srl		a4, a2, a5									# a4 = Tabtmp >> 32-i (Value of current)
			add		a1, a1, a3									# Data index += Nb of bytes read

			li		a5, 8
			bge		a4, a5, ValInRk2

ValInRk1:
			lw		a3, -16(sp)									# rankTable1 in A3

			beq		zero, zero, EndValInRK			# Goto EndValInRK
ValInRk2:
			lw		a3, -20(sp)									# rankTable2 in A3
			sub		a4, a4, a5									# Value = value - 8 (As first 8 values are in rankTable1)

			#beq		zero, zero, EndValInRK
EndValInRK:
			li		a5, 0xF0000000

			# a4 = 3 = 011 => a4 doit etre de 100 (3eme)
			slli	a4, a4, 2									# a3 = a3 * 4

			srl		a5, a5, a4									# Puting the mask to the value we want
			and		a5, a5, a3									# The value is now in a5 but at index a4
			sll		a5, a5, a4									# The value is now in a5 (left side)
			#srli	a5, a5, 28
			# Saving data



			lw    a4, -36(sp)									# outp
			lw		a3, -32(sp)									# Data Index
			slli	a3, a3, 2
			srl		a5, a5, a3
			srli	a3, a3, 2
			addi	a3, a3, 1
			sw 		a3, -32(sp)									# Save Data index
			lw		a3, 0(a4)										# Out
			or		a3, a3, a5
			sw		a3, 0(a4)										# Save output

			#lw		a4, -32(sp)
			#li		a6, 11
			#beq		a4, a6, EndDecode

			beq		zero, zero, Decode
EndDecode:



			lw    a4, -36(sp)									# outp
			lw		a5, 0(a4)
			lw		a1, -40(sp)



			lw    a0, -8(sp)

			# To Little endian
			li		a5, 0										# Indice in inp to transforme to big endian
ToLittleEndian:
			blt		a1, a5, EndToLittleEndian						# If Indice (a5) is out of scope, then the convertion is finished
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

			sw		a2, 0(a0)    								# Save the 8-bit word Big endian in a4 (Replace from Little to Big)
			addi	a0, a0, 4									# a0 point to the next 8-bit word
			addi	a5, a5, 4									# i + 4
			beq		zero, zero, ToLittleEndian						# Goto loop2

EndToLittleEndian:

lw    a4, -36(sp)									# outp
lw		a5, 0(a4)
lw		a4, -32(sp)
srli	a0, a4, 1										# Return value

			# End To Little endian






ret
