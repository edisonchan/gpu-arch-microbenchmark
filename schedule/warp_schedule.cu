// 
//
//
//

#include "cuda.h"
#include "utils.cuh"


__global__ void warpScheduleKernel(float* input, float* output, uint* clock, const int run_warp){
    int tid = threadIdx.x;
    int laneid = tid & 0x1f;
    int warpid = tid >> 5;

    if (warpid != 0 and warpid != run_warp){
        ptxExit();
    }

    input += tid;
    clock += 32 * warpid / run_warp;

    float acc = 0;

    uint c1 = getClock();

    #pragma unroll
    for (int i = 0; i < 128; ++i){
        acc += input[i] * input[i];
    }

    uint c2 = getClock();
    clock[laneid] = c2 - c1;
    output[laneid] = acc;
}

uint sumArray(uint* array, int size){
    uint acc = 0;
    for (int i = 0; i < size; ++i){
        acc += array[i];
    }
    return acc;
}


int main(){

    float* input_h; 
    float* input_d;
    float* output_h;
    float* output_d;
    uint32_t* clock_h;
    uint32_t* clock_d;

    int size = 1024;

    input_h     = static_cast<float*>(malloc(sizeof(float) * size));
    output_h    = static_cast<float*>(malloc(sizeof(float) * size));
    clock_h     = static_cast<uint32_t*>(malloc(sizeof(uint32_t) * size));


    cudaMalloc(&input_d,  sizeof(float) * size);
    cudaMalloc(&output_d, sizeof(float) * size);
    cudaMalloc(&clock_d,  sizeof(uint32_t) * size);

    cudaMemcpy(input_d, input_h, sizeof(float) * size, cudaMemcpyHostToDevice);


    dim3 gDim(1, 1, 1);
    dim3 bDim(256, 1, 1);

    void* kernel_args[3] = {&input_d, &output_d, &clock_d};



    printf(">>> CUDA-C Level Warp Scedule Detect\n");
    for (int i = 1; i < 8; ++i){
        warpScheduleKernel<<<gDim, bDim>>>(input_d, output_d, clock_d, i);
        cudaMemcpy(clock_h, clock_d, sizeof(float) * size, cudaMemcpyDeviceToHost);

        printf("        Run Warp <0, %d>  Elapsed \t%6u cycle\n", i, sumArray(clock_h, 64));
        cudaDeviceSynchronize();
    }

    return 0;
}