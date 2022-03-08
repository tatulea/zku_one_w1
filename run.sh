#!/bin/bash

# Compile the circuit
circom merkle_tree.circom --r1cs --wasm --sym --c

# Computing the witness with WebAssembly 
node merkle_tree_js/generate_witness.js merkle_tree_js/merkle_tree.wasm input.json witness.wtns

# Steps to create the proof using snarkjs
# 1. start a new "powers of tau" ceremony
# The number "14" is the power of 2 of the maximum number of constraints that the ceremony can accept
# In this case, the number of constraints is 2 ^ 14 = 16384
snarkjs powersoftau new bn128 14 pot12_0000.ptau -v

# 2. Contribute to the ceremony
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# 3. Prepare to start the phase 2, which is circuit specific
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

# 4. Generate a zkey file that contains the proving and verification keys
snarkjs groth16 setup merkle_tree.r1cs pot12_final.ptau merkle_tree_0000.zkey

# 5. Contribute to this ceremony
snarkjs zkey contribute merkle_tree_0000.zkey merkle_tree_0001.zkey --name="1st Contributor Name" -v

# 6. Export the verification key
snarkjs zkey export verificationkey merkle_tree_0001.zkey verification_key.json

# 7. Generate a proof associated to the circuit and the witness
snarkjs groth16 prove merkle_tree_0001.zkey witness.wtns proof.json public.json

# 8. Verify the proof
snarkjs groth16 verify verification_key.json public.json proof.json
