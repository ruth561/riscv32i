test_program_src	:= app/test.s
test_program_txt	:= build/testi.txt

.PHONY: simulation
simulation: $(test_program_src)
	iverilog -o build/simulation -Isrc src/top.v
	build/simulation

$(test_program_src): $(test_program_txt)
	riscv32-unknown-linux-gnu-gcc -c -o build/test.o app/test.s
	riscv32-unknown-linux-gnu-objcopy -O binary -j .text build/test.o
	xxd -e -c 4 build/test.o | cut -d ' ' -f 2 > build/testi.txt
