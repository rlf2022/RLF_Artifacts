pragma solidity ^0.4.25;

/**
  Multiplier contract: returns 200% of each investment!
  Automatic payouts!
  No bugs, no backdoors, NO OWNER - fully automatic!
  Made and checked by professionals!

  1. Send any sum to smart contract address
     - start sum from 0.01 to 1 ETH
     - min 250000 gas limit
     - you are added to a queue
  2. Wait a little bit
  3. ...
  4. PROFIT! You have got 200%

  How is that?
  1. The first investor in the queue (you will become the
     first in some time) receives next investments until
     it become 200% of his initial investment.
  2. You will receive payments in several parts or all at once
  3. Once you receive 200% of your initial investment you are
     removed from the queue.
  4. You can make multiple deposits
  5. The balance of this contract should normally be 0 because
     all the money are immediately go to payouts


     So the last pays to the first (or to several first ones
     if the deposit big enough) and the investors paid 200% are removed from the queue

                new investor --|               brand new investor --|
                 investor5     |                 new investor       |
                 investor4     |     =======>      investor5        |
                 investor3     |                   investor4        |
    (part. paid) investor2          инвестор5        |
                 инвестор3     |                   инвестор4        |
 (част. выплата) инвестор2     0){
            require(gasleft() >= 220000, "We require more gas!"); //We need gas to process queue
            require(msg.value <= maxDep); //Do not allow too big investments to stabilize payouts

            totalIn += msg.value;

            //Add the investor into the queue. Mark that he expects to receive 121% of deposit back
            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value*MULTIPLIER/100)));

            //Pay to first investors in line
            pay();
        }
    }

    //Used to pay to current investors
    //Each new transaction processes 1 - 4+ investors in the head of queue
    //depending on balance and gas left
    function pay() private {
        //Try to send all the money on contract to the first investors in line
        uint128 money = uint128(address(this).balance);

        //We will do cycle on the queue
        for(uint i=0; i= dep.expect){  //If we have enough money on the contract to fully pay to investor
                dep.depositor.send(dep.expect); //Send money to him
                money -= dep.expect;            //update money left

                //this investor is fully paid, so remove him
                delete queue[idx];
            }else{
                //Here we don't have enough money so partially pay to investor
                dep.depositor.send(money); //Send to him everything we have
                dep.expect -= money;       //Update the expected amount
                break;                     //Exit cycle
            }

            if(gasleft() <= 50000)         //Check the gas left. If it is low, exit the cycle
                break;                     //The next investor will process the line further
        }

        currentReceiverIndex += i; //Update the index of the current first investor
    }


}