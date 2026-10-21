// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CCIAIImmigrationHub
 * @dev Contract inteligent pentru finanțarea descentralizată și guvernanța Hub-ului Comunitar CCIAI
 */
contract CCIAIImmigrationHub {
    string public constant NAME = "CCIAI Social Impact Token";
    string public constant SYMBOL = "CCIAI";
    
    address public immutable founder;
    uint256 public constant TARGET_FUNDING = 69000 ether; // Echivalent în wei (ex: ETH / Stablecoin)
    uint256 public totalFundsRaised;
    
    bool public projectActive = true;

    // Structură pentru membrii DAO / Investitori
    mapping(address => uint256) public contributions;
    mapping(address => bool) public hasVoted;

    // Propuneri pentru alocarea fondurilor pe faze (ex: Chirie, Salarii, Echipamente)
    struct Proposal {
        string description;
        uint256 amountRequested;
        address payable recipient;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
    }

    Proposal[] public proposals;

    event FundsDeposited(address indexed donor, uint256 amount);
    event ProposalCreated(uint256 indexed proposalId, string description, uint256 amount);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support);
    event ProposalExecuted(uint256 indexed proposalId);

    modifier onlyFounder() {
        require(msg.sender == founder, "Doar fondatorul poate apela aceasta functie.");
        _;
    }

    constructor() {
        founder = msg.sender;
    }

    // Depunere fonduri cripto de către diaspora / investitori privați
    receive() external payable {
        require(projectActive, "Proiectul nu mai accepta fonduri.");
        require(msg.value > 0, "Suma trebuie sa fie mai mare ca zero.");

        contributions[msg.sender] += msg.value;
        totalFundsRaised += msg.value;

        emit FundsDeposited(msg.sender, msg.value);
    }

    // Crearea unei propuneri de cheltuieli (de exemplu, pentru chirie sau salarii)
    function createProposal(string memory _description, uint256 _amount, address payable _recipient) external onlyFounder {
        proposals.push(Proposal({
            description: _description,
            amountRequested: _amount,
            recipient: _recipient,
            yesVotes: 0,
            noVotes: 0,
            executed: false
        }));

        emit ProposalCreated(proposals.length - 1, _description, _amount);
    }

    // Votarea membrilor care au contribuit la proiect (DAO)
    function voteOnProposal(uint256 _proposalId, bool _support) external {
        require(contributions[msg.sender] > 0, "Doar investitorii/donatorii pot vota.");
        require(_proposalId < proposals.length, "Propunerea nu exista.");
        
        Proposal storage prop = proposals[_proposalId];
        require(!prop.executed, "Propunerea a fost deja executata.");

        uint256 votingPower = contributions[msg.sender];

        if (_support) {
            prop.yesVotes += votingPower;
        } else {
            prop.noVotes += votingPower;
        }

        emit Voted(_proposalId, msg.sender, _support);
    }

    // Executarea propunerii dacă a trecut prin consensul comunității
    function executeProposal(uint256 _proposalId) external onlyFounder {
        Proposal storage prop = proposals[_proposalId];
        require(!prop.executed, "Deja executata.");
        require(prop.yesVotes > prop.noVotes, "Propunerea nu a întrunit majoritatea.");

        prop.executed = true;
        (bool success, ) = prop.recipient.call{value: prop.amountRequested}("");
        require(success, "Transferul fondurilor a esuat.");

        emit ProposalExecuted(_proposalId);
    }
}
