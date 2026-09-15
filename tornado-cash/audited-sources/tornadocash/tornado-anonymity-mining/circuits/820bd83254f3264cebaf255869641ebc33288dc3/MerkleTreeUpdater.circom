include "./MerkleTree.circom";

// inserts a leaf into a tree
// checks that tree previously contained zero in the same position
template MerkleTreeUpdater(n, zeroLeaf) {
    signal input oldRoot;
    signal input newRoot;
    signal input leaf;
    signal input pathIndices;
    signal private input pathElements[n];

    component treeBefore = MerkleTree(n);
    for(var i = 0; i < n; i++) {
        treeBefore.pathElements[i] <== pathElements[i];
    }
    treeBefore.pathIndices <== pathIndices;
    treeBefore.leaf <== zeroLeaf;
    treeBefore.root === oldRoot;

    component treeAfter = MerkleTree(n);
    for(var i = 0; i < n; i++) {
        treeAfter.pathElements[i] <== pathElements[i];
    }
    treeAfter.pathIndices <== pathIndices;
    treeAfter.leaf <== leaf;
    treeAfter.root === newRoot;
}
