test_program_src	:= app/test.s
test_program_dst	:= build/testi.txt

run_pipeline: $(test_program_dst)
	iverilog -o build/top_pipeline -Isrc src/top_pipeline.v
	build/top_pipeline
	gtkwave build/dump.vcd

.PHONY: simulation
simulation: $(test_program_dst)
	iverilog -o build/simulation -Isrc src/top.v
	build/simulation

$(test_program_dst): $(test_program_src)
	riscv32-unknown-linux-gnu-gcc -c -o build/test.o app/test.s
	riscv32-unknown-linux-gnu-objdump -d build/test.o
	riscv32-unknown-linux-gnu-objcopy -O binary -j .text build/test.o
	xxd -e -c 4 build/test.o | cut -d ' ' -f 2 > build/testi.txt

.PHONY: c_test
c_test:
	riscv32-unknown-linux-gnu-gcc -c -o build/test.o app/test.c
	riscv32-unknown-linux-gnu-objdump -d build/test.o
	riscv32-unknown-linux-gnu-objcopy -O binary -j .text build/test.o
	xxd -e -c 4 build/test.o | cut -d ' ' -f 2 > build/testi.txt

.PHONY: disas
disas:
	riscv32-unknown-linux-gnu-gcc -c -o build/test_elf.o app/test.s
	riscv32-unknown-linux-gnu-objdump -d build/test_elf.o
