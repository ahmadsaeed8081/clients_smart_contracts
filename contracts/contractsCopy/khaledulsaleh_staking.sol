//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface DUSD{
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) ;
    }
contract Invest
    {
       
        address  public owner;
        address SMCcontract=0x61D0D2369083609A30A1a1b86ba790ffb3d609f0;
        address BUSDcontract=0x61D0D2369083609A30A1a1b86ba790ffb3d609f0;


        // address SMCcontract=0x92Fe38a3589314179a2415a3FCFbe9a4FE1e43f8;
        // address BUSDcontract=0x92Fe38a3589314179a2415a3FCFbe9a4FE1e43f8;
        uint reward_per_day=191;
        uint public totalDUSDInvestors;
        uint public rewardToken=5000000000000000000;//50000000
        uint public min_Stake_amount=10000;  //10000000000000000000000
        uint public max_Stake_amount=5000000; //5000000000000000000000000
        uint public denomenator=100000; //5000000000000000000000000
        uint public investmentPeriod=365 days;
        uint public totalbusiness; 
        uint rew_till_done;
        mapping(uint=>address) public All_investors;

        struct allInvestments{

            uint investedAmount;
            uint withdrawnTime;
            uint DepositTime;
            uint investmentNum;
            uint unstakeTime;
            bool unstake;



        }

        struct ref_data{
            uint reward;
            uint count;
        }

        struct Admin_Data{

            address investor;
            uint totalInvestment;
            uint reward;
            uint noOfInvestment;
            uint totalWithdraw_reward;
            uint Total_referrals;
        }

        struct Data{

            mapping(uint=>allInvestments) investment;
            address[] hisReferrals;
            address referralFrom;
            mapping(uint=>ref_data) referralLevel;
            uint reward;
            uint noOfInvestment;
            uint totalInvestment;
            uint totalWithdraw_reward;
            bool investBefore;
            uint stakeTime;
        }
  
        mapping(address=>Data) public DUSDinvestor;

        constructor(){
            
            owner=msg.sender;              //here we are setting the owner of this contract

        }

       


        function Stake(uint _investedamount) external returns(bool success){
            require(_investedamount >= min_Stake_amount && _investedamount <= max_Stake_amount,"value is not greater than 10000 and less than 5000000");     //ensuring that investment amount is not less than zero
         

            if(DUSDinvestor[msg.sender].investBefore == false)
            { 
                All_investors[totalDUSDInvestors]=msg.sender;

                totalDUSDInvestors++;                                     
            }


            if(DUSDinvestor[msg.sender].totalInvestment == 0)
            { 
                DUSDinvestor[msg.sender].stakeTime = block.timestamp + 365 days;
            }
            uint num = DUSDinvestor[msg.sender].noOfInvestment;
            DUSDinvestor[msg.sender].investment[num].investedAmount =_investedamount;
            DUSDinvestor[msg.sender].investment[num].DepositTime=block.timestamp;
            DUSDinvestor[msg.sender].investment[num].withdrawnTime=block.timestamp + investmentPeriod ;  // 300 days
            DUSDinvestor[msg.sender].investment[num].investmentNum=num;
            DUSDinvestor[msg.sender].totalInvestment+=_investedamount;
            DUSDinvestor[msg.sender].noOfInvestment++;
            totalbusiness+=_investedamount;
            // DUSD(SMCcontract).transferFrom(msg.sender,owner,_investedamount*10**18);

            DUSDinvestor[msg.sender].investBefore=true;

            return true;
            
        }
        function getReward() view public returns(uint){ //this function is get the total reward balance of the investor
            uint totalReward;
            uint depTime;
            uint rew;
            uint temp = DUSDinvestor[msg.sender].noOfInvestment;
            for( uint i = 0;i < temp;i++)
            {   
                if(!DUSDinvestor[msg.sender].investment[i].unstake)
                {
                    depTime =block.timestamp - DUSDinvestor[msg.sender].investment[i].DepositTime;
                }
                else{
                    depTime =DUSDinvestor[msg.sender].investment[i].unstakeTime - DUSDinvestor[msg.sender].investment[i].DepositTime;
                }
                depTime=depTime/60; //1 day
                if(depTime>0)
                {
                     rew  =  (((DUSDinvestor[msg.sender].investment[i].investedAmount * 6*10**18 )/ 100 )/365);


                    totalReward += depTime * rew;
                }
            }
            totalReward -= DUSDinvestor[msg.sender].totalWithdraw_reward;

            return totalReward;
        }



    function get_investor_Reward(address investor) view internal returns(uint){ //this function is get the total reward balance of the investor
            uint totalReward;
            uint depTime;
            uint rew;
            uint temp = DUSDinvestor[investor].noOfInvestment;
            for( uint i = 0;i < temp;i++)
            {   
                if(!DUSDinvestor[investor].investment[i].unstake)
                {
                    depTime =block.timestamp - DUSDinvestor[investor].investment[i].DepositTime;
                }
                else{
                    depTime =DUSDinvestor[investor].investment[i].unstakeTime - DUSDinvestor[investor].investment[i].DepositTime;
                }
                depTime=depTime/60; //1 day
                if(depTime>0)
                {
                     rew  =  (((DUSDinvestor[msg.sender].investment[i].investedAmount * 6*10**18 )/ 100 )/365);

                    totalReward += depTime * rew;
                }
            }
            totalReward -= DUSDinvestor[investor].totalWithdraw_reward;

            return totalReward;
        }




        function withdrawReward() external returns (bool success){
            uint Total_reward = getReward();
            require(Total_reward>0,"you dont have rewards to withdrawn");         //ensuring that if the investor have rewards to withdraw
        
            // DUSD(BUSDcontract).transfer(msg.sender,Total_reward);             // transfering the reward to investor             
            DUSDinvestor[msg.sender].totalWithdraw_reward+=Total_reward;

            return true;

        }


        function unStake() external  returns (bool success){
            require(DUSDinvestor[msg.sender].totalInvestment>0,"you dont have investment to withdrawn");             //checking that he invested any amount or not
            require(DUSDinvestor[msg.sender].stakeTime < block.timestamp,"you cant withdraw before 1 year");
            uint amount=DUSDinvestor[msg.sender].totalInvestment;
            uint temp = DUSDinvestor[msg.sender].noOfInvestment;
            uint from = rew_till_done;
   
      
            DUSD(SMCcontract).transfer(msg.sender,amount* 10**8);             //transferring this specific investment to the investor
            
            for( from=0;from < temp;from++)
            {   
                DUSDinvestor[msg.sender].investment[from].unstake =true;    
                DUSDinvestor[msg.sender].investment[from].unstakeTime =block.timestamp;    

                            

            }
            rew_till_done =DUSDinvestor[msg.sender].noOfInvestment;                                       
            DUSDinvestor[msg.sender].totalInvestment=0;           // decrease this invested amount from the total investment

            return true;

        }

        function getTotalInvestmentDUSD() public view returns(uint) {   //this function is to get the total investment of the ivestor
            
            return DUSDinvestor[msg.sender].totalInvestment;

        }

        function getAllDUSDinvestments() public view returns (allInvestments[] memory) { //this function will return the all investments of the investor and withware date
            uint num = DUSDinvestor[msg.sender].noOfInvestment;
            uint temp;
            uint currentIndex;
            
            for(uint i=0;i<num;i++)
            {
               if( DUSDinvestor[msg.sender].investment[i].investedAmount > 0 ){
                   temp++;
               }

            }
         
            allInvestments[] memory Invested =  new allInvestments[](temp) ;

            for(uint i=0;i<num;i++)
            {
               if( DUSDinvestor[msg.sender].investment[i].investedAmount > 0 ){
                 //allInvestments storage currentitem=DUSDinvestor[msg.sender].investment[i];
                   Invested[currentIndex]=DUSDinvestor[msg.sender].investment[i];
                   currentIndex++;
               }

            }
            return Invested;

        }



        function DUSDTotalReferrals() public view returns(uint){ // this function is to get the total number of referrals 
            return (DUSDinvestor[msg.sender].hisReferrals).length;
        }
        function DUSDTotalReferrals_inside(address investor) internal view returns(uint){ // this function is to get the total number of referrals 
            return (DUSDinvestor[investor].hisReferrals).length;
        }

        function DUSDReferralsList() public view returns(address[] memory){ //this function is to get the all investors list with there account number
           return DUSDinvestor[msg.sender].hisReferrals;
        }
        function setReward(uint _reward) public 
        {
            reward_per_day=_reward;

        }
        function set_min_Stake_amount(uint _amount) public 
        {
            min_Stake_amount = _amount;
        }
        function set_max_Stake_amount(uint _amount) public 
        {
            max_Stake_amount = _amount;
        }
        function set_values(uint min_stake,uint max_stake,uint _reward_per_day,uint _denomenator) public 
        {
            max_Stake_amount = max_stake;
            min_Stake_amount = min_stake;
            rewardToken = _reward_per_day;
            denomenator = _denomenator;
        }
        function transferOwnership(address _owner)  public
        {
            require(msg.sender==owner,"only Owner can call this function");
            owner = _owner;
        }

        function referralLevel_earning() public view returns( uint[] memory arr )
        {
            uint[] memory referralLevels_reward=new uint[](20);
            for(uint i=0;i<20;i++)
            {
                if(DUSDinvestor[msg.sender].referralLevel[i].reward>0)
                {
                    referralLevels_reward[i] = DUSDinvestor[msg.sender].referralLevel[i].reward;


                }
                else{

                    referralLevels_reward[i] = 0;

                }


            }
            return referralLevels_reward ;


        }
        function referralLevel_count() public view returns( uint[] memory arr )
        {
            uint[] memory referralLevels_reward=new uint[](20);
            for(uint i=0;i<20;i++)
            {
                if(DUSDinvestor[msg.sender].referralLevel[i].reward>0)
                {
                    referralLevels_reward[i] = DUSDinvestor[msg.sender].referralLevel[i].count;


                }
                else{
                    referralLevels_reward[i] = 0;

                }


            }
            return referralLevels_reward ;


        }

        function Admin_data() view public returns(Admin_Data[] memory){

            Admin_Data[] memory Temp=new Admin_Data[](totalDUSDInvestors);
            
            for(uint i=0;i<totalDUSDInvestors;i++)
            {
               Temp[i].investor = All_investors[i];
               Temp[i].totalInvestment = DUSDinvestor[All_investors[i]].totalInvestment;
               Temp[i].reward=get_investor_Reward(All_investors[i]);
               Temp[i].noOfInvestment = DUSDinvestor[All_investors[i]].noOfInvestment;
               Temp[i].totalWithdraw_reward = DUSDinvestor[All_investors[i]].totalWithdraw_reward;
               Temp[i].Total_referrals = DUSDTotalReferrals_inside(All_investors[i]);

               
            }
            return Temp;
            

        }

        function total_withdraw_reaward() view public returns(uint){


            uint Temp = DUSDinvestor[msg.sender].totalWithdraw_reward;

            return Temp;
            

        }


    } 