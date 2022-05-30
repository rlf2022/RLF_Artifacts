var contract = artifacts.require("MyAdvancedToken"); 
module.exports = function(deployer) {
   deployer.deploy(contract,0x2d4cae00,"MSV","MSV");
};
