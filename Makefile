test_program_src	:= app/test.c
test_program_bin	:= build/test
test_program_txt	:= build/test.txt
CFLAGS				= -Wall -ffreestanding
LDFLAGS				= -z norelro --static --entry _start -pic

test: build_program
	iverilog -o build/top_pipeline -Isrc src/top_pipeline.v
	build/top_pipeline
	gtkwave build/dump.vcd

.PHONY: build_program
build_program:
	riscv32-unknown-linux-gnu-gcc $(CFLAGS) -c -o build/test.o app/test.c
	riscv32-unknown-linux-gnu-gcc $(CFLAGS) -c -o build/_start.o app/_start.s
	riscv32-unknown-linux-gnu-ld $(LDFLAGS) -o build/test build/_start.o build/test.o 
	riscv32-unknown-linux-gnu-objdump -d build/test
	riscv32-unknown-linux-gnu-objcopy -O binary -j .text build/test
	xxd -e -c 4 build/test | cut -d ' ' -f 2 > build/testi.txt
