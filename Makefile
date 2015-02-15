include .knightos/variables.make

# This is a list of files that need to be added to the filesystem when installing your program
ALL_TARGETS:=$(BIN)calcsys $(APPS)calcsys.app

# This is all the make targets to produce said files
$(BIN)calcsys: *.asm core/*.asm ui/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)main.list main.asm $(BIN)calcsys

$(APPS)calcsys.app: config/calcsys.app
	mkdir -p $(APPS)
	cp config/calcsys.app $(APPS)

include .knightos/sdk.make
