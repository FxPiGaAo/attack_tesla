#include<stdio.h>
#include<malloc.h>

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
int main(void){
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
     sequence_read<<<1,1,array_size*sizeof(int)>>>(timing_d[0], device_array, array_size, array_size/stride);
     cudaMemcpy(timing,timing_d,sizeof(long long int),cudaMemcpyDeviceToHost);
     printf ("It took me %lld clicks.\n",timing[0]);
     delete host_array;
     //printf ("It took me %Lf clicks.\n",timing[0]);
   }



/*
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
     sequence_read<<<1,1>>>(timing_d[0], device_array, 1);
     cudaMemcpy(timing,timing_d,sizeof(long long int),cudaMemcpyDeviceToHost);
     printf ("It took me %lld clicks.\n",timing[0]);
     delete host_array;
     //printf ("It took me %Lf clicks.\n",timing[0]);
   }
*/
   return 0;
} 





