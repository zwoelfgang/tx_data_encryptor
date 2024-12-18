// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test} from "forge-std/Test.sol";
import {Encryptor} from "../src/tx_data_encryptor.sol";

contract EncryptorTest is Test {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Encryptor encryptor = new Encryptor();

        vm.stopBroadcast();
    }
}