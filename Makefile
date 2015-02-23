CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy

OBJ = startup.o syscalls.o limonite-c.o

CFLAGS = -O0 -g
INCLUDE = -I${BM_TOOLCHAIN_PATH}/arm-none-eabi/include
LDFLAGS = -L${BM_TOOLCHAIN_PATH}/arm-none-eabi/lib \
					-L${BM_TOOLCHAIN_PATH}/lib/gcc/arm-none-eabi/4.9.2 \
					-L${RUST_PATH}/lib/rustlib/arm-unknown-linux-gnueabi/lib
LIB = -lc -lgcc -lmorestack ${RUST_PATH}/lib/rustlib/arm-unknown-linux-gnueabi/lib/libstd-4e7c5e5c.rlib

TARGET_CPU=arm926ej-s

.c.o:
	${CC} -mcpu=${TARGET_CPU} ${CFLAGS} -c -o $@ $<

.s.o:
	${AS} -mcpu=${TARGET_CPU} -c -o $@ $<

all: limonite.bin

limonite.o: limonite.rs
	rustc --target=arm-unknown-linux-gnueabi --emit obj -o $@ $<

limonite.elf: ${OBJ} linker.ld
	${LD} -nostdlib ${LDFLAGS} -T linker.ld -o $@ ${OBJ} ${LIB}

limonite.bin: limonite.elf
	${OBJCOPY} -O binary $< $@

run: limonite.bin
	qemu-system-arm -M versatilepb -nographic -kernel $<

clean:
	rm -rf *.o *.bin *.elf
