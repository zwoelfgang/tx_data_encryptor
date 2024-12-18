// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test} from "forge-std/Test.sol";
import {Encryptor} from "../src/tx_data_encryptor.sol";

contract EncryptorTest is Test {
    function test_SendMessage() public {
        Encryptor encryptor = new Encryptor();
        encryptor.sendMessage("Hi");
    }

    function test_KeyDeposit() public {
        Encryptor encryptor = new Encryptor();
        encryptor.sendMessage("Hi");
        encryptor.keyDeposit(3961, 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496, bytes(hex"0000000000000000000000000000000000000000000000000000000000000ef1"));        
    }
}