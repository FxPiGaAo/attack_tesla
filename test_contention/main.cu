#include<stdio.h>
#include<iostream>
#include<malloc.h>
#include<ctime>
#include<cuda_runtime.h>
#include<assert.h>
using namespace std;
__global__ void loop_stride_access(int* latency, long long unsigned* device_array, int access_number, long long unsigned* last_access_value, int array_size){
   int threadx =threadIdx.x;
   int smid = blockIdx.x;
   clock_t start, end;
   long long unsigned *j;
   j = &(device_array[array_size*smid]);
   for(int i=0;i<access_number;i++){if(threadx == 0) j=*(long long unsigned **)j;}//first acces to cache the data
   if(threadx == 0) last_access_value[smid] = j[0];
   j = &(device_array[array_size*smid]);
   __syncthreads();//finish intializing the array
   if(threadx == 0){
	   start = clock();
	   for(int k=0;k<100;k++){//do the same thing 100 times to increase the access time difference
           	for(int i=0;i<access_number;i++){j=*(long long unsigned **)j;}//access the data array
		last_access_value[smid] = j[0];
		j = &(device_array[array_size*smid]);
	   }
	   end = clock();
	   latency[smid] = (int)(end - start);
	   last_access_value[smid] = j[0];
   }
}


int main(void){
     


     for(int stride = 16;stride<1024;stride+=16){

         long long unsigned array_size = 8192;//let the array overflow the l1 cache;array_size = 64KB/8byte = 8192
         int sm_max = 20;
         printf("%d\t",stride);
         long long unsigned device_size = sizeof(long long unsigned)*array_size*sm_max;
         long long unsigned* device_array;
         long long unsigned* host_array = (long long unsigned*)malloc(array_size*sizeof(long long unsigned*)*sm_max);
         assert(cudaSuccess == cudaMalloc((void**)&device_array,device_size));
         for(int sm_id =0;sm_id<sm_max;sm_id++){
             for(int i = 0; i < array_size; i++){
                 int t = i + stride;
                 if(t >= array_size) t %= stride;
                 host_array[i+array_size*sm_id] = (long long unsigned)(&(device_array[sm_id*array_size])) + sizeof(long long unsigned)*t;//converse the device from int* to int; 4 is the byte size of an int type
             }
         }
   

         int* timing = (int*)malloc(sizeof(int)*sm_max);
         int* timing_d;
         assert(cudaSuccess == cudaMalloc((void**)&timing_d, sizeof(int)*sm_max));
         long long unsigned* last_access_value = (long long unsigned*)malloc(sizeof(long long unsigned)*sm_max);
         long long unsigned* d_last_access_value;
         assert(cudaSuccess == cudaMalloc((void**)&d_last_access_value, sizeof(long long unsigned)*sm_max));
         assert(cudaSuccess == cudaMemcpy(device_array,host_array,device_size,cudaMemcpyHostToDevice));
    
         double access_time;


         cudaDeviceSynchronize();
         loop_stride_access<<<sm_max,1>>>(timing_d, device_array, 48, d_last_access_value, array_size);
         cudaDeviceSynchronize();
         assert(cudaSuccess == cudaMemcpy(timing,timing_d,sizeof(int)*sm_max,cudaMemcpyDeviceToHost));
         assert(cudaSuccess == cudaMemcpy(last_access_value,d_last_access_value,sizeof(long long unsigned)*sm_max,cudaMemcpyDeviceToHost));
         cudaDeviceSynchronize();
         access_time = 0;
         for(int i=0;i<sm_max;i++){
             access_time+=timing[i];
         }
         printf("%lf\n",access_time/sm_max);
      

         delete host_array;
         delete timing;
         delete last_access_value;


     }
     return 0;
} 





