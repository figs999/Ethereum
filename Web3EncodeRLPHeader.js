/*
Author: Chance Santana-Wees
Contact Email: figs999@gmail.com

Pass in a block produced from web3.eth.GetBlock
Out comes an array of bytes you can pass to the BlockHeaderValidator.sol contract code

Note: This is a very simple RLP encoder, it won't encode anything but a block header into RLP.
*/

var encodeRLPHeader = function(block) {
	return  hexToBytes("f90205" + 
				encode_with_length(block.parentHash.slice(2)) +
				encode_with_length(block.sha3Uncles.slice(2)) +
				encode_with_length(block.miner.slice(2)) +
				encode_with_length(block.stateRoot.slice(2)) +
				encode_with_length(block.transactionsRoot.slice(2)) +
				encode_with_length(block.receiptsRoot.slice(2)) +
				"b90100" + block.logsBloom.slice(2) + 
				encode_with_length(block.difficulty.toString(16)) +
				encode_with_length(block.number.toString(16)) + 
				encode_with_length(block.gasLimit.toString(16)) + 
				encode_with_length(block.gasUsed.toString(16)) + 
				encode_with_length(block.timestamp.toString(16)) + 
				encode_with_length(block.extraData.slice(2)) +
				encode_with_length(block.mixHash.slice(2)) + 
				encode_with_length(block.nonce.slice(2)))
}

function hexToBytes(hex) {
	for (var bytes = [], c = 0; c < hex.length; c += 2)
	bytes.push(parseInt(hex.substr(c, 2), 16));
	return bytes;
}

var encode_with_length = function(input) {
	if(input.length % 2 != 0)
		input = "0" + input;
	return (input.length/2 + 128).toString(16) + input;
}