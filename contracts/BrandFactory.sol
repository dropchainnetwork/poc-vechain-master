pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract ParticipantFactory is Ownable {

    enum ParticipantRole { ADMIN, BRAND, DISTRIBUTOR, SMB }

    event NewParticipant(address participantAddress, string name, ParticipantRole role);

    struct Participant {
        string name;
        ParticipantRole role;
    }

    mapping (address => Participant) public addressToParticipant;

    function createParticipant(address _addr, string _name, ParticipantRole _role) internal onlyOwner() {
        addressToParticipant[_addr] = Participant(_name, _role);
        emit NewParticipant(_addr, _name, _role);
    }

    function getParticipant(address _addr) public view returns (string name, ParticipantRole role){
        Participant memory participant = addressToParticipant[_addr];
        return (participant.name, participant.role);
    }
}
