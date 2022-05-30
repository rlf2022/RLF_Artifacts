var contract = artifacts.require("EthGame"); 
module.exports = function(deployer) {
   deployer.deploy(contract,"0x04f87645ca7ea324800bff5996361ac9060ecde8","0x3362a2d61ec7a4a90d0c0af9a56def3992f295c8","0x64b3202ceb73cf195a48d7dc2567c6fe3ec1db52","0x24cf113f8a3c768085f269bb32c1cb5485a18fda","0xffd60def5117bc0fdf94a1da72089f8cb1e5d867",0xa);
};
