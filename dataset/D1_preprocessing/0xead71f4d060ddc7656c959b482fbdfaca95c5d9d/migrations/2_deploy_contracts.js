var contract = artifacts.require("MyAdvancedToken"); 
module.exports = function(deployer) {
   deployer.deploy(contract,0xbebc200,"Test","IFIB");
};
