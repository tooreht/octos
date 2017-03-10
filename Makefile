# ***********************************************
#                 OctOS Makefile
# ***********************************************

# Detect host OS
ifeq ($(OS),Windows_NT)
    OS_detected := Windows
else
    OS_detected := $(shell uname -s)
endif

# Set host OS specific program paths
ifeq ($(OS_detected),Darwin)
    GRUB_MKRESCUE := ~/opt/bin/grub-mkrescue
    LD := ~/opt/bin/x86_64-pc-elf-ld
else
    GRUB_MKRESCUE := grub-mkrescue
    LD := ld
endif

default: run

.PHONY: clean

target/multiboot_header.o: src/asm/multiboot_header.asm
	mkdir -p target
	nasm -f elf64 src/asm/multiboot_header.asm -o target/multiboot_header.o

target/boot.o: src/asm/boot.asm
	mkdir -p target
	nasm -f elf64 src/asm/boot.asm -o target/boot.o

target/kernel.bin: target/multiboot_header.o target/boot.o src/asm/linker.ld cargo
	$(LD) -n -o target/kernel.bin -T src/asm/linker.ld target/multiboot_header.o target/boot.o target/x86_64-unknown-octos-gnu/release/liboctos.a

target/os.iso: target/kernel.bin grub.cfg
	mkdir -p target/isofiles/boot/grub
	cp grub.cfg target/isofiles/boot/grub
	cp target/kernel.bin target/isofiles/boot
	$(GRUB_MKRESCUE) -o target/os.iso target/isofiles

target: target/os.iso

run: target/os.iso
	qemu-system-x86_64 -cdrom target/os.iso

cargo:
	xargo build --release --target x86_64-unknown-octos-gnu

clean:
	xargo clean

# Rule for debugging Makefile variables
# Usage: make print-VARIABLE
print-%  : ; @echo $* = $($*)
