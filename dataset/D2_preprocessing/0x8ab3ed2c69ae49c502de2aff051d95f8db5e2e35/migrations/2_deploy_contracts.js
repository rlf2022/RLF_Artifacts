var contract = artifacts.require("WeddingContract"); 
module.exports = function(deployer) {
   deployer.deploy(contract,"_partner_1_name","_partner_2_name","_contract_date","_declaration");
};
