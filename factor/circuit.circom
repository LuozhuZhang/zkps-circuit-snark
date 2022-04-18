// circom语言默认的主要文件路径，circom本质是一个zkp的电路编程语言，而且初步接触下来应该是较为图灵完备的，就像solidity那些一样。The default main file path of circom language, circom is essentially a zkp circuit programming language, and the initial contact should be more Turing-complete, just like those of solidity.
// Doc：https://docs.circom.io/circom-language

/* 
 template Like a function
 这里定义了一个电路，目标是能够让我们验证两个数字（a和b）相乘可以得到c，但不需要知道这两个数字（a和b）。A circuit is defined here whose goal is to allow us to verify that multiplying two numbers (a and b) gives c without knowing the two numbers (a and b)
 */
template Multiplier() {
  // signal define public and private variables, writes like solidity
   signal private input a;
   signal private input b;
   signal output c;
  // constraint：https://docs.circom.io/circom-language/constraint-generation/
   c <== a*b;
}

// component类似于其他编程语言中的Object
// Doc：https://docs.circom.io/circom-language/the-main-component/
component main = Multiplier();


// run circom circuit.circom --r1cs --wasm --sym
// 1）--r1cs outputs the constraints in r1cs format
// 2）--wasm Compiles the circuit to wasm
// 3）--sym outputs witness in sym format 