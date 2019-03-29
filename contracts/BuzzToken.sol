pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

// Crowd sale token contract
// (c) by Pragmatic DLT
contract BuzzToken is ERC20, Ownable {
    using SafeMath for uint;

    string public name;
    string public symbol;
    uint public decimals;
    uint public totalSupply;
    uint public startDate;
    uint public bonusEnds;
    uint public endDate;

    // Amount of tokens per 1 ETH
    uint public exchangeRate;
    uint public bonusExchangeRate;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) approved;

    constructor() public {
        symbol = "TST";
        name = "Test ERC20 token";
        decimals = 18;
        bonusEnds = now + 1 weeks;
        endDate = now + 7 weeks;
        exchangeRate = 1000;
        bonusExchangeRate = 1200;

        balances[0x14e5486c5FCAa8F0495Fc055F1ee9B38E7A226E2] = 1000 * 10 ** uint(decimals);
        balances[0xCDd294a3d7A8Ac4f7B5fA811b2428F0fe484fd5D] = 1000 * 10 ** uint(decimals);
        balances[0x2eDB6e465caCd426278EE6fB3E7074F1A48c3F3B] = 1000 * 10 ** uint(decimals);
        balances[0x39FC5CAE00a805b56ce0B6c7E4956357Fb9F0fF4] = 1000 * 10 ** uint(decimals);
        balances[0xA76A210A999378c62339dBB1e6826F90Ec5Fb911] = 1000 * 10 ** uint(decimals);
        balances[0x7a150B13A27495898a8ba409DAe590a0DBC27970] = 1000 * 10 ** uint(decimals);

        balances[0x0EE4DD95CeA8F38BdF0E46033616915420Bd1852] = 1000 * 10 ** uint(decimals);
        balances[0x799e74DDDfd7886e3054494Db40413b26753a062] = 1000 * 10 ** uint(decimals);
        balances[0x805B30b7eFBFe78dE9D2178F50A2C6c882F352B6] = 1000 * 10 ** uint(decimals);
        balances[0x1dd4DcA7E1aD837463Df09aee50b69B7B6530545] = 1000 * 10 ** uint(decimals);
        balances[0xE3d8D6d4ed3F639CaE8Bc232EC51130DBEA344F2] = 1000 * 10 ** uint(decimals);

    }

    function totalSupply() public view returns (uint) {
        return totalSupply - balances[address(0)];
    }

    function balanceOf(address _tokenOwner) public view returns (uint) {
        return balances[_tokenOwner];
    }

    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) public view returns (uint) {
        return approved[_owner][_spender];
    }

    // Transfers _value amount of tokens to address _to, and fires the Transfer event.
    // If the _from account balance does not have enough tokens to spend - revert.
    // Transfers of 0 values are treated as normal transfers and the Transfer event is fired.
    function transfer(address _to, uint _value) public returns (bool) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Transfers _value amount of tokens from address _from to address _to and fires the Transfer event.
    // Transfers of 0 values are treated as normal transfers and the Transfer event is fired.
    // The calling account must already have sufficient tokens approved
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require(balances[_from] >= _value);
        require(approved[_from][msg.sender] >= _value);

        balances[_from] = balances[_from].sub(_value);
        approved[_from][msg.sender] = approved[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    // Allows _spender to withdraw multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint _value) public returns (bool) {
        approved[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function() public payable {
        require(now >= startDate && now <= endDate);
        require(msg.value >= 1 finney);

        uint tokens;

        if (now <= bonusEnds) {
            tokens = msg.value.mul(exchangeRate);
        } else {
            tokens = msg.value.mul(bonusExchangeRate);
        }

        balances[msg.sender] = balances[msg.sender].add(tokens);
        totalSupply = totalSupply.add(tokens);

        emit Transfer(address(0), msg.sender, tokens);
        owner.transfer(msg.value);
    }

    // Token owner can approve for _spender to 'transferFrom' tokens from the token owner's account.
    // The `spender` contract function `receiveApproval` is then executed
    function approveAndCall(address _spender, uint _value, bytes _data) public returns (bool) {
        approved[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _value, this, _data);
        return true;
    }

    // Owner can transfer out any accidentally sent ERC20 tokens
    function transferAnyERC20Token(address _tokenAddress, uint _value) public returns (bool) {
        return ERC20(_tokenAddress).transfer(owner, _value);
    }
}

// Contract function to receive approval and execute function in one call
contract ApproveAndCallFallBack {
    function receiveApproval(address _from, uint256 _value, address _tokenAddress, bytes _data) public;
}
