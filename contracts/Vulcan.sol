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
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
 _     _           _                            ______               __          
| |   | |         | |                          (_____ \              | |   
| |   | |  _   _  | |  ____   __ _   _ __       _____) )  ____    ___| |  
| |   | | | | | | | | /  _ ) / _  | |  _  \    |  ____/  / _  |  /  _| |  
 \ \_/ /  | |_| | | |( (__  ( ( | | | | | |    | |      ( ( | | (  |_| |  
  \___/    \__,_) |_| \____) \_||_| |_| |_|    |_|       \_||_|  \_____) ⠀⠀
  ⠀

 *  https://vulcan.pad
 **/

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vulcan {

    /// @dev struct for token info
    struct TOKEN {
        string name;
        string symbol;
        uint256 totalSupply;
        address tokenAddress;
        uint256 decimal;
        uint256 price;
    }

    /// @dev contract owner
    address public owner;

    //@dev immutables
    IERC20 public immutable token;
    
    /// @dev ICO creator
    address public creator;

    /// @dev project metadata URI
    string public projectURI;

    /// @dev ICO hardcap
    uint256 public hardcap;

    /// @dev ICO softcap
    uint256 public softcap;

    /// @dev endTime
    uint256 public endTime;
    
    /// @dev token info
    TOKEN public tokenInfo;

    /// @dev funds raised from ICO
    uint256 public fundsRaised;

    /// @dev Tracks contributions of investors
    mapping(address => uint256) public contributions;

    /**
     * @dev constructor for new ICO launch
     * @param projectURI_ project metadata uri "https://ipfs.."
     * @param softcap_ softcap for ICO 100 * 10**18
     * @param hardcap_ hardcap for ICO  200 * 10**18
     * @param endTime_ ICO end time 1762819200000
     * @param name_ token name "vulcan token"
     * @param symbol_ token symbol "$VULCAN"
     * @param creator_ ICO creator address "0x00f.."
     * @param price_ token price for ICO 0.01 * 10**18
     * @param decimal_ token decimal 18
     * @param totalSupply_ token totalSupply 1000000000 * 10**18
     * @param tokenAddress_ token address 0x810fa...
     */
    constructor(
        string memory projectURI_,
        uint256 softcap_,
        uint256 hardcap_,
        uint256 endTime_,
        string memory name_,
        string memory symbol_,
        address creator_,
        uint256 price_,
        uint256 decimal_,
        uint256 totalSupply_,
        address tokenAddress_
    ) payable {
        require(endTime_ > block.timestamp, "End time should be in the future");
        require(hardcap_ > 0, "Invalid hardcap");
        require(softcap_ > 0, "Invalid softcap");
        require(hardcap_ > softcap_, "Invalid hardcap & softcap setting");
        require(tokenAddress_ != address(0), "invalid token address");
        require(creator_ != address(0), "invalid creator address");
        require(price_ > 0, "token price must be greater than 0");
        require(decimal_ > 0, "token decimal must be greater than 0");
        require(totalSupply_ > 0, "totalSupply must be greater than 0");

        projectURI = projectURI_;
        creator = creator_;

        tokenInfo.name = name_;
        tokenInfo.totalSupply = totalSupply_;
        tokenInfo.symbol = symbol_;
        tokenInfo.tokenAddress = tokenAddress_;
        tokenInfo.price = price_;
        tokenInfo.decimal = decimal_;

        token = IERC20(tokenAddress_);
        owner = msg.sender;
    }
    /**
     * @dev return remaining token balance for ICO
     * @return amount token balance as uint256
     */
    function getAvailableTokenAmount() public view returns (uint256) {
        uint256 amount = token.balanceOf(address(this));
        return amount;
    }
}
