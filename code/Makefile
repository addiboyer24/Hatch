CC=g++
CFLAGS=-I -O3 -std=c++11

all: interpreter.out

interpreter.tab.c: interpreter.y
	bison -d interpreter.y

lex.yy.c: interpreter.l
	flex interpreter.l

interpreter.out: interpreter.l interpreter.y interpreter.tab.c lex.yy.c
	$(CC) $(CFLAGS) interpreter.tab.c lex.yy.c -lfl -o interpreter.out