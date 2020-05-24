NAME=fpmul

FILES=adder1.vhd addern.vhd mul.vhd $(NAME).vhd ffd.vhd delay.vhd $(NAME)_tb.vhd
TEST_ENTITY=$(NAME)_tb
WAVE_FILE=$(NAME).vcd

OBJ=$(FILES:.vhd=.o)

all: view

check:
	ghdl -s $(FILES)

$(OBJ) &: $(FILES)
	ghdl -a $(FILES)

$(TEST_ENTITY): $(OBJ)
	ghdl -e $(TEST_ENTITY)

$(WAVE_FILE): $(TEST_ENTITY)
	ghdl -r $(TEST_ENTITY) --vcd=$(WAVE_FILE) --assert-level=error
	#  --disp-tree=port  --stop-time=30ns

view: $(WAVE_FILE)
	gtkwave $(WAVE_FILE)

clean:
	rm -fv $(TEST_ENTITY) $(WAVE_FILE) *.o *.cf
