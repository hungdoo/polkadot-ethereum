pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract IncentivizedReceiveChannel {
    uint256 public lastProcessedNonce;

    // MAX_PAYLOAD_SIZE = 1000 bytes;
    // MAX_PAYLOAD_COST = 500000gas;
    // MAX_GAS_PER_MESSAGE = externallCallCost + max_payload_cost + max_processing_cost;

    struct Message {
        uint256 nonce;
        string senderApplicationId;
        address targetApplicationAddress;
        bytes payload;
    }

    struct Commitment {
        bytes commitmentHash;
    }

    struct CommitmentContents {
        Message[] messages;
    }

    constructor() public {
        lastProcessedNonce = 0;
    }

    function newParachainCommitment(
        Commitment memory commitment,
        CommitmentContents memory commitmentContents,
        uint256 parachainBlockNumber,
        bytes memory ourParachainMerkleProof,
        bytes memory parachainHeadsMMRProof
    ) public {
        verifyCommitment(
            commitment,
            commitmentContents,
            ourParachainMerkleProof,
            parachainHeadsMMRProof
        );
        processCommitmentContents(commitmentContents);
    }

    function verifyCommitment(
        Commitment memory commitment,
        CommitmentContents memory commitmentContents,
        bytes memory ourParachainMerkleProof,
        bytes memory parachainHeadsMMRProof
    ) internal returns (bool success) {
        // Prove we can get the MMRLeaf that is claimed to contain our Parachain Block Header
        // BEEFYLightClient.verifyMMRLeaf(parachainHeadsMMRProof)
        // BeefyLightClient{
        // verifyMMRLeaf(parachainHeadsMMRProof) {
        //MMRVerification.verifyInclusionProof(latestMMRRoot, parachainHeadsMMRProof)
        // }
        //}
        //}
        // returns mmrLeaf;

        // Prove we can get the claimed parachain block header from the MMRLeaf
        // allParachainHeadsMerkleTreeRoot = mmrLeaf.parachain_heads;
        // MerkeTree.verify(allParachainHeadsMerkleTreeRoot, ourParachainMerkleProof)
        // returns parachainBlockHeader

        // Prove that the commitment is in fact in the parachain block header
        // require(parachainBlockHeader.commitment == commitment)

        // Prove that the commitmentContents match the commitment
        // require(commitment == hash(commitmentContents))

        // Require there is enough gas to play all messages
        // require(leftovergas == commitmentContents.length * MAX_GAS_PER_MESSAGE)

        // Require all payloads are smaller than max_payload_size
        //for(message in commitmentContents) {
        //require(size(message.payload) <= MAX_PAYLOAD_SIZE )
        //}
        return true;
    }

    function processCommitmentContents(
        CommitmentContents memory commitmentContents
    ) internal {
        // for(message in commitmentContents) {
        // Check message nonce is correct and increment nonce for replay protection
        // require(message.nonce == lastProcessedNonce+1)
        // lastProcessedNonce = lastProcessedNonce + 1
        // Deliver the message to the destination
        // Delivery will have fixed maximum gas allowed for the destination app.
        // g = MAX_GAS_PER_MESSAGE
        // in = payload;
        // ...
        // call(g, a, v, in, insize, out, outsize)
        // call is expected to be fire and forget. if the call reverts, runs out of gas, error,
        // etc, its the fauly of the application and we don't care
        // }
    }
}