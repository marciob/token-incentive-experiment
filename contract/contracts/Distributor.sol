// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Tara.sol";

contract Distributor {
    address payable[] public recipients;

    Tara public taraContract;

    constructor(Tara _taraContract) {
        taraContract = _taraContract;
    }

    // adds addresses to the recipients list
    function addAddress(address payable[] memory _addresses) public payable {
        for (uint i = 0; i < _addresses.length; i++) {
            recipients.push(_addresses[i]);
        }
    }

    // removes an address from the recipients list
    function removeAddress(address _addressToRemove) public {
        uint index = 0;
        bool found = false;

        // Find the index of the address to remove
        for (uint i = 0; i < recipients.length; i++) {
            if (recipients[i] == _addressToRemove) {
                index = i;
                found = true;
                break;
            }
        }

        // If the address is found, remove it from the recipients list
        if (found) {
            // Move the last element to the index of the element to remove, then pop the last element
            recipients[index] = recipients[recipients.length - 1];
            recipients.pop();
        }
    }

    function mintAndDistribute(uint _amount) public {
        // Mint the total amount of tokens required
        taraContract.mint(address(this), _amount);

        // Calculate the share of each recipient, including the sender
        uint256 share = _amount / recipients.length;

        // Distribute the shares to the recipients list
        for (uint i = 0; i < recipients.length; i++) {
            // Approve the contract to transfer tokens on the sender's behalf
            require(
                taraContract.approve(address(this), share),
                "Approve failed"
            );

            // Transfer tokens from the contract to the recipient
            require(
                taraContract.transferFrom(address(this), recipients[i], share),
                "Transfer failed"
            );
        }
    }
}
