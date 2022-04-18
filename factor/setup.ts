// youtube: https://www.youtube.com/watch?v=-9TJa1hVsKA

import { zkSnark } from 'snarkjs';
import circuit from './circuit.circom';
// "myCircuit.cir" is the output of the jaz compiler

const circuitDef = JSON.parse(fs.readFileSync("myCircuit.cir", "utf8"));
const circuit = new zkSnark.Circuit(circuitDef);

const setup = zkSnark.setup(circuit);
fs.writeFileSync("myCircuit.vk_proof", JSON.stringify(setup.vk_proof), "utf8");
fs.writeFileSync("myCircuit.vk_verifier", JSON.stringify(setup.vk_verifier), "utf8");
setup.toxic  // Must be discarded.