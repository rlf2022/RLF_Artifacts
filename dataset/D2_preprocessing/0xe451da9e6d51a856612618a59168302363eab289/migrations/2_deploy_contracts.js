var contract = artifacts.require("SimpleDonate"); 
module.exports = function(deployer) {
   deployer.deploy(contract,"contractName");
};
