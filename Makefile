include .knightos/variables.make

# This is a list of files that need to be added to the filesystem when installing your program
ALL_TARGETS:=$(BIN)calcsys $(APPS)calcsys.app $(SHARE)icons/calcsys.img

# This is all the make targets to produce said files
$(BIN)calcsys: *.asm core/*.asm ui/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)main.list main.asm $(BIN)calcsys

$(APPS)calcsys.app: config/calcsys.app
	mkdir -p $(APPS)
	cp config/calcsys.app $(APPS)

$(SHARE)icons/calcsys.img: config/calcsys.png
	mkdir -p $(SHARE)icons
	kimg -c config/calcsys.png $(SHARE)icons/calcsys.img

include .knightos/sdk.make
