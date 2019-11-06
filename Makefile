NVCC=nvcc
NVCCFLAGS=-O3 -Xcompiler -O3 -Xptxas -O3,-v
#NVCCFLAGS=-O0 -Xcompiler -O0 -Xptxas -O0,-v

all: tesla-attack

tesla-attack: main.cu
	$(NVCC) $(NVCCFLAGS) -lm main.cu -o tesla-attack

clean:
	rm -f tesla-attack

