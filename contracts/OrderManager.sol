pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./ParticipantManager.sol";

contract OrderManager is ParticipantManager {

    enum OrderStatus {PENDING, DEACTIVATED, OVERDUE, RECEIVED}

    event CreateOrder(uint orderId, uint[] unitIds, address participantAddress, string payload);
    event CreateCustomOrder(uint orderId, uint[] unitIds, address participantAddress, string payload);
    event CreateUnit(uint unitId, address brandAddress, string payload);
    event DeactivateOrder(uint orderId, address diactivatedBy);
    event CheckInOrder(uint orderId);
    event ReceiveOrder(uint orderId);
    event CreateCustomOrder(uint orderId, uint[] unitIds, string payload);

    struct Order {
        string payload;
        OrderStatus status;
    }

    struct Unit {
        address brandAddress;
        string payload;
        uint orderId;
    }

    uint256 unitPrice = 1 * 10**uint(18);
    uint256 checkInFee = 1 * 10**uint(17);

    Order[] public orders;
    Unit[] public units;
    BuzzTokenContract buzzTokenContract;

    constructor(address _erc20Address) public {
        buzzTokenContract = BuzzTokenContract(_erc20Address);
    }

    mapping(uint => address) public orderToParticipant;

    function createUnit(string _payload) public onlyBrand() {
        require(buzzTokenContract.transferFrom(msg.sender, address(this), unitPrice));

        uint id = units.push(Unit(msg.sender, _payload, 0));

        emit CreateUnit(id, msg.sender, _payload);
    }

    function createOrder(uint[] _unitIds, string _payload) public onlyBrand() {
        uint id = orders.push(Order(_payload, OrderStatus.PENDING));

        // validate unitIds if they exist, belong to brand and not in order
        for (uint i = 0; i < _unitIds.length - 1; i++) {
            require(units[_unitIds[i]].brandAddress == msg.sender);
            require(units[_unitIds[i]].orderId == 0);
            units[_unitIds[i]].orderId = id;
        }

        orderToParticipant[id] = msg.sender;

        emit CreateOrder(id, _unitIds, msg.sender, _payload);
    }

    function createCustomOrder(uint[] _unitIds, string _payload) public onlyDistributor() {
        require(_unitIds.length >= 0);

        uint id = orders.push(Order(_payload, OrderStatus.PENDING));

        for (uint i = 0; i < _unitIds.length - 1; i++) {
            require(orderToParticipant[units[_unitIds[i]].orderId] == msg.sender);
            require(orders[units[_unitIds[i]].orderId - 1].status == OrderStatus.DEACTIVATED);
            units[_unitIds[i]].orderId = id;
        }

        orderToParticipant[id] = msg.sender;

        emit CreateCustomOrder(id, _unitIds, msg.sender, _payload);
    }

    function deactivateOrder(uint _orderId) public onlyDistributor() {
        require(orderToParticipant[_orderId] == msg.sender);
        require(orders[_orderId - 1].status == OrderStatus.PENDING);

        orders[_orderId - 1].status = OrderStatus.DEACTIVATED;

        emit DeactivateOrder(_orderId, msg.sender);
    }

    function checkInOrder(uint _orderId) public onlyDistributor() {
        require(orders[_orderId - 1].status == OrderStatus.PENDING);
        require(buzzTokenContract.transfer(msg.sender, checkInFee));

        orderToParticipant[_orderId] = msg.sender;

        emit CheckInOrder(_orderId);
    }

    function receiveOrder(uint _orderId) public onlySMB() {
        require(orders[_orderId - 1].status == OrderStatus.PENDING);
        require(buzzTokenContract.transfer(msg.sender, checkInFee));

        orderToParticipant[_orderId] = msg.sender;

        orders[_orderId - 1].status = OrderStatus.RECEIVED;

        emit ReceiveOrder(_orderId);
    }
}

contract BuzzTokenContract is ERC20 {}
