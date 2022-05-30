var contract = artifacts.require("GLDS"); 
module.exports = function(deployer) {
   deployer.deploy(contract,"GoldDigitStandart","GLDS",0x12,0xe4e1c0);
};
