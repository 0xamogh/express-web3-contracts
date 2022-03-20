pragma v0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract ExpressWeb3Resolver is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    mapping(bytes32 => string) public hashmap;

    constructor(){
        oracle = 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8;
        jobId = "d5270d1c311941d0b08bead21fea7747";
        fee = 0.1*10**18; // figure out fee scene
    }

    function resolve(bytes calldata ipfsHash) public returns (bytes32 requestId){
        bytes memory url = "localhost:5001/api/v0/cat?arg="; 
        Chainlink.request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        request.add("get", url + ipfsHash);
        bytes32 requestId = sendChainlinkRequestTo(oracle, request, fee);
        hashmap[requestId] = ipfsHash;
        return requestId;
    }

    function fullfill(uint calldata request_id, string calldata _md5hash) public recordChainlinkFulfillment(_requestId) {
        hashmap[request_id] = _md5hash;
    }

    function resolveCallback(string calldata request_id, string calldata md5) public returns (bool verified){
        // should add check to see if the request is completed/pending/errored out
        return hashmap[request_id] == md5;
    }
}