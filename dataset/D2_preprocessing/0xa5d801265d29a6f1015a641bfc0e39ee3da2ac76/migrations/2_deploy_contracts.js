var contract = artifacts.require("DocumentStore"); 
module.exports = function(deployer) {
   deployer.deploy(contract,"_name");
};
