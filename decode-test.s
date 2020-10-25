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


	.data
	.align	2

	.globl	test
test:
	.word	test0
	.word	test1
	.word	test2
	.word	test3
	.word	test4
	.word	test5

	.globl	ans
ans:
	.word	ans0
	.word	ans1
	.word	ans2
	.word	ans3
	.word	ans4
	.word	ans5

test0:
	.word	0x00000007
	.word	0x4513ac02
	.word	0x00208826
ans0:
	.word	0x00000003
	.word	0x002020ca

test1:
	.word	0x00000008
	.word	0x12f0abed
	.word	0x40601132
ans1:
	.word	0x00000004
	.word	0xefbeadde

test2:
	.word	0x0000000e
	.word	0x12af370b
	.word	0x9a3f2328
	.word	0x15f92189
	.word	0x00006c63
ans2:
	.word	0x0000000a
	.word	0x1aef05ab
	.word	0xb3d307fb
	.word	0x00008720

test3:
	.word	0x0000000e
	.word	0x57024e61
	.word	0xc1c6a065
	.word	0x08b83015
	.word	0x0000c062
ans3:
	.word	0x0000000a
	.word	0x616a6e49
	.word	0x614b2065
	.word	0x0000676e

test4:
	.word	0x00000018
	.word	0x34912760
	.word	0x8c08437b
	.word	0x08976589
	.word	0x8b161e89
	.word	0x8303d1a1
	.word	0x0094d608
ans4:
	.word	0x00000015
	.word	0x68206542
	.word	0x79707061
	.word	0x646e6120
	.word	0x696d7320
	.word	0x3a20656c
	.word	0x00000029

test5:
	.word	0x0000002b
	.word	0x485f2067
	.word	0x1362a128
	.word	0x32343038
	.word	0x09459838
	.word	0x04307d24
	.word	0xc06c4c9b
	.word	0x892967f1
	.word	0x9a494120
	.word	0xd1312116
	.word	0xc5a4b383
	.word	0x007c0509
ans5:
	.word	0x0000002c
	.word	0x20656854
	.word	0x63697571
	.word	0x7262206b
	.word	0x206e776f
	.word	0x20786f66
	.word	0x706d756a
	.word	0x766f2073
	.word	0x74207265
	.word	0x6c206568
	.word	0x20797a61
	.word	0x2e676f64
