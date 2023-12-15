# Accelerator Architecture for Fully-Connected Neural Networks Inference and Training
This repository contains the Verilog code for an accelerator architecture designed for training and inference of **non-compressed** fully-connected neural networks. The architecture is optimized for FPGA implementation, featuring a core processor that efficiently handles the computations needed for uncompressed neural network algorithms. Verification has been performed using ModelSim.

## The Architecture
The core processor is designed to execute the necessary instructions for a fully-connected neural network algorithm. The design utilizes a resilient 16 MAC structure which reforms to effectively tailor to each phase of the inference/training.

This design also conducts a novel approach for performing computationally-intensive non-linearity functions such as Sigmod function. By expanding the non-linearity functions to their taylor series, and configuring the MAC interconnect appropriatly, this design can exploit the available MAC units to perform such operations.

**Next we will see how the architecture aligns for each algorithm phase.**

## Forward Propagation
Forward Propagation multiplies weight matrices with activation matrices. The matrices are spread across several RAM blocks to enable parallel reading of multiple elements from a column.
The following two images illustrate the architectural structure, and how it's used during forward propagation.

<img src="https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/84641aeb-b0d2-44e7-b640-02412623a052" width=70% height=70%>

<img src="https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/a61f3d4c-7466-4608-91c8-1b908b997d29" width=70% height=70%>

## Sigmoid Function
The sigmoid function, defined as `Sigmoid(x) = 1 / (1 + 2^(-x))`, is implemented in two steps:
### Step 1: Calculation of the sigmoid function using a Taylor series expansion.
First, we calculate the term `1 + 2^(-x)` by decomposing `2^(-x)` into two parts:

```
2^(-x) = 2^(-n) * 2^(r)   |  n ∈ Z  &  0 ≤ r < 1
```
We then compute `2^r` using its Taylor series expansion:

```
2^r = exp (r*ln(2)) -> taylor series -> 1 + [r*ln(2)] + [r^2 * (ln(2)^2) / (2!)] + [r^3 * (ln(2)^3) / (3!)] + …
```
**Note**: Values within the neural network are stored in floating-point format, thus separating `-x` into `-n` and `r` is straightforward. The floating-point format is optimized for FPGA and is not based on the IEEE standard. It is as follows:
- 18-bit fraction: This precision level is deemed sufficient for neural network computations. Additionally, each DSP48A1 includes an 18-bit multiplier and adder.
- 8-bit exponent: This precision level is also considered adequate for neural network computations, and this size ensures that the total number of bits is a multiple of 9.
- 1-bit sign.
- Total bits: 27 bits, which is a multiple of 9 and optimized for FPGA's M4k blocks, as each word is 9 bits.

**Architectural setup for first Sigmod step:**
<img src="https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/2a7cc33c-66cf-4da6-b398-3c11805af77d" width=90% height=90%>

### Step 2: Inversion of the resulting value.
The second step involves inverting the result from step 1:

```
1 / x = 1 / (2^exp * fraction) = 2^(-exp) * (1 / fraction)   |   fraction ∈ (0, 0.5)
```

To find `1 / fraction`, we use the following converging series:

```
1 / fraction = ∑_(n=0)^∞ (1-fraction)^n   |   1 - fraction ∈  (1, 0.5)   ->   converging series
```

**Architectural setup for second Sigmod step:**
<img src="https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/63cceaf0-bbfb-498b-9cbe-81ec1a704ef7" width=70% height=70%>

## Back Propagation
Back Propagation calculates the error list and adjusts the weights accordingly.
In this part of the algorithm, what cannot be easily done with the previous circuits is the multiplication of the transposed weight matrix by the error list. This is because parallel reading from this matrix involves 16 elements from one column, and after transposition, this rule changes. As a result, a different dataflow and architectural setup is needed for this part.

**Architectural setup for back propagation:**
<img src="https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/cbb38c35-c0e9-40d5-b5c5-115fc7fda395" width=80% height=80%>

## Element-wise Multiplication and Additiom
Element-wise multiplication and addition of two matrices can also be performed in parallel, with the available components. For example, for element-wise multiplication, the following setup can be used:
<img src="https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/e5019d5e-feef-4b2f-80ec-f15299118942" width=90% height=90%>

## Final Architecture
Finally, by combining the above circuits and applying pipelines and timing adjustments, we arrive at the following architecture (implemented in `FCDNNAccelerator/Core.v`):
![image](https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/2ee1985a-127e-4232-8171-05c48398ff78)

**Modules and Components:**

| Image | Description |
| --- | --- |
| ![image](https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/d00b6fcc-42bc-4912-bd3a-73b157b88e46) | Multiplexer (Code in files MUX_2.v, MUX_3.v, and MUX_4.v based on the number of inputs) |
| ![image](https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/75a93410-e1d1-403c-8355-bdd327811598) | Register (Code in file SReg.v) |
| ![image](https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/ca2c4207-2ee1-4b13-b29f-5f45d4df8ef5) | Two pipeline layers (Code in file PipeReg.v) |
| ![image](https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/9b7ad3d6-9439-4600-b9d5-1121932e3c84) | N pipeline layers with the capability to bypass data (Code in file SelectablePipeReg.v) |
| ![image](https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/40d3cd76-9aaf-427c-b272-832d422de0d9) | Pipeline with the ability to switch between 3 states N layers, M layers, and bypassing data (Code in file SelectableExtendablePipeReg.v) |
| ![image](https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/5de546a4-d8b9-49e1-b18c-af63c3d47efd) | Module for adding the value of Exp (input) to the exp of a floating-point number (another input) (Code in file FPExpMultiplier) |
| ![image](https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/6f6b82ff-5d33-4562-a768-d7a8c036f40e) | Adds the input with a constant number 1 (uses a floating-point adder and does not have independent code) |
| ![image](https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/e9fd6261-f32d-4822-b84a-7364997f330d) | 27-bit floating-point multiplier! (Code in file FloatingPointMultiplier.v and includes 2 submodules and 1 pipeline layer) |
| ![image](https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/7653af7d-d9ea-42e3-b4f1-dc855573dc87) | 27-bit floating-point adder (Code in file FloatingPointAdder.v and includes 3 main submodules and 2 pipeline layers) |

## Testing
The core processor has undergone several testings. The provided example demonstrates the testing of the sigmoid function's second step, where the Taylor series is used to calculate the inverse of `x`.

Let's assume:
```
x = 0_00000010_101001111111011110 = 2^2 * (1/2 + 1/8 + 1/64 + …) ≈ 2^2 * (1/2 + 1/8 + 1/32) = 2.625
1/x = 1/2.625 = 0.381
```
Inputs to the core (1-fraction and –exp):
```
1 - fraction = floating point(1) - 0.101001111111011110 = 0.1111111… - 0.101001111111011110 = 0.(~101001111111011110) = 0.010110000000100001 → 1-fraction = 27'b0_00000000_010110000000100001
-exp = -2
```
Output corresponding to the first input:
```
0_11111111_110000110001010001 = 2^(-1) * (1/2 + 1/4 + 1/128 + …) = 0.381 → as expected.
```
If the above inputs are applied, after passing through the pipeline path, the outputs appear consecutively in each clock (in the valid output sequence section).

```
exp = -2;
mul_in_1_single = 27'b0_00000000_010110000000100001; #20;
mul_in_1_single = 27'b0_00000000_100110101001010100; #20;
mul_in_1_single = 27'b0_00000000_110100000100010101; #20;
mul_in_1_single = 27'b0_00000000_010110000000100001; #20;
mul_in_1_single = 27'b0_00000000_100110101001010100; #20;
mul_in_1_single = 27'b0_00000000_110100000100010101; #20;
mul_in_1_single = 27'b0_00000000_010110000000100001;
```

![image](https://github.com/SamanMohseni/FCDNNAccelerator/assets/51726090/1a7caf3b-6e9a-45fb-b98a-46dc90ca763a)


All Core functions have been tested similar to the example above and operate correctly.
