functions.o: memory_map.s
	as -o functions.o memory_map.s

keys.o: test_keys.c 
	gcc -c -o keys.o test_keys.c 

main: keys.o functions.o
	gcc -o main keys.o functions.o

run: main
	./main
