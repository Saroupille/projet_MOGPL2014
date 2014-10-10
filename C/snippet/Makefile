# Copyright 2013, Gurobi Optimization, Inc.

PLATFORM = linux64
INC      = ../include/
CC       = gcc
CARGS    = -m64 -g
CLIB     = -L../lib/ -lgurobi56


snippet: snippet.c
	$(CC) $(CARGS) -o snippet snippet.c -I$(INC) $(CLIB) -lpthread -lm

run: snippet
	./snippet

clean:
	rm -rf *.o *_c *_c++ *.class *.log *.rlp *.lp *.bas *.ilp
