# circom-snark
A zk-SNARK implementation, use [circom](https://github.com/iden3/circom) and [snarkjs](https://github.com/iden3/snarkjs)

# ToDo

mkdir circuit.circom

```
template Multiplier() {
   signal private input a;
   signal private input b;
   signal output c;
   c <== a*b;
}

component main = Multiplier();
```
change circuit

```
template Multiplier() {
   signal private input a;
   signal private input b;
   signal output c;
   signal inva;
   signal invb;

   inva <-- 1/(a-1);
   (a-1)*inva === 1;
   invb <-- 1/(b-1);
   (b-1)*invb === 1;

   c <== a*b;
}

component main = Multiplier();
```

# References

[1] : Create your first [zero-knowledge snark circuit](https://blog.iden3.io/first-zk-proof.html) using circom and snarkjs
