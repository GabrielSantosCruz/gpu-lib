C_FILE = test_functions
S_FILE = functions_lib
TARGET = main
CTAG = -std=c99

all: functions.o $(TARGET).o $(TARGET)
	echo compilado pae

functions.o: $(S_FILE).s
	as -o functions.o $(S_FILE).s

$(TARGET).o: $(C_FILE).c 
	gcc -std=c99 -c -o $(TARGET).o $(C_FILE).c 

$(TARGET): functions.o $(TARGET).o 
	gcc -std=c99 -o $(TARGET) functions.o $(TARGET).o 

run: $(TARGET)
	./$(TARGET)

clear: 
	rm -f ./*.o main

teste: $(TARGET)
	gdb $(TARGET)
