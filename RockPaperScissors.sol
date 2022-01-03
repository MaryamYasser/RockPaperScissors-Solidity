pragma solidity >=0.7.0 <0.9.0;

contract RockPaperScissors{
    bytes32 constant ROCK = keccak256(abi.encodePacked("ROCK"));
    bytes32 constant PAPER = keccak256(abi.encodePacked("PAPER"));
    bytes32 constant SCISSORS = keccak256(abi.encodePacked("SCISSORS"));

    
    uint public gameEndTime;
    uint public reward;
    uint public reward1;
    uint public reward2;

    address payable public winner;


    address payable private player1;
    address payable private player2;
    address payable private contractCreator;

    bytes32 private choiceOfPlayer1;
    bytes32 private choiceOfPlayer2;


    bool private Player1Played = false;
    bool private Player2Played = false;
    bool private draw = false;

    bool ended = false;

    event gameEnded(address winner,uint reward); //who is the winner and what is the amount
    event gameEndedinDraw(address player1,address player2,uint reward1,uint reward2);


constructor(uint _gameTime,address payable _player1,address payable _player2, address payable _contractCreator){
player1 = _player1;
player2 = _player2;
contractCreator = _contractCreator;
gameEndTime = block.timestamp + _gameTime;


}

function addReward() public payable{
    require(msg.sender == contractCreator ,
                "You are not authorized to add reward."
        );

    reward = msg.value;
    

}
function evaluate(bytes32 choice1, bytes32 choice2) public
    {
        // if the choices are the same, the game is a draw, therefore returning 0x0000000000000000000000000000000000000000 as the winner
       

        // paper beats rock bob/alice
        if (choice1 == ROCK && choice2 == PAPER) {
            winner = player2;
            // paper still beats rock (played in opposite alice/bob)
        } else if (choice1 == ROCK && choice2 == SCISSORS) {
            winner = player1;

            } else if (choice1 == ROCK && choice2 == ROCK) {
            //winner = player1;
            draw = true;
            
        } else if (choice1 == SCISSORS && choice2 == PAPER) {
            winner = player1;
            //revert("Winner is player 1");
            
        } else if (choice1 == SCISSORS && choice2 == SCISSORS) {
            draw = true;
            //revert("Winner is player 2");

            }else if (choice1 == SCISSORS && choice2 == ROCK) {
            winner = player2;
            
        } else if (choice1 == PAPER && choice2 == SCISSORS) {
            winner = player2;
            //revert("Winner is player 1");
            
        } else if (choice1 == PAPER && choice2 == ROCK) {
            winner = player1;

            }else if (choice1 == PAPER && choice2 == PAPER) {
            draw = true;
            //revert("Winner is player 2");
            
        }
        
    }


function play(string calldata choice) public payable {
    // check that the move is valid
        require(keccak256(abi.encodePacked(choice)) == ROCK ||
         keccak256(abi.encodePacked(choice)) == PAPER || 
         keccak256(abi.encodePacked(choice)) == SCISSORS,
        "Only ROCK, PAPER, or SCISSORS allowed");

        require(msg.sender == player1 || msg.sender == player2,
                "You are not a player in this game."
        );

        if(block.timestamp > gameEndTime){
            revert("Game has ended");
        }

        if(msg.sender == player1){
         choiceOfPlayer1 = keccak256(abi.encodePacked(choice));
         Player1Played = true;
         if(Player2Played){
             evaluate(choiceOfPlayer1,choiceOfPlayer2);
         } }

         if(msg.sender == player2){
         choiceOfPlayer2 = keccak256(abi.encodePacked(choice));
         Player2Played = true;
         if(Player1Played){
             evaluate(choiceOfPlayer1,choiceOfPlayer2);
         }



        }
        
        
        
        
        
        
        
        
        }






    function gameEnd() public{
        if(block.timestamp < gameEndTime){
            revert("Game has not ended");
        }

        if(ended){
            revert("Function Auction Ended has already been called");
        }
        if(draw && Player1Played && Player2Played){
            reward1 = reward / 2;
            reward2 = reward / 2;
            emit gameEndedinDraw(player1,player2,reward1,reward2);
            player1.transfer(reward1);
            player2.transfer(reward2);
            
        }
        else if(!draw && Player1Played && Player2Played){ 
        emit gameEnded(winner,reward);
         winner.transfer(reward);
         
        }
        else if(Player2Played || Player1Played){
            if(Player1Played){
                emit gameEnded(player1,reward);
                player1.transfer(reward);
            }
            else if(Player2Played){
                emit gameEnded(player2,reward);
                player2.transfer(reward);
            }

        }
        

        ended = true;
        draw = false;
        Player1Played = false;
        Player2Played = false;

    }



}