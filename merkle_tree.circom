pragma circom 2.0.0;

include "mimcsponge.circom";

template MerkleTree(n) {
    signal input leaves[n];
    signal output root;

    var total_hashes = n * 2 - 1;
    var mimc_hashes[total_hashes];
    component mimc_components[total_hashes];

    var left_hash_index = 0;

    for (var i = 0; i < total_hashes; i++) {
        if (i < n) {
            mimc_components[i] = MiMCSponge(1, 220, 1);
            mimc_components[i].ins[0] <== leaves[i];
            mimc_components[i].k <== 0;
            mimc_hashes[i] = mimc_components[i].outs[0];
        }
        else {
            mimc_components[i] = MiMCSponge(2, 220, 1);
            mimc_components[i].ins[0] <== mimc_hashes[left_hash_index];
            mimc_components[i].ins[1] <== mimc_hashes[left_hash_index + 1];
            mimc_components[i].k <== 0;

            mimc_hashes[i] = mimc_components[i].outs[0];

            left_hash_index += 2;
        }
    }

    root <== mimc_hashes[total_hashes - 1];
}

component main = MerkleTree(8);