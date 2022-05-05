<div align="center">
  <a href="https://www.artstation.com/artwork/lRZAQJ/">
    <img alt="eth logo" src="https://pbs.twimg.com/media/FQXMnOTXEAY5fzX?format=jpg&name=large" >
  </a>
  <p align="center">
    <a href="https://github.com/LuozhuZhang/zkps-circuit-demo/graphs/contributors">
      <img alt="GitHub contributors" src="https://img.shields.io/github/contributors/LuozhuZhang/zkps-circuit-demo">
    </a>
    <a href="http://makeapullrequest.com">
      <img alt="pull requests welcome badge" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat">
    </a>
    <a href="https://twitter.com/LuozhuZhang">
      <img alt="Twitter" src="https://img.shields.io/twitter/url/https/twitter.com/LuozhuZhang.svg?style=social&label=Follow%20%40LuozhuZhang">
    </a>
  </p>
</div>

# zk-SNARK

A zk-SNARK implementation, use [circom](https://github.com/iden3/circom) and [snarkjs](https://github.com/iden3/snarkjs)

Welcome to submit any issues or prs, also welcome DM me via [twitter](https://twitter.com/LuozhuZhang)

# English

### 一、initialize and setup

Create random numbers and circuits, get pk and vk through trusted setup

![image](https://user-images.githubusercontent.com/70309026/164189689-d6f3f6cb-1b3b-4da9-b3ac-87c40842bc12.png)

1. Install dependencies
```
yarn global add circom
yarn global add snarkjs
```

<br/>

2. Secure Multi-party Computation

Here is the output tool of zcash in ceremony[powersoftau](https://github.com/ebfull/powersoftau)

```
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau contribute pot12_0001.ptau pot12_0002.ptau --name="Second contribution" -v -e="some random text"

snarkjs powersoftau export challenge pot12_0002.ptau challenge_0003
snarkjs powersoftau challenge contribute bn128 challenge_0003 response_0003 -e="some random text"
snarkjs powersoftau import response pot12_0002.ptau response_0003 pot12_0003.ptau -n="Third contribution name"
```

Verify the ptau file so far
```
snarkjs powersoftau verify pot12_0003.ptau
```
> More info about [the powers of tau ceremony](https://zfnd.org/conclusion-of-the-powers-of-tau-ceremony/) and [MPC](https://en.wikipedia.org/wiki/Secure_multi-party_computation)

<br/>

3. Apply a random beacon，get final ptau file

```
snarkjs powersoftau beacon pot12_0003.ptau pot12_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"
snarkjs powersoftau prepare phase2 pot12_beacon.ptau pot12_final.ptau -v
```

Verify this ptau file
```
snarkjs powersoftau verify pot12_final.ptau
```

<br/>

4. Create circuit

Using [circom](https://github.com/iden3/circom) to write circuit，the [circomlib](https://github.com/iden3/circomlib) also encapsulates the basic circuit
```
cat <<EOT > circuit.circom

template Multiplier(n) {
    signal input a;
    signal input b;
    signal output c;

    signal int[n];

    int[0] <== a*a + b;
    for (var i=1; i<n; i++) {
    int[i] <== int[i-1]*int[i-1] + b;
    }

    c <== int[n-1];
}

component main = Multiplier(1000);
EOT
```
> More circom specification refer [official documentation](https://docs.circom.io/)

<br/>

5. Compile circuit

```
circom circuit.circom --r1cs --wasm --sym
```
View circuit information
```
snarkjs r1cs info circuit.r1cs
snarkjs r1cs print circuit.r1cs circuit.sym
```

<br/>

6. trusted setup
Export r1cs.json and create witness
```
snarkjs r1cs export json circuit.r1cs circuit.r1cs.json

cat <<EOT > input.json
{"a": 3, "b": 11}
EOT

circuit_js$ node generate_witness.js circuit.wasm ../input.json ../witness.wtns
// or
snarkjs wtns calculate circuit.wasm input.json witness.wtns
```

You can use the proof system of plonk or groth16，and there will be Halo2 developed by [Aztec](https://aztec.network/) and Zcash in the future
```
snarkjs plonk setup circuit.r1cs pot12_final.ptau circuit_final.zkey

snarkjs groth16 setup circuit.r1cs pot12_final.ptau circuit_0000.zkey
```

<br/>

7. Get pk and export the vk
```
snarkjs zkey export verificationkey circuit_final.zkey verification_key.json
```

### 二、create proof

![image](https://user-images.githubusercontent.com/70309026/164192749-c32b84ce-a6c3-4939-b93b-b107dee249a4.png)

Import pk、witness（s，private input）and x（public input），export proof
```
snarkjs plonk prove circuit_final.zkey witness.wtns proof.json public.json
```

### 三、verify proof

![image](https://user-images.githubusercontent.com/70309026/164193092-e1f4ba0e-9af4-4bc9-929b-6e624d2ed7b7.png)

Import proof、x（public input）and verification key，then verifiers can verify the result of proof

```
// plonk
snarkjs plonk verify verification_key.json public.json proof.json
// groth16
snarkjs groth16 verify verification_key.json public.json proof.json
```

### 四、deploy verification contract

Export solidity file，contracts can be deployed via [Remix](https://remix.ethereum.org/#optimize=false&runs=200&evmVersion=null)，you can call contract after deploy verifier.sol
```
snarkjs zkey export solidityverifier circuit_final.zkey verifier.sol
```

You can also use soliditycalldata to simulate the verification call, return the verifyProof field and put it in the environment where the remix contract is deployed
```
snarkjs zkey export soliditycalldata public.json proof.json
```

---

# 中文

### 一、初始化并setup

创建随机数和电路，通过可信度设置得到pk和vk

![image](https://user-images.githubusercontent.com/70309026/164189689-d6f3f6cb-1b3b-4da9-b3ac-87c40842bc12.png)

1. 安装依赖
```
yarn global add circom
yarn global add snarkjs
```

<br/>

2. 多方安全计算，为了保证随机数的安全性

这里使用的是zcash在ceremony产出的[powersoftau](https://github.com/ebfull/powersoftau)

```
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau contribute pot12_0001.ptau pot12_0002.ptau --name="Second contribution" -v -e="some random text"

snarkjs powersoftau export challenge pot12_0002.ptau challenge_0003
snarkjs powersoftau challenge contribute bn128 challenge_0003 response_0003 -e="some random text"
snarkjs powersoftau import response pot12_0002.ptau response_0003 pot12_0003.ptau -n="Third contribution name"
```

验证到目前为止的ptau file
```
snarkjs powersoftau verify pot12_0003.ptau
```
> 更多关于[the powers of tau ceremony](https://zfnd.org/conclusion-of-the-powers-of-tau-ceremony/)和[MPC](https://en.wikipedia.org/wiki/Secure_multi-party_computation)的信息

<br/>

3. 应用一个random beacon，得到最终的ptau file
```
snarkjs powersoftau beacon pot12_0003.ptau pot12_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"
snarkjs powersoftau prepare phase2 pot12_beacon.ptau pot12_final.ptau -v
```

验证这个ptau file
```
snarkjs powersoftau verify pot12_final.ptau
```

<br/>

4. 创建电路

使用[circom](https://github.com/iden3/circom)写circuit，在[circomlib](https://github.com/iden3/circomlib)中也封装了基本的电路
```
cat <<EOT > circuit.circom

template Multiplier(n) {
    signal input a;
    signal input b;
    signal output c;

    signal int[n];

    int[0] <== a*a + b;
    for (var i=1; i<n; i++) {
    int[i] <== int[i-1]*int[i-1] + b;
    }

    c <== int[n-1];
}

component main = Multiplier(1000);
EOT
```
> 更多circom规范可以参考[官方文档](https://docs.circom.io/)

<br/>

5. 编译电路

```
circom circuit.circom --r1cs --wasm --sym
```
查看电路信息
```
snarkjs r1cs info circuit.r1cs
snarkjs r1cs print circuit.r1cs circuit.sym
```

<br/>

6. trusted setup
导出r1cs.json，并创建witness
```
snarkjs r1cs export json circuit.r1cs circuit.r1cs.json

cat <<EOT > input.json
{"a": 3, "b": 11}
EOT

circuit_js$ node generate_witness.js circuit.wasm ../input.json ../witness.wtns
// or
snarkjs wtns calculate circuit.wasm input.json witness.wtns
```

可以使用plonk或groth16的proof system，未来还会有[Aztec](https://aztec.network/)和Zcash开发的Halo2
```
snarkjs plonk setup circuit.r1cs pot12_final.ptau circuit_final.zkey

snarkjs groth16 setup circuit.r1cs pot12_final.ptau circuit_0000.zkey
```

<br/>

7. 得到pk并导出对应的vk
```
snarkjs zkey export verificationkey circuit_final.zkey verification_key.json
```

### 二、创建proof

![image](https://user-images.githubusercontent.com/70309026/164192749-c32b84ce-a6c3-4939-b93b-b107dee249a4.png)

导入pk、witness（s，即private input）和x（public input），得到proof
```
snarkjs plonk prove circuit_final.zkey witness.wtns proof.json public.json
```

### 三、验证proof

![image](https://user-images.githubusercontent.com/70309026/164193092-e1f4ba0e-9af4-4bc9-929b-6e624d2ed7b7.png)

根据proof、x（public input）和verification key，Verifiers就可以验证proof的结果了

```
// plonk
snarkjs plonk verify verification_key.json public.json proof.json
// groth16
snarkjs groth16 verify verification_key.json public.json proof.json
```

### 四、部署和verification合约

导出solidity文件，可以通过[Remix](https://remix.ethereum.org/#optimize=false&runs=200&evmVersion=null)部署合约，部署verifier.sol调用即可
```
snarkjs zkey export solidityverifier circuit_final.zkey verifier.sol
```

也可以使用soliditycalldata模拟verification call，返回verifyProof字段后放到remix合约部署的环境中
```
snarkjs zkey export soliditycalldata public.json proof.json
```


# References

[1] : Create your first [zero-knowledge snark circuit](https://blog.iden3.io/first-zk-proof.html) using circom and snarkjs

[2] : Explaining SNARKs Part I: [Homomorphic Hidings](https://electriccoin.co/blog/snark-explain/)

[3] : What are [zk-SNARKs](https://z.cash/technology/zksnarks/)?

[4] : Why and How zk-SNARK Works 1: [Introduction & the Medium of a Proof](https://medium.com/@imolfar/why-and-how-zk-snark-works-1-introduction-the-medium-of-a-proof-d946e931160)

[5] : Why and [How zk-SNARK Works](https://arxiv.org/pdf/1906.07221.pdf): Definitive Explanation

[6] : [Zk-SNARKs](https://medium.com/@VitalikButerin/zk-snarks-under-the-hood-b33151a013f6): Under the Hood -- vitalik
