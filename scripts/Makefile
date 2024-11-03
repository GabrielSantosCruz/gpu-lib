C_FILE = test_functions
S_FILE = functions_lib
TARGET = main

functions.o: $(S_FILE).s
	as -o functions.o $(S_FILE).s

$(TARGET).o: $(C_FILE).c 
	gcc -c -o $(TARGET).o $(C_FILE).c 

$(TARGET): $(TARGET).o functions.o
	gcc -o $(TARGET) $(TARGET).o functions.o

run: $(TARGET)
	./$(TARGET)

clear: $(C_FILE).o $(S_FILE).o $(TARGET)
	rm -f $(TARGET).o functions.o $(TARGET) test_functions.o

teste: $(TARGET)
	gdb $(TARGET)
