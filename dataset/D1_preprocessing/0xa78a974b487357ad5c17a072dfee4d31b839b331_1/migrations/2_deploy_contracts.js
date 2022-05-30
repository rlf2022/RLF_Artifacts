var contract = artifacts.require("HOT"); 
module.exports = function(deployer) {
   deployer.deploy(contract,0x3b9aca00,"HOTS",0x22b8);
};
