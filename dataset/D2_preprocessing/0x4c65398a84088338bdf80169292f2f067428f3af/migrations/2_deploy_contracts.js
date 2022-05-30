var contract = artifacts.require("DSToken"); 
module.exports = function(deployer) {
   deployer.deploy(contract,"symbol_");
};
