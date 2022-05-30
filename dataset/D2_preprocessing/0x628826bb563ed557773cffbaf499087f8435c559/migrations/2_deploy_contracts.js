var contract = artifacts.require("Rox"); 
module.exports = function(deployer) {
   deployer.deploy(contract,"_name","_symbol","_uriToken");
};
