functions.o: functions_lib.s
	as -o functions.o functions_lib.s

main.o: test_functions.c 
	gcc -c -o main.o test_functions.c 

main: main.o functions.o
	gcc -o main main.o functions.o

run: main
	./main

teste: main
	gdb main
