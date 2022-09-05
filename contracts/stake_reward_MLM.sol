//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface DUSD{
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) ;
    }
contract Invest
    {
       
        address  public owner;
        // address SMCcontract=0x4d00DDCC526c14Fd353131F289b1e62C856E9737;
        // address BUSDcontract=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;


        address SMCcontract=0x9462A065c980693808405eB4f2851f0FfA1d3016;
        address BUSDcontract=0xc8BbA86A801Cd87ca72222d5A43639592fbAA6EC;

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

        function sendRewardToDUSDReferrals(address investor,uint _investedAmount)  internal  //this is the freferral function to transfer the reawards to referrals
        { 

            address temp = investor;       
            uint[] memory percentage = new uint[](5);
            percentage[0] = 5;
            percentage[1] = 3;
            percentage[2] = 2;
            percentage[3] = 1;
            percentage[4] = 1;


            uint j;



            for(uint i=0;i<20;i++)
            {

                if(i==0)
                {
                    j=0;
                }
                else if(i==1)
                {
                    j=1;
                }
                else if(i==2)
                {
                    j=2;
                }
                else if(i>7)
                {
                    j=4;
                }
                else if(i>2)
                {
                    j=3;
                }
                
                if(DUSDinvestor[temp].referralFrom!=address(0))
                {

                    temp=DUSDinvestor[temp].referralFrom;
                    uint reward1 = ((percentage[j]*100000000) * _investedAmount)/100;
                    if(j==4)
                    {
                        reward1 = reward1/2;
                    }
                    // rewardToken=reward1;
                    DUSD(SMCcontract).transfer(temp,reward1);
                    DUSDinvestor[temp].referralLevel[i].reward+=reward1;
                    DUSDinvestor[temp].referralLevel[i].count++;


                } 
                else{
                    break;
                }

            }

        }


        function Stake(uint _investedamount,address _referral) external returns(bool success){
            require(_investedamount >= min_Stake_amount && _investedamount <= max_Stake_amount,"value is not greater than 10000 and less than 5000000");     //ensuring that investment amount is not less than zero
         

            if(DUSDinvestor[msg.sender].investBefore == false)
            { 
                All_investors[totalDUSDInvestors]=msg.sender;

                totalDUSDInvestors++;                                     
            }
            else{

                _referral = DUSDinvestor[msg.sender].referralFrom;

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
            DUSD(SMCcontract).transferFrom(msg.sender,address(this),_investedamount*10**8);

            // if(_referral==address(0) || _referral==msg.sender)                                         //checking that investor comes from the referral link or not
            // {

            //     DUSDinvestor[msg.sender].referralFrom = address(0);
            // }
            // else
            // {
            //     if(DUSDinvestor[msg.sender].investBefore == false)
            //     { 
            //         DUSDinvestor[msg.sender].referralFrom = _referral;
            //         DUSDinvestor[_referral].hisReferrals.push(msg.sender);
            //     }
            //     sendRewardToDUSDReferrals(msg.sender,_investedamount);      //with this function, sending the reward to the all 12 parent referrals
                
            // }
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
                    // rew  = ((DUSDinvestor[msg.sender].investment[i].investedAmount)*rewardToken)/denomenator;
                    rew  = ((DUSDinvestor[msg.sender].investment[i].investedAmount)*50)/10000;

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
                    // rew  = ((DUSDinvestor[investor].investment[i].investedAmount)*rewardToken)/denomenator;
                    rew  = ((DUSDinvestor[investor].investment[i].investedAmount)*50)/10000;

                    totalReward += depTime * rew;
                }
            }
            totalReward -= DUSDinvestor[investor].totalWithdraw_reward;

            return totalReward;
        }




        function withdrawReward() external returns (bool success){
            uint Total_reward = getReward();
            require(Total_reward>0,"you dont have rewards to withdrawn");         //ensuring that if the investor have rewards to withdraw
            uint reward21 = (Total_reward*21)/100;
            
            address parent_referral = DUSDinvestor[msg.sender].referralFrom;
            if(parent_referral != address(0)){

                DUSD(BUSDcontract).transfer(parent_referral,reward21*10**18);             // transfering the reward to investor             
                DUSD(BUSDcontract).transfer(msg.sender,(Total_reward-reward21)*10**18);             // transfering the reward to investor             

            }
            else{
                DUSD(BUSDcontract).transfer(msg.sender,Total_reward*10**18);             // transfering the reward to investor             

            }

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
        function setReward(uint _amount,uint _denomenator) public 
        {
            rewardToken = _amount;
            denomenator = _denomenator;

        }
        function set_min_Stake_amount(uint _amount) public 
        {
            min_Stake_amount = _amount;
        }
        function set_max_Stake_amount(uint _amount) public 
        {
            max_Stake_amount = _amount;
        }
        function set_values(uint min_stake,uint max_stake,uint reward_per_day,uint _denomenator) public 
        {
            max_Stake_amount = max_stake;
            min_Stake_amount = min_stake;
            rewardToken = reward_per_day;
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