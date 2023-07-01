async function updateMain(boardSize){
  response = await fetch(`http://${serverAddress}?board=${boardSize}`);
  if (response.ok) {
    response = await response.text();
    body.innerHTML = response;
    arrangeButtons();
    arrangeBoard();
    htmlFetched = true;
    selectBoardElements();
  }
  else {
    main.innerHTML = "<p>cannot fetch the board :(</p>";
  }
}

function arrangeButtons() {
  buttonReload = document.getElementById("buttonReload");
  buttonClose = document.getElementById("buttonClose");

  buttonReload.addEventListener("click", () => { 
    notifyLeaveGame();
    resetBoard();
    pingReady();
  });
  buttonClose.addEventListener("click", () => { 
    notifyLeaveGame();
    // clearBoard();
    window.location.href = `http://${serverAddress}`;
  });
}

function arrangeBoard() {
  board = document.getElementById("board"); 

  board.addEventListener("click", (event) => {
    if (event.target.className != "cell" ||
    event.target.innerHTML == undefined) { 
      return
    }
    else {
      sendMsg(socket, event.target.id);
    }
  })
}

function resetBoard(){ 
  updateAvatars();
  setStatusBarMessage();
  updateBoard();
}

function updateBoard(board_array = undefined){
  if (board_array == undefined) {
    cells.forEach(cell => {
      cell.innerHTML = "";
    });
  } 
  else {
    i = 0;
    cells.forEach(cell => {
      if (board_array[i] == 'X') {
        cell.innerHTML = "<img src=/img/x.svg>"
      }
      else if (board_array[i] == 'O') {
        cell.innerHTML = "<img src=/img/o.svg>"
      }
      i++;
    });
  }
}

function enableInput(boolean){
  if (boolean == true) {
    board.classList.remove("unclickable");
  }
  else { 
    board.classList.add("unclickable");
  }
}

function setStatusBarMessage(message = "") {
  statusBar.innerHTML = `${message}`;
}

// function offerRematch() {
//   if (confirm("rematch?")) {
//     statusBar_message("searching for opponent");
//     ping_ready();
//   }
//   else {
//     socket.close();
//   }
// }

function updateAvatars(symbol = undefined) {
  if (symbol == undefined) {
    [avatarLeft, avatarRight, nameLeft, nameRight].forEach(element => {
      element.innerHTML = '';
    });
    avatarsSet = false;
  }
  else {
    if (symbol == 'X') {
      avatarLeft.innerHTML = '<img id="avatarLeftImg" src="img/x_eyes.svg" style="-webkit-transform: scaleX(-1) var(--scale); transform: scaleX(-1) var(--scale);">';
      avatarRight.innerHTML = '<img id="avatarRightImg" src="img/o_eyes.svg" style="-webkit-transform: scaleX(-1) var(--scale); transform: scaleX(-1) var(--scale);">'
    }
    else if (symbol == 'O') {
      avatarLeft.innerHTML = '<img id="avatarLeftImg" src="img/o_eyes.svg" style="transform: var(--scale);">';
      avatarRight.innerHTML = '<img id="avatarRightImg" src="img/x_eyes.svg" style="transform: var(--scale);">'
    }
    
    nameLeft.innerHTML = 'You';
    nameRight.innerHTML = 'Opponent';
    avatarsSet = true;
  }
}

function enableWaitingAnimation(boolean, boardSize = undefined) {
  if (boolean == true) {
    setStatusBarMessage("Searching for opponent");
  }
  else if (boolean == false) {
    setStatusBarMessage();
  }
}

function highlightWhoseTurn(turn) {
  console.log("WHOSE TURN PROCS")
  if (turn == true) {
    avatarRightImg.classList.remove("playing");
    avatarLeftImg.classList.add("playing");
  }
  else if (turn == false) {
    avatarRightImg.classList.add("playing");
    avatarLeftImg.classList.remove("playing");
  }
}

function processGameOver(winlose = undefined) {
  if (winlose == undefined) {
    setStatusBarMessage("Opponent Left");
  }
  else if (winlose == true) {
    setStatusBarMessage("You win!");
  }
  else if (winlose == false) {
    setStatusBarMessage("You lose!");
  }
}