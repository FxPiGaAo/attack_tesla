NVCC=nvcc
NVCCFLAGS=-O3 -Xcompiler -O3 -Xptxas -dlcm=ca,-O3,-v -gencode=arch=compute_61,code=sm_61
#NVCCFLAGS=-O3 -Xcompiler -O3 -Xptxas -dlcm=ca,-O3,-v
#NVCCFLAGS=-O0 -Xcompiler -O0 -Xptxas -dlcm=ca,-O0,-v
#NVCCFLAGS=-O0 -Xcompiler -O0 -Xptxas -dlcm=ca,-O0,-v -gencode=arch=compute_61,code=sm_61

all: test_contention

test_contention: main.cu
	$(NVCC) $(NVCCFLAGS) -lm main.cu -o test_contention

clean:
	rm -f test_contention

