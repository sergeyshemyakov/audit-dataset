include "./MerkleTree.circom";

// inserts a leaf into a tree
// checks that tree previously contained zero in the same position
template MerkleTreeUpdater(n, zeroLeaf) {
    signal input oldRoot;
    signal input newRoot;
    signal input leaf;
    signal input pathIndices;
    signal private input pathElements[n];

    // Compute indexBits once for both trees
    // Since Num2Bits is non deterministic, 2 duplicate calls to it cannot be
    // optimized by circom compiler
    component indexBits = Num2Bits(n);
    indexBits.in <== pathIndices;

    component treeBefore = RawMerkleTree(n);
    for(var i = 0; i < n; i++) {
        treeBefore.pathIndices[i] <== indexBits.out[i];
        treeBefore.pathElements[i] <== pathElements[i];
    }
    treeBefore.leaf <== zeroLeaf;
    treeBefore.root === oldRoot;

    component treeAfter = RawMerkleTree(n);
    for(var i = 0; i < n; i++) {
        treeAfter.pathIndices[i] <== indexBits.out[i];
        treeAfter.pathElements[i] <== pathElements[i];
    }
    treeAfter.leaf <== leaf;
    treeAfter.root === newRoot;
}
