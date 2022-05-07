pragma solidity ^0.4.25;

/**
 * Web - https://ethmoon.cc/
 * RU  Telegram_chat: https://t.me/ethmoonccv2
 *
 *
 * Multiplier ETHMOON_V3: returns 115%-120% of each investment!
 * Fully transparent smartcontract with automatic payments proven professionals.
 * 1. Send any sum to smart contract address
 *    - sum from 0.21 to 5 ETH
 *    - min 400000 gas limit
 *    - you are added to a queue
 * 2. Wait a little bit
 * 3. ...
 * 4. PROFIT! You have got 115%-120%
 *
 * How is that?
 * 1. The first investor in the queue (you will become the
 *    first in some time) receives next investments until
 *    it become 115%-120% of his initial investment.
 * 2. You will receive payments in several parts or all at once
 * 3. Once you receive 115%-120% of your initial investment you are
 *    removed from the queue.
 * 4. You can make more than one deposits at once
 * 5. The balance of this contract should normally be 0 because
 *    all the money are immediately go to payouts
 *
 *
 * So the last pays to the first (or to several first ones if the deposit big enough) 
 * and the investors paid 115%-120% are removed from the queue
 *
 *               new investor --|               brand new investor --|
 *                investor5     |                 new investor       |
 *                investor4     |     =======>      investor5        |
 *                investor3     |                   investor4        |
 *   (part. paid) investor2          инвестор5        |
 *                инвестор3     |                   инвестор4        |
 * (част. выпл.)  инвестор2     uint) public participation;

    // the deposit structure holds all the info about the deposit made
    struct Deposit {
        address depositor; // the depositor address
        uint128 deposit;   // the deposit amount
        uint128 expect;    // how much we should pay out (initially it is 115%-120% of deposit)
    }

    Deposit[] private queue;  // the queue
    uint public currentReceiverIndex = 0; // the index of the first depositor in the queue. The receiver of investments!

    // this function receives all the deposits
    // stores them and make immediate payouts
    function () public payable {
        require(gasleft() >= 250000, "We require more gas!"); // we need gas to process queue
        require(msg.sender != SMARTCONTRACT);
        require((msg.sender == STARTER) || (started));
        
        if (msg.sender != STARTER) {
            require((msg.value >= MIN_DEPOSIT) && (msg.value <= MAX_DEPOSIT)); // do not allow too big investments to stabilize payouts
            uint multiplier = percentRate(msg.sender);
            // add the investor into the queue. Mark that he expects to receive 115%-120% of deposit back
            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value * multiplier/100)));
            participation[msg.sender] = participation[msg.sender] + 1;
            
            // send smartcontract to the first EthmoonV2 for it to spin faster
            uint smartcontract = msg.value*SMARTCONTRACT_PERCENT/100;
            require(SMARTCONTRACT.call.value(smartcontract).gas(gasleft())());
            
            // send some promo to enable this contract to leave long-long time
            uint promo = msg.value * PROMO_PERCENT/100;
            PROMO.transfer(promo);
    
            // pay to first investors in line
            pay();
        } else {
            started = true;
        }
    }

    // used to pay to current investors
    // each new transaction processes 1 - 4+ investors in the head of queue 
    // depending on balance and gas left
    function pay() private {
        // try to send all the money on contract to the first investors in line
        uint128 money = uint128(address(this).balance);

        // we will do cycle on the queue
        for (uint i=0; i= dep.expect) {  // if we have enough money on the contract to fully pay to investor
                dep.depositor.transfer(dep.expect); // send money to him
                money -= dep.expect;            // update money left

                // this investor is fully paid, so remove him
                delete queue[idx];
            } else {
                // here we don't have enough money so partially pay to investor
                dep.depositor.transfer(money); // send to him everything we have
                dep.expect -= money;       // update the expected amount
                break;                     // exit cycle
            }

            if (gasleft() <= 50000)         // check the gas left. If it is low, exit the cycle
                break;                     // the next investor will process the line further
        }

        currentReceiverIndex += i; // update the index of the current first investor
    }

    // get the deposit info by its index
    // you can get deposit index from
    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }

    // get the count of deposits of specific investor
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for (uint i=currentReceiverIndex; i 0) {
            uint j = 0;
            for (uint i=currentReceiverIndex; i 0) {
            persent = persent + participation[depositor] * 5;
        }
        if (persent > 120) {
            persent = 120;
        } 
        return persent;
    }
}