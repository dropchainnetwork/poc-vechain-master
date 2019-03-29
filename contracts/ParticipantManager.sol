pragma solidity ^0.4.21;

import "./BrandFactory.sol";

contract ParticipantManager is ParticipantFactory {

    function changeName(address addr, string _newName) external onlyOwner() {
        addressToParticipant[addr].name = _newName;
    }

    function createBrand(address _addr, string _name) external onlyOwner(){
        createParticipant(_addr, _name, ParticipantRole.BRAND);
    }

    function createSmb(address _addr, string _name) external onlyOwner(){
        createParticipant(_addr, _name, ParticipantRole.SMB);
    }

    function createDistributor(address _addr, string _name) external onlyOwner(){
        createParticipant(_addr, _name, ParticipantRole.DISTRIBUTOR);
    }

    modifier onlyBrand() {
        require(addressToParticipant[msg.sender].role == ParticipantRole.BRAND);
        _;
    }

    modifier onlyDistributor() {
        require(addressToParticipant[msg.sender].role == ParticipantRole.DISTRIBUTOR);
        _;
    }

    modifier onlySMB() {
        require(addressToParticipant[msg.sender].role == ParticipantRole.SMB);
        _;
    }
}
