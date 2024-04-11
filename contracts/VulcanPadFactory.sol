// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 *Submitted for verification at basescan.org on 2024-04-2

 
                              *                              
                      **       ***                             
                      ****     ****                            
           *          *****    ******                           
          ***          ***     ********        *                 
          ***                  **********      ***               
         ******               ***********     *****               
         ******   ****       *************   *****               
          ****   ******    ****************   **                
               ********* *******  *********                     
            *****************      ********     ***             
          *****************        *******  ******             
         *****************      *   **************             
        ************ ****      **    **************             
      ***********     *      ***       *************             
      ***********         ******        **   *******             
      **********        *********           ********             
      ********** **   ***********     *      *******              
       ****** *  *************   ******    ********              
        *****    *********************     *******               
         ******  ********************      ******                
          ******   *****************     ******                  
             ******  *************    *******                    
               ********       *********                       
                     ********                    ⠀⠀⠀⠀⠀⠀⠀
 _     _           _                            ______               __          
| |   | |         | |                          (_____ \              | |   
| |   | |  _   _  | |  ____   __ _   _ __       _____) )  ____    ___| |  
| |   | | | | | | | | /  _ ) / _  | |  _  \    |  ____/  / _  |  /  _| |  
 \ \_/ /  | |_| | | |( (__  ( ( | | | | | |    | |      ( ( | | (  |_| |  
  \___/    \__,_) |_| \____) \_||_| |_| |_|    |_|       \_||_|  \_____)⠀

 *  https://vulcan.pad
 **/

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Vulcan } from "./Vulcan.sol";
// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract VulcanPadFactory {

    /// @dev owner of the factory
    address public owner;

    /// @dev DAI ERC20 token
    IERC20 public immutable daiToken;

    /// @dev spam filter fee amount 100 DAI as decimal is 18
    uint256 public feeAmount = 100 ether; 

    /// @dev tracks spam filter fee contributions of investors
    mapping(address => uint256) feeContributions; 

    /// @dev created ICOs
    address[] public vulcans;

    /// @dev launched ICO
    mapping(address => bool) isVulcan;

    /// @dev events
    event SpamFilterFeePaid(address user_, uint256 amount_);
    event ICOCreated(address user, string projectURI, uint256 softcap, uint256 hardcap, uint256 endTime, string name, string symbol, uint256 price, uint256 decimal, uint256 totalSupply, address tokenAddress);
    
    /// @dev validate if token address is non-zero
    modifier notZeroAddress(address token_) {
        require (token_ != address(0), "Invalid TOKEN address");
        _;
    }

    /// @dev validate if paid 100DAI spam filter fee
    modifier PaidSpamFilterFee(address user_) {
        require(
            feeContributions[user_] >= feeAmount,
            "Not paid spam filter fee"
        );
        _;
    }

    /// @dev validate endtime is valid
    modifier isFuture(uint256 endTime_) {
        require(endTime_ > block.timestamp, "End time should be in the future");
        _;
    }

    /// @dev validate softcap & hardcap setting
    modifier capSettingValid(uint256 softcap_, uint256 hardcap_) {
        require(softcap_ > 0, "Softcap must be greater than 0");
        require(hardcap_ > 0, "Hardcap must be greater than 0");
        require(hardcap_ > softcap_, "Softcap must less than hardcap");
        _;
    }

    /// @dev validate if token price is zero
    modifier notZeroPrice(uint256 price_) {
        require(price_ > 0, "Token price must greater than 0");
        _;
    }

    /// @dev validate if token decimal is zero
    modifier notZeroDecimal(uint256 decimal_) {
        require(decimal_ > 0, "Token decimal must greater than 0");
        _;
    }

    /// @dev validate if token totalsupply is zero
    modifier notZeroTotalSupply(uint256 totalSupply_) {
        require(totalSupply_ > 0, "Token totalSupply must greater than 0");
        _;
    }

    /**
     * @dev contructor
     * @param daiAddress_ DAI stable coin address for paying spam filter fee...
     */
    constructor(address daiAddress_) {
        require(daiAddress_ != address(0), "Invalid DAI address");
        daiToken = IERC20(daiAddress_);
        owner = msg.sender;
    }
    /**
     * @dev Pays non-refundable Spam filter fee 100DAI
     */
    function paySpamFilterFee() external {
        uint256 _balance = daiToken.balanceOf(msg.sender);
        require(_balance > feeAmount, "Insufficient Dai balance");
        
        bool _success = daiToken.approve(address(this), feeAmount);
        require(_success, "DAI approve failed");

        SafeERC20.safeTransferFrom(daiToken, msg.sender, address(this), feeAmount);
        feeContributions[msg.sender] += feeAmount;

        emit SpamFilterFeePaid (msg.sender, feeAmount);
    }
    /**
     * @dev launch new ICO
     * @param projectURI_ project metadata uri "https://ipfs.."
     * @param softcap_ softcap for ICO 100 * 10**18
     * @param hardcap_ hardcap for ICO  200 * 10**18
     * @param endTime_ ICO end time 1762819200000
     * @param name_ token name "vulcan token"
     * @param symbol_ token symbol "$VULCAN"
     * @param price_ token price for ICO 0.01 * 10**18
     * @param decimal_ token decimal 18
     * @param totalSupply_ token totalSupply 1000000000 * 10**18
     * @param tokenAddress_ token address 0x810fa...
     */
    function launchNewICO(
        string memory projectURI_,
        uint256 softcap_,
        uint256 hardcap_,
        uint256 endTime_,
        string memory name_,
        string memory symbol_,
        uint256 price_,
        uint256 decimal_,
        uint256 totalSupply_,
        address tokenAddress_
    )
        public
        PaidSpamFilterFee(msg.sender)
        capSettingValid(softcap_, hardcap_)
        isFuture(endTime_)
        notZeroPrice(price_)
        notZeroDecimal(decimal_)
        notZeroTotalSupply(totalSupply_)
        notZeroAddress(tokenAddress_)
        returns (address)
    {
        Vulcan _newVulcan = new Vulcan(
            projectURI_,
            softcap_,
            hardcap_,
            endTime_,
            name_,
            symbol_,
            msg.sender,
            price_,
            decimal_,
            totalSupply_,
            tokenAddress_
        );

        address _vulcan = address (_newVulcan);
        vulcans.push(_vulcan);
        isVulcan[_vulcan] = true;
        emit ICOCreated (msg.sender, projectURI_, softcap_, hardcap_, endTime_, name_, symbol_, price_, decimal_, totalSupply_, tokenAddress_);
        return _vulcan;
    }   
}
