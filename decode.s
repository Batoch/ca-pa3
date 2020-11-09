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
			beq		zero, a1, End						# If inbyte = 0 jump to end
			# Saving everything to be able to use a0-a5
			sw    a0, -44(sp)
			sw    a1, -4(sp)
			sw    a2, -8(sp)
			sw    a2, -64(sp)
			sw    a3, -12(sp)



			lw		a1, (a0)
ToBigEndian:
# To Big endian (transform a1)
			li		a3, 0xFF000000
			and		a3, a3, a1
			srli	a2, a3, 24

			li		a3, 0x00FF0000
			and		a3, a3, a1
			srli	a3, a3, 8
			or		a2, a2, a3

			li		a3, 0x0000FF00
			and		a3, a3, a1
			slli	a3, a3, 8
			or		a2, a2, a3

			li		a3, 0x000000FF
			and		a3, a3, a1
			slli	a3, a3, 24
			or		a1, a2, a3
			# End To Big endian
EndToBigEndian:

			sw		a1, -16(sp)									# Put the first half of the rankTable in -16(sp)


			# Padding

			lw		a4, 4(a0)
			li		a5, 0x000000F0
			and		a5, a5, a4
			srli	a5, a5, 4
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
			sw		a1, -28(sp)									# Save i1
			slli	a1, a1, 2									# i1 *= 4
			sll		a3, a3, a1									# 0x0000000F << i1
			lw		a4, -16(sp)									# rankTable in A4
			and		a3, a3, a4									# put rankTable[i1] in A3
			srl		a3, a3, a1									# A3 >> A1
			lw		a1, -28(sp)									# Restore i1

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
			#	 -36(sp) out temp
			#	 -40(sp) Keep track of how much data pointer is far from initial
			#	 -44(sp) input data pointer
			#	 -48(sp) return value
			#--------------------------------------------------
			li		a0, 0
			sw		a0, -36(sp)					# Initialize the temp value
			sw		a0, -48(sp)					# return value

			lw		a1, -12(sp)
			bge		zero, a1, Endminus1


			li		a1, 0
			sw		a1, -32(sp)									# Init index of data stored


			lw		a0, -44(sp)										# Initialize input data pointer

			#li		a0, 0

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
			slli	a2, a2, 3										# How many bits
			# Sub padding
			lw		a3, -24(sp)
			sub		a2, a2, a3

			lw		a3, -40(sp)									# index Datapointer in a3
			slli	a3, a3, 3										# Express it in bits too

			add		a4, a1, a3

			# lw		a4, -32(sp)
			# li		a3, 6
			# beq		a4, a3, EndDecode

			bge		a4, a2, EndDecode						# If a2 =< a4 (inbyte - padding =< Datapointer index + i) then decode is finished

			# Creating a moving windowed array


ToBigEndian1:
			# To Big endian (transform from a2 to a3)
			sw		a1, -52(sp)
			lw		a1, 0(a0)									# Loading First values in a1

			li		a3, 0xFF000000
			and		a3, a3, a1
			srli	a2, a3, 24

			li		a3, 0x00FF0000
			and		a3, a3, a1
			srli	a3, a3, 8
			or		a2, a2, a3

			li		a3, 0x0000FF00
			and		a3, a3, a1
			slli	a3, a3, 8
			or		a2, a2, a3

			li		a3, 0x000000FF
			and		a3, a3, a1
			slli	a3, a3, 24
			or		a3, a2, a3
			# End To Big endian

			lw		a1, -52(sp)
EndToBigEndian1:



			sll		a3, a3, a1									# Tab1 << i
#if a1 = 32, a3 = 0
			li		a2, 32
			bne		a1, a2, Notnull
			li		a3, 0
Notnull:
			li		a2, 0												# Initialize moving windowed array
			or		a2, a2, a3									# Tabtmp = Tab1


ToBigEndian2:
			# To Big endian (transform from a2 to a3)
			sw		a1, -52(sp)
			sw		a2, -56(sp)
			lw		a1, 4(a0)									# Loading Secondvalues in a1

			li		a3, 0xFF000000
			and		a3, a3, a1
			srli	a2, a3, 24

			li		a3, 0x00FF0000
			and		a3, a3, a1
			srli	a3, a3, 8
			or		a2, a2, a3

			li		a3, 0x0000FF00
			and		a3, a3, a1
			slli	a3, a3, 8
			or		a2, a2, a3

			li		a3, 0x000000FF
			and		a3, a3, a1
			slli	a3, a3, 24
			or		a3, a2, a3
			# End To Big endian

			lw		a1, -52(sp)
			lw		a2, -56(sp)
EndToBigEndian2:

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

			li		a4, 0												# Value of the current char to read
			li		a5, 32
			sub		a5, a5, a3									# a5 = 32-Nb of bytes to read
			srl		a4, a2, a5									# a4 = Tabtmp >> 32-i (Value of current)

			beq		zero, zero, EndVal					# Goto EndVal
Val10:
			li		a3, 4												# Nb of bytes to read = 4

			li		a4, 0												# Value of the current char to read
			li		a5, 32
			sub		a5, a5, a3									# a5 = 32-Nb of bytes to read
			srl		a4, a2, a5									# a4 = Tabtmp >> 32-i (Value of current)
			andi	a4, a4, 7										# taking the 3 last bits
			addi	a4, a4, 4										# adding 4, as 1000 is value nb 4, 1001 is 5.. and rankTable start from 0

			beq		zero, zero, EndVal					# Goto EndVal
Val11:
			li		a3, 5												# Nb of bytes to read = 5

			li		a4, 0												# Value of the current char to read
			li		a5, 32
			sub		a5, a5, a3									# a5 = 32-Nb of bytes to read
			srl		a4, a2, a5									# a4 = Tabtmp >> 32-i (Value of current)
			andi	a4, a4, 7										# taking the 3 last bits
			addi	a4, a4, 8										# adding 8, as 11000 is 8, 11001 is 9...

			#beq		zero, zero, EndVal				# Goto EndVal
EndVal:
			# Number of bits to read is now in a3

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

			lw		a3, -32(sp)									# Data Index

			slli	a3, a3, 2
			srl		a5, a5, a3
			srli	a3, a3, 2
			addi	a3, a3, 1
			sw 		a3, -32(sp)									# Save Data index



			lw		a4, -12(sp)									# outbytes
			blt		a4, a3, Endminus1						# if dataindex > outbytes

			lw    a3, -36(sp)									# outp
			or		a3, a3, a5
			sw		a3, -36(sp)										# Save output

			lw		a5, -32(sp)

			li		a3, 8




			bne		a3, a5, Continue						# If a5 >= 9 then we store data to the next register




			# To Little endian
			sw		a1, -52(sp)
			sw		a2, -56(sp)

			lw    a1, -36(sp)									# out tab
			li		a3, 0
			sw		a3, -36(sp)										# Reset the temp tab

			li		a3, 0xFF000000
			and		a3, a3, a1
			srli	a2, a3, 24

			li		a3, 0x00FF0000
			and		a3, a3, a1
			srli	a3, a3, 8
			or		a2, a2, a3

			li		a3, 0x0000FF00
			and		a3, a3, a1
			slli	a3, a3, 8
			or		a2, a2, a3

			li		a3, 0x000000FF
			and		a3, a3, a1
			slli	a3, a3, 24
			or		a3, a2, a3


			lw		a1, -52(sp)
			lw		a2, -56(sp)
			# End To Little endian

			lw    a5, -8(sp)							# outp
			sw		a3, (a5)

			addi	a5, a5, 4										# Next register
			sw    a5, -8(sp)							# outp

			# addi 	a4, a4, 4
			# sw    a4, -36(sp)									# save outp
			lw		a5, -32(sp)
			srli	a5, a5, 1

			lw		a3, -48(sp)
			add		a3, a3, a5
			sw		a3, -48(sp)


			li		a5, 0
			sw		a5, -32(sp)									# Index of the data stored is reset
Continue:
# 			li		a3, 4
# 			bne		a6, a3, Pasfin
# 			lw		a4, -32(sp)
# 			li		a3, 8
# 			beq		a4, a3, EndDecode
# Pasfin:

			beq		zero, zero, Decode
EndDecode:




# Last row of data is not stored yet
			# To Little endian
			lw    a1, -36(sp)									# out tab

			li		a3, 0xFF000000
			and		a3, a3, a1
			srli	a2, a3, 24

			li		a3, 0x00FF0000
			and		a3, a3, a1
			srli	a3, a3, 8
			or		a2, a2, a3

			li		a3, 0x0000FF00
			and		a3, a3, a1
			slli	a3, a3, 8
			or		a2, a2, a3

			li		a3, 0x000000FF
			and		a3, a3, a1
			slli	a3, a3, 24
			or		a3, a2, a3

			# End To Little endian

			lw    a5, -8(sp)							# outp
			sw		a3, (a5)

			lw		a5, -32(sp)
			srli	a5, a5, 1

			lw		a3, -48(sp)
			add		a3, a3, a5
			sw		a3, -48(sp)



			lw    a1, -36(sp)

			lw    a4, -64(sp)									# outp
			lw		a1, 0(a4)
			lw		a2, 4(a4)
			lw		a3, 8(a4)

			lw		a0, -48(sp)


			# ebreak
						# End To Little endian


			End:

			ret

Endminus1:

		li	a0, -1
ret
