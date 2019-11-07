NVCC=nvcc
NVCCFLAGS=-O3 -Xcompiler -O3 -Xptxas -O3,-v -gencode=arch=compute_61,code=sm_61
#NVCCFLAGS=-O3 -Xcompiler -O3 -Xptxas -O3,-v
#NVCCFLAGS=-O0 -Xcompiler -O0 -Xptxas -O0,-v
#NVCCFLAGS=-O0 -Xcompiler -O0 -Xptxas -O0,-v -gencode=arch=compute_61,code=sm_61

all: tesla-attack

tesla-attack: main.cu
	$(NVCC) $(NVCCFLAGS) -lm main.cu -o tesla-attack

clean:
	rm -f tesla-attack

