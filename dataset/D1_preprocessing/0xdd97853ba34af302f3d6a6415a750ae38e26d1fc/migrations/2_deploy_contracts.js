var contract = artifacts.require("betContractUP"); 
module.exports = function(deployer) {
   deployer.deploy(contract);
};
