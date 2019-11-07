#include<stdio.h>
#include<iostream>
#include<malloc.h>
#include<ctime>
#include<cuda_runtime.h>
#include<assert.h>
using namespace std;
//__constant__ int* device_array;

__global__ void test_clock(int &delay, int &add){
   int threadID = (blockIdx.x * blockDim.x) + threadIdx.x;
   clock_t start=0;
   if(threadID == 0) start = clock();
   for(int k=0;k<100;k++){
      for(int j =0;j<10;j++){
         for(int i=0;i<100;i++){
            if(threadID==0){add+=i;}
	    //add+=j;
	    //if(threadID<11){add+=k;}
		 add+=k;
         }
      }
   }
   if(threadID==0){clock_t end = clock();
   delay = (int)(end - start);}
}



__global__ void sequence_read(long long int &latency, int* device_array, int n, int access_number){
   extern __shared__ int shared_array[];
   for(int i=0;i<n;i++){shared_array[i]=device_array[i];}
   int* j = &shared_array[0];
   //for(int i=0;i<access_number;i++){j=*(int **)j;}
   //j = &shared_array[0];
   long long int temp = clock64();
   for(int i=0;i<access_number;i++){j=*(int **)j;}
   latency = clock64() - temp;
}
__global__ void static_sequence_read(int &latency, long long unsigned* device_array, int access_number, long long unsigned &last_access_value){
   int threadID = (blockIdx.x * blockDim.x) + threadIdx.x;
   //__shared__ int shared_array[64];
   //__constant__ int shared_array[64];
   //for(int i=0;i<64;i++){shared_array[i]=device_array[i];}
   long long unsigned *j;
   if(threadID == 0){
       j =&device_array[0];
       //int* j = &shared_array[0];
       for(int i=0;i<access_number;i++){j=*(long long unsigned **)j;}
   }
   //j = &shared_array[0];
   clock_t temp=0;
   if(threadID == 0){temp = clock();}
   //for(int i=0;i<access_number;i++){if(threadID <5) j=*(int**)j;}
   //long long int temp = clock64();
   for(int i=0;i<access_number;i++){if(threadID == 0) j=*(long long unsigned **)j;}
   if(threadID == 0){
	   latency = (int)(clock() - temp);
	   last_access_value = j[0];
   }
}
int main(void){/*
   for(int array_size = 64; array_size<2048;array_size+=8){
     int device_size = sizeof(int)*array_size;
     int* device_array;
     int* host_array = (int*)malloc(array_size*sizeof(int*));
     cudaMalloc((void**)&device_array,device_size);
     int stride = 4;
     for(int i = 0; i < array_size; i++){
         int t = i + stride;
         if(t >= array_size) t %= stride;
         host_array[i] = *((int*)(&device_array)) + 4*t;//converse the device from int* to int; 4 is the byte size of an int type
     }
     long long int* timing = (long long int*)malloc(sizeof(long long int));
     long long int* timing_d;
     cudaMalloc((void**)&timing_d, sizeof(long long int));
     printf("start computing!\n");
     cudaMemcpy(device_array,host_array,device_size,cudaMemcpyHostToDevice);
     sequence_read<<<1,1,array_size*sizeof(int)>>>(timing_d[0], device_array, array_size, 1000000);
     cudaMemcpy(timing,timing_d,sizeof(long long int),cudaMemcpyDeviceToHost);
     printf ("It took me %lld clicks.\n",timing[0]);
     delete host_array;
     //printf ("It took me %Lf clicks.\n",timing[0]);
   }
*/
	/*
	//cudaEvent_t event1, event2;
	//cudaEventCreate(&event1);
	//cudaEventCreate(&event2);
	
	int* d_time;
	int time;
     int add = 0;
     int* d_add;printf("%d,%d\n",time,add);
     cudaMalloc((void**)&d_time,sizeof(int));
     cudaMalloc((void**)&d_add,sizeof(int));
     cudaMemcpy(d_add,&add,sizeof(int),cudaMemcpyHostToDevice); 
     clock_t start = clock();
     //cudaEventRecord(event1 ,0);
     test_clock<<<1,1>>>(d_time[0],d_add[0]);
     //cudaEventRecord(event2,0);
     //cudaEventSynchronize(event1);
     //cudaEventSynchronize(event2);
     //cudaDeviceSynchronize();
     clock_t end = clock();
     cudaMemcpy(&time,d_time,sizeof(int),cudaMemcpyDeviceToHost);
     cudaMemcpy(&add,d_add,sizeof(int),cudaMemcpyDeviceToHost);
     long double time_elapsed_ms = 1000.0 * (end-start) / CLOCKS_PER_SEC;
     cout << "CPU time used: " << time_elapsed_ms << " ms\n";
     printf("%d,%d\n",time,add);
     //float dt_ms;
     //cudaEventElapsedTime(&dt_ms, event1, event2);
     //cout << "cuda event elpased time:" << dt_ms << " ms\n";
*/

     long long unsigned array_size = 16;
     long long unsigned device_size = sizeof(long long unsigned)*array_size;
     long long unsigned* device_array;
     long long unsigned* host_array = (long long unsigned*)malloc(array_size*sizeof(long long unsigned*));
     assert(cudaSuccess == cudaMalloc((void**)&device_array,device_size));
     int stride = 4;
     for(int i = 0; i < array_size; i++){
         int t = i + stride;
         if(t >= array_size) t %= stride;
         host_array[i] = *((long long unsigned*)(&device_array)) + 4*t;//converse the device from int* to int; 4 is the byte size of an int type
     }

/*
     cout<< "sizeof long long unsigned" << sizeof(long long unsigned) << endl;
     cout<< "device array adress: " << (long long unsigned)device_array << endl;
     for(int i=0;i<array_size;i++){
         cout << host_array[i] << endl;
     }
     return 0;
*/


     int* timing = (int*)malloc(sizeof(int));
     int* timing_d;
     printf ("It took me %d clicks before the funvtion call.\n",timing[0]);
     assert(cudaSuccess == cudaMalloc((void**)&timing_d, sizeof(int)));
     long long unsigned* last_access_value = (long long unsigned*)malloc(sizeof(long long unsigned));
     long long unsigned* d_last_access_value;
     printf ("original last_access value: %llu\n", last_access_value[0]);
     assert(cudaSuccess == cudaMalloc((void**)&d_last_access_value, sizeof(long long unsigned)));
     printf("start computing!\n");
     assert(cudaSuccess == cudaMemcpy(device_array,host_array,device_size,cudaMemcpyHostToDevice));

     static_sequence_read<<<1,32>>>(timing_d[0], device_array, 4, d_last_access_value[0]);
     assert(cudaSuccess == cudaMemcpy(timing,timing_d,sizeof(int),cudaMemcpyDeviceToHost));
     assert(cudaSuccess == cudaMemcpy(last_access_value,d_last_access_value,sizeof(long long unsigned),cudaMemcpyDeviceToHost));
     cudaDeviceSynchronize();
     printf ("It took me %d clicks, last_access value: %llu.\n",timing[0], last_access_value[0]);


     static_sequence_read<<<1,32>>>(timing_d[0], device_array, 4, d_last_access_value[0]);
     cudaMemcpy(last_access_value,d_last_access_value,sizeof(long long unsigned),cudaMemcpyDeviceToHost);
     cudaMemcpy(timing,timing_d,sizeof(int),cudaMemcpyDeviceToHost);
     printf ("It took me %d clicks, last_access value: %llu.\n",timing[0],last_access_value[0]);

     static_sequence_read<<<1,32>>>(timing_d[0], device_array, 4, d_last_access_value[0]);
     cudaMemcpy(last_access_value,d_last_access_value,sizeof(long long unsigned),cudaMemcpyDeviceToHost);
     cudaMemcpy(timing,timing_d,sizeof(int),cudaMemcpyDeviceToHost);
     printf ("It took me %d clicks, last_access value: %llu.\n",timing[0], last_access_value[0]);

     static_sequence_read<<<1,32>>>(timing_d[0], device_array, 4, d_last_access_value[0]);
     cudaMemcpy(last_access_value,d_last_access_value,sizeof(long long unsigned),cudaMemcpyDeviceToHost);
     cudaMemcpy(timing,timing_d,sizeof(int),cudaMemcpyDeviceToHost);
     printf ("It took me %d clicks, last_access value: %llu.\n",timing[0], last_access_value[0]);

     static_sequence_read<<<1,32>>>(timing_d[0], device_array, 10000, d_last_access_value[0]);
     cudaMemcpy(last_access_value,d_last_access_value,sizeof(long long unsigned),cudaMemcpyDeviceToHost);  
     cudaMemcpy(timing,timing_d,sizeof(int),cudaMemcpyDeviceToHost);
     printf ("It took me %d clicks, last_access value: %llu.\n",timing[0], last_access_value[0]);
     
     static_sequence_read<<<1,32>>>(timing_d[0], device_array, 2000, d_last_access_value[0]);
     cudaMemcpy(last_access_value,d_last_access_value,sizeof(long long unsigned),cudaMemcpyDeviceToHost);
     cudaMemcpy(timing,timing_d,sizeof(int),cudaMemcpyDeviceToHost);
     printf ("It took me %d clicks, last_access value: %llu.\n",timing[0], last_access_value[0]);

     static_sequence_read<<<1,32>>>(timing_d[0], device_array, 1, d_last_access_value[0]);
     cudaMemcpy(last_access_value,d_last_access_value,sizeof(long long unsigned),cudaMemcpyDeviceToHost);
     cudaMemcpy(timing,timing_d,sizeof(int),cudaMemcpyDeviceToHost);
     printf ("It took me %d clicks, last_access value: %llu.\n",timing[0], last_access_value[0]);

     delete host_array;
     //printf ("It took me %Lf clicks.\n",timing[0]);

   return 0;
} 





