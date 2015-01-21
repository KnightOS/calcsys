include .knightos/variables.make

# This is a list of files that need to be added to the filesystem when installing your program
ALL_TARGETS:=$(BIN)calcsys

# This is all the make targets to produce said files
$(BIN)calcsys: *.asm ui/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)main.list main.asm $(BIN)calcsys

include .knightos/sdk.make
