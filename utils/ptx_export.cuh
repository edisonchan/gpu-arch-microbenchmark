
#include "utils/macro.h"
#include "cuda.h"

__forceinline__ __device__ uint32_t get_clock(){
    uint32_t clock;
    asm volatile(
        "mov.u32    %0,     %%clock; \n\t"
        :"=r"(clock)::"memory"
    );
    return clock;
}

__forceinline__ __device__ uint32_t get_clock64(){
    uint64_t clock64;
    asm volatile(
        "mov.u64    %0,     %%clock; \n\t"
        :"=l"(clock64)::"memory"
    );
    return clock64;
}

__forceinline__ __device__ uint32_t get_smid(){
    uint32_t smid;
    asm volatile(
        "mov.u32    %0,     %%smid; \n\t"
        :"=r"(clock)::"memory"
    );
    return smid;
}

__forceinline__ __device__ uint32_t get_warpid(){
    uint32_t warpid;
    asm volatile(
        "mov.u32    %0,     %%warpid; \n\t"
        :"=r"(clock)::"memory"
    );
    return warpid;
}

__forceinline__ __device__ uint32_t get_global_warpid(){
    uint32_t global_warpid;
    uint32_t local_warpid = get_warpid();
    uint32_t block_id = blockIdx.x + blockIdx.y * gridDim.x + blockIdx.z * gridDim.x * gridDim.y;
    uint32_t warp_per_block = UPPER_DIV(blockDim.x * blockDim.y * blockDim.z, WARP_SIZE);
    global_warpid = block_id * warp_per_block + local_warpid;
    return global_warpid;
}


__forceinline__ __device__ uint32_t get_laneid(){
    uint32_t laneid;
    asm volatile(
        "mov.u32    %0,     %%laneid; \n\t"
        :"=r"(clock)::"memory"
    );
    return laneid;
}

__forceinline__ __device__ void bar_sync(){
    asm volatile(
        "bar.sync   0; \n\t"
    );
}