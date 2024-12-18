// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Encryptor {
    event MessageSent(address from, bytes encrypted, uint n, uint e, uint amount);
    event MessageDecrypted(address from, uint d, uint amount);

    mapping (bytes => uint) private tx_data;
    mapping (address => bytes) public messages;
    mapping (uint => uint) private balance;

    constructor() {
        address payable owner;
        owner = payable(msg.sender);
    }

    receive() external payable {}

    function sendMessage(string memory message) public payable {
        require(bytes(message).length <= 8, "Message must be under 8 bytes in size.");
        require(msg.value >= 10_000_000_000_000_000, "Insufficient funds for bounty.");

        (bytes memory rsaMessage, uint base, uint key, uint encryptor) = encryptMessage(message);

        tx_data[rsaMessage] = key;
        messages[msg.sender] = rsaMessage;
        balance[key] = msg.value;

        emit MessageSent(msg.sender, rsaMessage, base, encryptor, msg.value);
    }

    function keyDeposit(uint key, address sender, bytes memory rsaMessage) public payable {
        uint target = bytesToUint(messages[sender]);
        uint storedMessage = bytesToUint(rsaMessage);

        if (target == storedMessage && tx_data[rsaMessage] == key) {
            require(balance[key] >= 10_000_000_000_000_000, "Balance not available.");
            payable(msg.sender).transfer(balance[key]);
            emit MessageDecrypted(msg.sender, key, balance[key]);
        }
    }

    function encryptMessage(string memory message) internal view returns (bytes memory, uint, uint, uint) {
        uint timeStamp = ((uint((block.timestamp % 10_000)) ** 2) % 1_000_000) / 100;

        for (uint x = 1; timeStamp >= 3202 || timeStamp < 1009; x++) {
            timeStamp = (((timeStamp % 10_000) ** 2) % 1_000_000) / 100;
        }

        (bool prime, uint p, uint q) = primeChecker(timeStamp);

        while (!prime) {
            timeStamp--;
            (prime, p, q) = primeChecker(timeStamp);
        }

        require(prime, "Not a prime number.");

        uint n = p * q;
        uint phiN = (p - 1) * (q - 1);
        uint e = 0;
        uint k = 2;

        for (uint i = 2; i < 5; i++) {
            if (phiN % i != 0) {
                e = i;
                break;
            }
        }

        uint d = (k * phiN + 1) / e;
        bytes memory bytesMessage = bytes(message);
        uint numMessage = bytesToUint(bytesMessage);
        bytes memory encryptedMessage = abi.encodePacked(numMessage ** e % n);

        return (encryptedMessage, n, d, e);
    }

    function primeChecker(uint time) internal pure returns (bool, uint, uint) {
        uint step = (time + 1) / 2;
        uint sqrtTime = time;

        while (step < sqrtTime) {
            sqrtTime = step;
            step = (time / step + step) / 2;
        }

        sqrtTime++;

        uint x = 0;
        uint[] memory primes = new uint[](52);

        primes[0] = 2;

        for (uint i = 1; primes[i - 1] < sqrtTime; i++) {
            if (i == 1) {
                primes[i] = 3;
                x++;
            } else if (i == 2) {
                primes[i] = 5;
                x++;
            } else if (i == 3) {
                primes[i] = 7;
                x++;
            } else if (i == 4) {
                primes[i] = 11;
                x++;
            } else if (i == 5) {
                primes[i] = 13;
                x++;
            } else if (i == 6) {
                primes[i] = 17;
                x++;
            } else if (i == 7) {
                primes[i] = 19;
                x++;
            } else if (i == 8) {
                primes[i] = 23;
                x++;
            } else if (i == 9) {
                primes[i] = 29;
                x++;
            } else if (i == 10) {
                primes[i] = 31;
                x++;
            } else if (i == 11) {
                primes[i] = 37;
                x++;
            } else {
                primes[i] = i ** 2 + i + 41;
                x++;
            }
        }

        for (uint k = x; k > 0; k--) {
            if (time % primes[k] == 0) {
                delete primes;
                return (false, 0, 0);
            }
        }

        delete primes;

        return (true, time, 3);
    }

    function bytesToUint(bytes memory b) internal pure returns (uint) {
        uint number;

        for (uint i = 0; i < b.length; i++) {
            number = number + uint(uint8(b[i])) * (2 ** (8 * (b.length - (i + 1))));
        }

        return number;
    }
}