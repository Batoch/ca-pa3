﻿# 4190.308 Computer Architecture (Fall 2020)
# Project #3: RISC-V Assembly Programming
### Due: 11:59PM, November 8 (Sunday)


## Introduction

The goal of this project is to give you an opportunity to practice RISC-V assembly programming. In addition, this project introduces various RISC-V tools that help you compile and run your RISC-V programs.

## Background

In this project, we focus on the 32-bit RISC-V processor that implements a subset of RV32I base instruction set. RV32I was designed to be sufficient to form a compiler target and to support modern operating system environments, containing only 40 unique instructions. 

## Problem specification

Write the function `decode()` that decodes the data compressed with the Simplified Huffman Coding in [Project #1](https://github.com/snu-csl/ca-pa1).
The prototype of `decode()` is as follows:

```
int decode(const char *inp, int inbytes, char *outp, int outbytes);
```

The first argument `inp` points to the memory address of the input compressed data. The length of the input data (in bytes) is specified in the second argument `inbytes`. The decoded (original) data should be stored starting from the address pointed to by `outp`. Finally, the `outbytes` argument indicates the number of bytes allocated for the result by the caller.

The function `decode()` returns the actual length of the output in bytes. If the size of the output exceeds the `outbytes`, it should return -1 and the contents of the output is ignored. When the `inbytes` is zero, `decode()` returns zero. 

In the assembly code, those arguments for `inp`, `inbytes`, `outp`, and `outbytes` are available in the `a0`, `a1`, `a2`, and `a3` registers, respectively. Also, you need to put the return value in the `a0` register on return. Because we are using the 32-bit RISC-V simulator, all the registers are 32-bit wide.

You will be using `lw` and `sw` RISC-V instructions to access data in memory. The `lw` instruction reads a 4-byte word from the memory, while the `sw` instruction stores a 4-byte value into the memory. Because all the memory accesses are performed with these instructions, you can safely assume that the size of the memory region allocated for `inp` or `outp` is a multiple of 4. 


## Building RISC-V gcc compiler

In order to compile RISC-V assembly programs, you need to build a cross compiler, i.e. the compiler that generates the RISC-V binary code on the x86-64 machine. To build the RISC-V toolchain on your machine (on either Linux or MacOS), please take the following steps. These instructions are also available in the [README.md](https://github.com/snu-csl/pyrisc/blob/master/README.md) file of the PyRISC toolset.

### 1. Install prerequisite packages first

For Ubuntu 18.04LTS, perform the following command:
```
$ sudo apt-get install autoconf automake autotools-dev curl libmpc-dev
$ sudo apt-get install libmpfr-dev libgmp-dev gawk build-essential bison flex
$ sudo apt-get install texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
```
If your machine runs MacOS, perform the following command (If you don't have the `brew` utility, you have to install it first -- please refer to https://brew.sh):
```
$ brew install gawk gnu-sed gmp mpfr libmpc isl zlib expat
```

### 2. Download the RISC-V GNU Toolchain from Github

```
$ git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
```

### 3. Configure the RISC-V GNU toolchain

```
$ cd riscv-gnu-toolchain
$ mkdir build
$ cd build
$ ../configure --prefix=/opt/riscv --with-arch=rv32i
```

### 4. Compile and install them.

Note that they are installed in the path given as the prefix, i.e. `/opt/riscv` in this example.

```
$ sudo make
```

### 5. Add `/opt/riscv/bin` in your `PATH`

```
$ export PATH=/opt/riscv/bin:$PATH
```


## Skeleton code

We provide you with the skeleton code for this project. It can be downloaded from Github at https://github.com/snu-csl/ca-pa3/.

To download and build the skeleton code, please follow these steps:

```
$ git clone https://github.com/snu-csl/ca-pa3.git
$ cd ca-pa3
$ make
riscv32-unknown-elf-gcc -c -Og -march=rv32g -mabi=ilp32 -static  decode.s -o decode.o
riscv32-unknown-elf-gcc -c -Og -march=rv32g -mabi=ilp32 -static  decode-main.s -o decode-main.o
riscv32-unknown-elf-gcc -c -Og -march=rv32g -mabi=ilp32 -static  decode-test.s -o decode-test.o
riscv32-unknown-elf-gcc -T./link.ld -nostdlib -nostartfiles -o decode decode.o decode-main.o decode-test.o  
```

## Running your RISC-V executable file

The executable file generated by `riscv32-unknown-elf-gcc` should be run in the RISC-V machine. In this project, we provide you with a RISC-V instruction set simulator written in Python, called __snurisc__. It is available at the separate Github repository at https://github.com/snu-csl/pyrisc. You can install it by performing the following command.
```
$ git clone https://github.com/snu-csl/pyrisc
```

To run your RISC-V executable file, you need to modify the `./ca-pa3/Makefile` so that it can find the __snurisc__ simulator. In the `Makefile`, there is an environment variable called `PYRISC`. By default, it was set to `../../pyrisc/sim/snurisc.py`. For example, if you have downloaded PyRISC in `/dir1/dir2/pyrisc`, set `PYRISC` to `/dir1/dir2/pyrisc/sim/snurisc.py`.

```
...

PREFIX      = riscv32-unknown-elf-
CC          = $(PREFIX)gcc
CXX         = $(PREFIX)g++
AS          = $(PREFIX)as
OBJDUMP     = $(PREFIX)objdump

PYRISC      = /dir1/dir2/pyrisc/sim/snurisc.py      # <-- Change this line
PYRISCOPT   = -l 1

INCDIR      =
LIBDIR      =
LIBS        =

...
```

Now you can run `decode`, by performing `make run`. The result of a sample run using the __snurisc__ simulator looks like this:

```
$ make run
/dir1/dir2/pyrisc/sim/snurisc.py   -l 1 decode
Loading file decode
Execution completed
Registers
=========
zero ($0): 0x00000000    ra ($1):   0x8000000c    sp ($2):   0x80020000    gp ($3):   0x00000000    
tp ($4):   0x00000000    t0 ($5):   0x00000006    t1 ($6):   0x00000006    t2 ($7):   0x80010018    
s0 ($8):   0x00000000    s1 ($9):   0x00000004    a0 ($10):  0x800100dc    a1 ($11):  0x0000002c    
a2 ($12):  0x8001fef0    a3 ($13):  0x00000100    a4 ($14):  0x00000000    a5 ($15):  0x00000000    
a6 ($16):  0x00000000    a7 ($17):  0x00000000    s2 ($18):  0x00000000    s3 ($19):  0x00000000    
s4 ($20):  0x00000000    s5 ($21):  0x00000000    s6 ($22):  0x00000000    s7 ($23):  0x00000000    
s8 ($24):  0x00000000    s9 ($25):  0x00000000    s10 ($26): 0x00000000    s11 ($27): 0x00000000    
t3 ($28):  0x80010030    t4 ($29):  0x80010108    t5 ($30):  0x00000020    t6 ($31):  0x0000003f    
120 instructions executed in 120 cycles. CPI = 1.000
Data transfer:    26 instructions (21.67%)
ALU operation:    67 instructions (55.83%)
Control transfer: 27 instructions (22.50%)
```

If the value of the `t6` (or `x31`) register is nonzero, it means that your program didn't pass all the test cases. Each bit in the value of the `t6` represents the result of a test case (LSB is for test 0, and so on...). The bit will be set if your program didn't pass the corresponding test.
For example, if the value of the `t6` is equal to 0x0000000d (0b1101 in binary), it means that your program didn't pass test 0, 2 and 3, while passing the others.


## Restrictions

* You are allowed to use only the following registers in the `decode.s` file: `zero (x0)`, `sp`, `ra`, and `a0` ~ `a5`. If you are running out of registers, use stack as temporary storage. 

* __The maximum amount of the space you can use in the stack is limited to 128 bytes.__ Let A be the address indicated by the `sp` register at the beginning of the function `decode()`. The valid stack area you can use is from `A - `128` to `A - 1`. You should always access the stack area using the `sp` register such as `sw a0, 16(sp)`.

* Your solution should finish within a reasonable time. If your code does not finish within a predefined threshold, it will be terminated.

* __The top 10 fastest `decode()` implementations will receive a 10% extra bonus.__ Also, __the next top 10 fastest implementation will receive a 5% bonus.__ The time will be measured in clock cycles which is identical to the total number of instructions executed.

## Hand in instructions

* Submit the `decode.s` file to the submission server.
* You should write a 1~2 page report to explain your assembly implementation of the `decode()` function.
  * Submit the `report.pdf` file to the submission server.
  * It will account for 10% of your score in this assignment.
  * It will be graded as pass or fail.

## Logistics

* You will work on this project alone.
* Only the upload submitted before the deadline will receive the full credit. 25% of the credit will be deducted for every single day delay.
* __You can use up to 4 _slip days_ during this semester__. If your submission is delayed by 1 day and if you decided to use 1 slip day, there will be no penalty. In this case, you should explicitly declare the number of slip days you want to use in the QnA board of the submission server after each submission. Saving the slip days for later projects is highly recommended!
* Any attempt to copy others' work will result in heavy penalty (for both the copier and the originator). Don't take a risk.

Have fun!

[Jin-Soo Kim](mailto:jinsoo.kim_AT_snu.ac.kr)  
[Systems Software and Architecture Laboratory](http://csl.snu.ac.kr)  
[Dept. of Computer Science and Engineering](http://cse.snu.ac.kr)  
[Seoul National University](http://www.snu.ac.kr)