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

        # To Big endian
        lw     a4, 0(a0)    #chargement du premier mot de 8 bits dans a4 il faut faire une boucle bb

        li     a5, 0xFF000000
        and    a5, a5, a4
        srli   a5, a5, 24
        sw     a5, 0(sp)
        
        li     a5, 0x00FF0000
        and    a5, a5, a4
        srli   a5, a5, 8
        sw     a5, 4(sp)
        mv     a6, a5

        li     a5, 0x0000FF00
        and    a5, a5, a4
        slli   a5, a5, 8
        sw     a5, 8(sp)

        li     a5, 0x000000FF
        and    a5, a5, a4
        slli   a5, a5, 24
        #sw     a5, 12(sp)    # we use it right away

        lw     a4, 0(sp)
        or    a5, a4, a5
        lw     a4, 4(sp)
        or    a5, a4, a5
        lw     a4, 8(sp)
        or    a5, a4, a5

        # End To Big endian




	# TODO
	ret
