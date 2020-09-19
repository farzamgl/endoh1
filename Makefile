#!/usr/bin/env make
#
# 2012 makefile
#
# This work by Landon Curt Noll, Simon Cooper, and Leonid A. Broukhis
# is licensed under:
#
#	Creative Commons Attribution-ShareAlike 3.0 Unported License.
#
# See: http://creativecommons.org/licenses/by-sa/3.0/


################
# tool locations
################
#
SHELL= /bin/bash
CP= cp
CPP= cpp
GUNZIP= gunzip
LD= ld
MAKE= make
RM= rm
SED= sed
TAR= tar
TRUE= true

# Set X11_LIBDIR to the directory where the X11 library resides
#
X11_LIBDIR= /usr/X11R6/lib

# Set X11_INCLUDEDIR to the directory where the X11 include files reside
#
X11_INCDIR= /usr/X11R6/include

# Compiler warnings
#
#CWARN=
#CWARN= -Wall -W
CWARN= -Wall -W -pedantic

# compiler standard
#
#CSTD=
#CSTD= -ansi
CSTD= -std=c99

# compiler bit architecture
#
# Some entries require 32-bitness:
# ARCH= -m32
#
# Some entries require 64-bitess:
# ARCH= -m64
#
# By default we assume nothing:
#
ARCH=

# optimization
#
# Most compiles will safely use -O2.  Some can use only -O1 or -O.
# A few compilers have broken optimizers or this entry make break
# under those buggy optimizers and thus you may not want anything.
#
#OPT=
#OPT= -O
#OPT= -O1
OPT= -O2
#OPT= -O3

# Libraries needed to build
#
LIBS= -lm

# default flags for ANSI C compilation
#
CFLAGS= ${CWARN} ${CSTD} ${ARCH} ${OPT} 

# ANSI compiler
#
# Set CC to the name of your ANSI compiler.
#
# Some entries seem to need gcc.  If you have gcc, set
# both CC and MAY_NEED_GCC to gcc.
#
# If you do not have gcc, set CC to the name of your ANSI compiler, and
# set MAY_NEED_GCC to either ${CC} (and hope for the best) or to just :
# to disable such programs.
#
CC= cc
#CC=clang
MAY_NEED_GCC= gcc

#RISCV_GCC  = $(CROSS_COMPILE)gcc -mabi=lp64 -march=rv64ima -mcmodel=medany -fno-builtin-printf -I$(BP_TEST_DIR)/include
#RISCV_LINK = -O2 -static -nostartfiles -Wl,--start-group -lgloss -lperch -lc -lg -lm -lgcc -Wl,--end-group -T riscv.ld -L$(BP_TEST_DIR)/lib
MKLFS = dramfs_mklfs

comma:= ,
empty:=
space:= $(empty) $(empty)

ARGC = 2
ARGV = $(ENTRY) $(ENTRY).c

RISCV_GCC  = $(CROSS_COMPILE)gcc
RISCV_GCC += -O2 -mabi=lp64 -march=rv64ima -mcmodel=medany -mstrict-align -static -nostartfiles -I$(BP_TEST_DIR)/include
RISCV_GCC += -D__init_argc=$(ARGC) -D__init_argv=\"$(subst $(space),\"$(comma)\",$(strip $(ARGV)))\"
RISCV_GCC += -DG=$G -DP=$P -DV=$P

RISCV_LINK      = $(CROSS_COMPILE)gcc -t -T riscv.ld
RISCV_LINK_OPTS = -nostartfiles -lperch -lm -lgloss -lc -lg -lgcc -L$(BP_TEST_DIR)/lib

LFS_BLOCK_SIZE = 128
LFS_BLOCK_COUNT = 64

OBJECT_FILES = endoh1.o lfs.o crt.o args.o

##############################
# Special flags for this entry
##############################
#
ENTRY= endoh1
DATA= column.txt column2.txt column3.txt corners.txt dripping-pan.txt \
	evaporation.txt flat.txt fountain.txt funnel.txt funnel2.txt \
	funnel3.txt leidenfrost.txt logo.txt pour-out.txt tanada.txt
ALT_OBJ= endoh1_color.o
ALT_ENTRY= endoh1_color

# The factor of gravity
#
G=1

# The factor of pressure
#
P=4

# The factor of viscosity
#
V=8

#################
# build the entry
#################
#
all: ${ENTRY} ${DATA}
	@${TRUE}

lfs.c: ${ENTRY}.c
	$(MKLFS) $(LFS_BLOCK_SIZE) $(LFS_BLOCK_COUNT) $< > $@

%.o: %.S
	$(RISCV_GCC) -c $< -o $@

%.o: %.c
	$(RISCV_GCC) -c $< -o $@

endoh1.riscv: $(OBJECT_FILES)
	$(RISCV_LINK) $(OBJECT_FILES) -L. -o $@ $(RISCV_LINK_OPTS)

${ENTRY}: ${ENTRY}.c lfs.c args.c crt.S
	$(RISCV_GCC) $(RISCV_LINK) -DG=$G -DP=$P -DV=$P $< lfs.c args.c crt.S -o $@

# alternative executable
#
alt: ${ALT_ENTRY}
	@${TRUE}

endoh1_deobfuscate: endoh1_deobfuscate.c
	${CC} ${CFLAGS} -DG=$G -DP=$P -DV=$P $< -o $@ ${LIBS}

endoh1_color: endoh1_color.c
	${CC} ${CFLAGS} -DG=$G -DP=$P -DV=$P $< -o $@ ${LIBS}

# data files
#
data: ${DATA}
	@${TRUE}


###############
# utility rules
###############
#
everything: all alt

clean:
	${RM} -f *.o ${ALT_OBJ}

clobber: clean
	${RM} -f ${ENTRY} ${ALT_ENTRY}

nuke: clobber
	@${TRUE}

dist_clean: nuke
	@${TRUE}

install:
	@echo "Surely you're joking Mr. Feynman!"
	@${TRUE}

# backwards compatibility
#
build: all
	@${TRUE}


##################
# 133t hacker rulz
##################
#
love:
	@echo 'not war?'
	@${TRUE}

haste:
	$(MAKE) waste
	@${TRUE}

waste:
	@echo 'waste'
	@${TRUE}

easter_egg:
	@echo you expected to mis-understand this $${RANDOM} magic
	@echo chongo '<was here>' "/\\oo/\\"
	@echo Readers shall be disallowed from not being unable to partly misunderstand this partocular final echo.

# Understand the history of "I Am the Walrus" and
# and in particular John Lennon's remarks on that
# song and you might be confused about these next
# rules in a different way. :-)
#
supernova: nuke
	@-if [ -r .code_anal ]; then \
	    ${RM} -f .code_anal_v3; \
	else \
	    echo "You are not expected to understand this"; \
	fi
	@${TRUE}

deep_magic:
	@-if [ -r .code_anal ]; then \
	    ccode_analysis --deep_magic 1c2c85c7a02c55d1add91967eca491d53c101dc1 --FNV1a_hash 256-bit "${ENTRY}"; \
	else \
	    echo "Understand different"; \
	fi
	@${TRUE}

magic: deep_magic
	@-if [ -r .code_anal ]; then \
	    ccode_analysis --mode 21701 --level 23209 --FNV1a_hash 256-bit "${ENTRY}"; \
	else \
	    echo "These aren't the droids you're looking for Mr. Spock!"; \
	fi
	@${TRUE}
