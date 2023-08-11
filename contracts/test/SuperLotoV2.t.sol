// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/SuperLotoV2.sol";

contract SuperLotoTest is Test {
  SuperLoto public superLoto;
  address public owner;
  address public user1;

  function setUp() public {
    superLoto = new SuperLoto();
    owner = msg.sender;
    user1 = address(this);
  }

  function testStartNewGame() public {
    uint256 ticketCost = 100;
    uint128 expensesPercentage = 5;
    uint128 gameDurationInDays = 7;
    uint128 maxPlayers = 100;
    uint128 minPlayers = 5;
    //Execute startNewGame function on the contract
    superLoto.startNewGame(
      ticketCost,
      expensesPercentage,
      gameDurationInDays,
      maxPlayers,
      minPlayers
    );
    // Obtener la información del juego recién creado desde el mapeo "lotteries"
    SuperLoto.Lottery memory newGame = superLoto.lotteries(
      superLoto.gameIndex()
    );
    // Aserciones para verificar los detalles del juego
    assertEq(newGame.ticketCost, ticketCost, "Ticket cost should match");
    assertEq(
      newGame.expensesPercentage,
      expensesPercentage,
      "Expenses percentage should match"
    );
    assertEq(newGame.maxPlayers, maxPlayers, "Max players should match");
    assertEq(newGame.minPlayers, minPlayers, "Min players should match");

    uint256 expectedDueDate = block.timestamp +
      uint256(gameDurationInDays) *
      86400;
    assertWithinRange(
      newGame.dueDate,
      expectedDueDate,
      60,
      "Due date should be approximately correct"
    );
  }

  function testBuyTicket() public {
    uint256 ticketCost = 100;
    address beneficiary = address(0); // Replace with actual beneficiary address

    superLoto.startNewGame(ticketCost, 5, 7, 100, 5);

    superLoto.value(ticketCost).buyTicket(beneficiary);

    // Perform assertions to verify ticket purchase
    // You can check playerTickets and beneficiary mappings
  }

  function testBuyTicketMultipleWithDifferentBeneficiaries() public {
    uint256 ticketCost = 100;
    address beneficiary1 = address(0x123); // Replace with actual beneficiary addresses
    address beneficiary2 = address(0x456);
    address beneficiary3 = address(0x789);

    // Crear un nuevo juego
    superLoto.startNewGame(ticketCost, 5, 7, 100, 5);

    // Comprar tres boletos con diferentes beneficiarios
    superLoto.value(ticketCost * 3).buyTicket(beneficiary1);
    superLoto.value(ticketCost * 2).buyTicket(beneficiary2);
    superLoto.value(ticketCost).buyTicket(beneficiary3);

    // Obtener la información del juego recién creado desde el mapeo "lotteries"
    SuperLoto.Lottery memory currentGame = superLoto.lotteries(
      superLoto.gameIndex()
    );

    // Verificar que el contrato balanceBag se haya actualizado correctamente
    assertEq(
      currentGame.balanceBag,
      ticketCost * 6,
      "Balance bag should match total ticket cost"
    );

    // Verificar que los jugadores se hayan registrado en los playerTickets
    assertEq(
      currentGame.playerTickets.length,
      6,
      "Player ticket count should be 6"
    );
    // Verificar que los jugadores tengan los beneficiarios correctos
    assertEq(
      superLoto.beneficiary(superLoto.gameIndex(), address(this)),
      beneficiary1,
      "Beneficiary should match for player 1"
    );
    assertEq(
      superLoto.beneficiary(superLoto.gameIndex(), address(this, 1)),
      beneficiary2,
      "Beneficiary should match for player 2"
    );
    assertEq(
      superLoto.beneficiary(superLoto.gameIndex(), address(this, 2)),
      beneficiary3,
      "Beneficiary should match for player 3"
    );

    // Verificar que el contrato balance haya aumentado en el valor total de los boletos
    assertEq(
      address(superLoto).balance,
      ticketCost * 6,
      "Contract balance should match total ticket cost"
    );
  }

  function testFinishGame() public {
    uint256 ticketCost = 100;
    address beneficiary = address(0); // Replace with actual beneficiary address

    superLoto.startNewGame(ticketCost, 5, 7, 100, 5);

    superLoto.value(ticketCost).buyTicket(beneficiary);

    // Fast-forward time to after the dueDate
    // Perform the finishGame function call
    // Perform assertions to verify winner selection and prize distribution
  }

  // Add more test cases as needed

  // Helper function to fast-forward time
  function fastForwardTime(uint256 secondsToForward) internal {
    // Implement time manipulation as required by your test environment
  }
}
