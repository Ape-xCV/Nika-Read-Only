# Makefile for a C++ program linked with X11 and Xtst libraries

# Compiler
CXX = g++

# Source files
SRCS = Nika.cpp

# Libraries to link
LIBS = -lX11 -lXtst

# Default target
all: rebuild; 

# Clean up object files and the executable
clean:
	rm -f a.out

# Compilation and linking
a.out: $(SRCS)
	$(CXX) $^ -o $@ $(LIBS)


# clean & build
rebuild:
	@$(MAKE) clean
	@$(MAKE) a.out
	echo "BUILD SUCCESSFUL - RUN: sudo ./a.out"

