// circom语言默认的主要文件路径，circom本质是一个zkp的电路编程语言，而且初步接触下来应该是较为图灵完备的，就像solidity那些一样。The default main file path of circom language, circom is essentially a zkp circuit programming language, and the initial contact should be more Turing-complete, just like those of solidity.
// Doc：https://docs.circom.io/circom-language

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

