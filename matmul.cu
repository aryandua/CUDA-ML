#pragma once

#include <stdlib.h>
#include <stdint.h>
#include <curand.h>
#include <curand_kernel.h>
#include <cuda.h>

// This file contains all of our CUDA kernel functions

// Spawn N Threads
__global__ void matrix_mul(double * a, double * b, double * output, int N, int M) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if(row < N) {
        double sum = 0;
        for(int i = 0; i < M; i++) 
            sum += a[row * M + i] * b[i];
        output[row] = sum;
    }
}

// Spawn B Threads
__global__ void batch_matrix_mul(double * a, double * b, double * output, int N, int M, int B) {
    int batch = blockIdx.x * blockDim.x + threadIdx.x;
    if(batch < B) {
        dim3 gridSz(1, 1, 1);
        dim3 blockSz(N, 1, 1);
        matrix_mul<<<gridSz, blockSz>>>(a, b + (batch * M), output + (batch * N), N, M);
    }
}

// Spawn N Threads
__global__ void vector_sigmoid(double * input, double * output, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N)
        output[i] = 1.0 / (1 + exp(-input[i]));
}

// Spawn B Threads
__global__ void batch_vector_sigmoid(double * input, double * output, int N, int B) {
    int batch = blockIdx.x * blockDim.x + threadIdx.x;
    if(batch < B) {
        dim3 gridSz(1, 1, 1);
        dim3 blockSz(N, 1, 1);
        vector_sigmoid<<<gridSz, blockSz>>>(input + (batch * N), output + (batch * N), N);
    }
}

// Spawn N Threads
__global__ void vector_dsigmoid(double * input, double * output, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N) {
        double sigmoid = 1.0 / (1 + exp(-input[i]));
        output[i] = sigmoid * (1-sigmoid);
    }
}

// Spawn B Threads
__global__ void batch_vector_dsigmoid(double * input, double * output, int N, int B) {
    int batch = blockIdx.x * blockDim.x + threadIdx.x;
    if(batch < B) {
        dim3 gridSz(1, 1, 1);
        dim3 blockSz(N, 1, 1);
        vector_dsigmoid<<<gridSz, blockSz>>>(input + (batch * N), output + (batch * N), N);
    }
}

// Spawn N Threads
__global__ void vector_relu(double * input, double * output, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N)
        output[i] = input[i] > 0 ? input[i] : 0;
}

// Spawn B Threads
__global__ void batch_vector_relu(double * input, double * output, int N, int B) {
    int batch = blockIdx.x * blockDim.x + threadIdx.x;
    if(batch < B) {
        dim3 gridSz(1, 1, 1);
        dim3 blockSz(N, 1, 1);
        vector_relu<<<gridSz, blockSz>>>(input + (batch * N), output + (batch * N), N);
    }
}

// Spawn N Threads
__global__ void vector_drelu(double * input, double * output, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N)
        output[i] = input[i] > 0;
}

// Spawn B Threads
__global__ void batch_vector_drelu(double * input, double * output, int N, int B) {
    int batch = blockIdx.x * blockDim.x + threadIdx.x;
    if(batch < B) {
        dim3 gridSz(1, 1, 1);
        dim3 blockSz(N, 1, 1);
        vector_drelu<<<gridSz, blockSz>>>(input + (batch * N), output + (batch * N), N);
    }
}

// Spawn N Threads
__global__ void vector_tanh(double * input, double * output, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N)
        output[i] = (exp(input[i]) - exp(-input[i])) / (exp(input[i]) + exp(-input[i]));
}

// Spawn B Threads
__global__ void batch_vector_tanh(double * input, double * output, int N, int B) {
    int batch = blockIdx.x * blockDim.x + threadIdx.x;
    if(batch < B) {
        dim3 gridSz(1, 1, 1);
        dim3 blockSz(N, 1, 1);
        vector_tanh<<<gridSz, blockSz>>>(input + (batch * N), output + (batch * N), N);
    }
}

// Spawn N Threads
__global__ void vector_dtanh(double * input, double * output, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N) {
        double tanh = (exp(input[i]) - exp(-input[i])) / (exp(input[i]) + exp(-input[i]));
        output[i] = 1 - tanh*tanh;
    }
}

// Spawn B Threads
__global__ void batch_vector_dtanh(double * input, double * output, int N, int B) {
    int batch = blockIdx.x * blockDim.x + threadIdx.x;
    if(batch < B) {
        dim3 gridSz(1, 1, 1);
        dim3 blockSz(N, 1, 1);
        vector_dtanh<<<gridSz, blockSz>>>(input + (batch * N), output + (batch * N), N);
    }
}

// Spawn B Threads
__global__ void batch_vector_softmax(double * input, double * output, int N, int B) {
    int batch = blockIdx.x * blockDim.x + threadIdx.x;
    if(batch < B) {
        double maxv = input[batch*N];
        for(int i = 0; i < N; i++) {
            if(input[batch*N + i] > maxv)
                maxv = input[batch*N + i];
        }

        double sum = 0.0;
        for(int i = 0; i < N; i++)
            sum += exp(input[batch*N + i] - maxv);

        for(int i = 0; i < N; i++)
            output[batch*N + i] = exp(input[batch*N + i] - maxv)/sum;
    }
}

// Spawn N Threads
__global__ void vector_add(double * a, double * b, double * output, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N)
        output[i] = a[i] + b[i];
}

// Spawn B Threads
__global__ void batch_vector_add(double * a, double * b, double * output, int N, int B) {
    int batch = blockIdx.x * blockDim.x + threadIdx.x;
    if(batch < B) {
        dim3 gridSz(1, 1, 1);
        dim3 blockSz(N, 1, 1);
        vector_add<<<gridSz, blockSz>>>(a + (batch * N), b, output + (batch * N), N);
    }
}

// Spawn N Threads
__global__ void vector_sub(double * a, double * b, double * output, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N)
        output[i] = a[i] - b[i];
}

// Spawn N Threads
__global__ void matrix_hadamard(double * a, double * b, double * output, int N, int M) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    int col = blockIdx.y * blockDim.y + threadIdx.y;
    if(row < N && col < M) 
        output[row * M + col] = a[row * M + col] * b[row * M + col];
}

// Spawn N x M Threads
__global__ void matrix_trans(double * input, double * output, int N, int M) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    int col = blockIdx.y * blockDim.y + threadIdx.y;
    if(row < N && col < M) 
        output[col * N + row] = input[row * M + col];
}

// Spawn N x M Threads
__global__ void matrix_scalar(double * input, double sc, double * output, int N, int M) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    int col = blockIdx.y * blockDim.y + threadIdx.y;
    if(row < N && col < M) 
        output[row * M + col] = sc * input[row * M + col];
}

// Spawn N Threads
__global__ void uniform_init(double * output, curandState * globalState, double range, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N) {
        curandState localState = globalState[i];
        output[i] = curand_uniform_double(&localState) * 2 * range - range;
    }
}

// Spawn N Threads
__global__ void normal_init(double * output, curandState * globalState, double range, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N) {
        curandState localState = globalState[i];
        output[i] = curand_normal_double(&localState) * range;
    }
}

// Spawn N Threads
__global__ void constant_init(double * output, int N, double sc) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N) {
        output[i] = sc;
    }
}

__global__ void setup_kernel(curandState * state, uint64_t seed) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    curand_init(seed, i, 0, &state[i]);
}

// Spawn TOTAL N Threads
__global__ void vector_hadamard(double * a, double * b, double * output, int N) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i < N)
        output[i] = a[i] * b[i];
}

// Spawn N x M Threads
__global__ void matrix_sub_scalar(double * a, double * b, double alpha, double epsilon, double * output, int N, int M) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    int col = blockIdx.y * blockDim.y + threadIdx.y;
    if(row < N && col < M)
        output[row * M + col] = ((1 - alpha * epsilon) * a[row * M + col]) - (alpha * b[row * M + col]);
}

// Spawn N Threads
__global__ void vector_sub_scalar(double * a, double * b, double alpha, double epsilon, double * output, int N) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i < N)
        output[i] = ((1 - alpha * epsilon) * a[i]) - (alpha * b[i]);
}

// Spawn N x M Threads
__global__ void vector_op(double * a, double * b, double * output, int N, int M, int B) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    int col = blockIdx.y * blockDim.y + threadIdx.y;
    
    if(row < N && col < M)
        for(int i = 0; i < B; i++)
            output[row * M + col] += a[i * N + row] * b[i * M + col];
}

// Spawn B Threads
__global__ void mse_loss(double * a, double * b, double * output, int N, int B) {
    int batch = threadIdx.x + blockIdx.x * blockDim.x;
    if(batch < B) {
        double sum = 0;
        for(int i = 0; i < N; i++) {
            double diff = a[batch * N + i] - b[batch * N + i];
            sum += diff * diff;
        }

        output[batch] = sum / N;
    }
}

// Spawn B Threads
__global__ void cross_entropy_loss(double * a, double * b, double * output, int N, int B) {
    int batch = threadIdx.x + blockIdx.x * blockDim.x;
    if(batch < B) {
        double sum = 0;
        for(int i = 0; i < N; i++) {
            sum -= b[batch * N + i] * log(a[batch * N + i]);
        }

        output[batch] = sum;
    }
}