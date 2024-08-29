# Compiler for system verilog
CC = iverilog
# Compiler flags
CFLAGS = -g2012

# Source files ( system verilog .sv)
SRCS = design/packet_generator.sv design/router.sv test/tb_noc_router.sv

# Executable name
TARGET = tb_noc_router

# Default target
all: $(TARGET)
	./$(TARGET)

# Rule to link object files into executable
$(TARGET):
	$(CC) $(CFLAGS) $(SRCS) -o $(TARGET)

simulate: ./$(TARGET)
	gtkwave $(TARGET).vcd

# Target to clean object files and executable
clean:
	rm -f $(TARGET) $(TARGET).vcd
# Clean target
.PHONY: clean