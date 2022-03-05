//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
contract MyContract {

    address payable admin;//adress of one who have deployed
    address payable wallet;//to store adress of a wallet where tracsaction is to be done
    uint256  public count=0;//count of Songs
    mapping(uint256=>Music) public musicDirectory ;
    mapping(uint256=>string) spectCodeSecretVault;//a secret vault where index of a Music is mapped to a 
    //special string code by which only the user who have given a royalty would be awarded a that string
    mapping(address => uint256) public balances ;//a mapping by which a user can easily check how many trasaction was made in this smart contract 
    mapping(string => string[]) public superFan;//a special map!! in which a fan can donate some royalty and get his name embedded with the name of the artist
    
    constructor(){
    admin  =payable(msg.sender);//sets deployer as admin
    }
     
    struct Music{
        uint256 _index;
     string _musicName;
     uint256 _downloads;//no of downloadsnloads
     string _artistName;
    address payable _artistAddress;  

    }

    //a modifier to check if the account which called the function is user
    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }
    //a modifier to check if the account which called the function have paid > O ETH
    modifier nonEmptyValue(){
        require(msg.value != 0);
        _;
    } 

    //to be by admin
    function registerNewMusic ( 
        string memory musicName,
        string memory artistName,
        string memory specCode_U,
        address payable artistAddress
        ) public onlyAdmin{
            
            
           musicDirectory[count]=Music(count,musicName,0,artistName,artistAddress);
           spectCodeSecretVault[musicDirectory[count]._index]=specCode_U;
       count++;
    }

    // A event for user to know about the purchase
    event Purchase(
        address indexed _buyer,
        uint256 _amount
    );

    //fallback function, in case someone want to supply ther to the admin
    fallback() external payable
    {
        wallet=admin;
        wallet.transfer(msg.value);
    }
    event Received(address, uint);
    receive() external payable {
        wallet=admin;
        wallet.transfer(msg.value);
        emit Received(msg.sender, msg.value);
    }

   //now we will make a getter function to get unique code of song to download it which will
   function getter(uint256 index) payable public nonEmptyValue returns(string memory){


        //sets wallets as the choosed song`s artist address
        wallet=musicDirectory[index]._artistAddress;
        //increase downloads by 1
        musicDirectory[index]._downloads+=1;
        
        //transfer royalty to wallet
        wallet.transfer(msg.value);

        //add 1 to wallet-transction(balance) from the user
        balances[msg.sender]+=1;
        
        //shows the address of buyer and amount
        emit Purchase(msg.sender, msg.value);

         return spectCodeSecretVault[index];//song can be accesed only by this
   }

//allows a user to donate to his favourite artist wuthout any return . Thats a TRUE SUPER FAN
function SuperFan(uint256 index,string memory Name) nonEmptyValue public payable{


      //sets wallets as the choosed songs address
        wallet=musicDirectory[index]._artistAddress;
        
        //transfer royalty to artist
        wallet.transfer(msg.value);
      
        superFan[musicDirectory[index]._artistName].push(Name);
   }


}
