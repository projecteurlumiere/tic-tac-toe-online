async function updateMain(boardSize){
  response = await fetch(`http://${serverAddress}?board=${boardSize}`);
  if (response.ok) {
    response = await response.text();
    main.innerHTML = response;
    arrangeButtons();
    arrangeBoard();
    htmlFetched = true;
    selectBoardElements();
    arrangeEmotions();
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
      prePlaceSymbol(event.target, currentSymbol);
    }
  })
}

function arrangeEmotions() {
  emotionsContainer = document.querySelector("#emotions");
  let closeEmotions = document.querySelector("#closeEmotions");
  [avatarLeft, closeEmotions].forEach((element)=> {
    element.addEventListener("click", () => {
      console.log("click on left image procs!");
      emotionsContainer.classList.toggle("invisible")
    })
  });

  emotionsArray = document.querySelectorAll(".emotion");
  emoPicArray = document.querySelectorAll(".emoPic");

  emotionsArray.forEach((em) => {
    em.addEventListener("click", () => {
      console.log(`click happens with id ${em.dataset.id}`);
      sendMsg(socket, em.dataset.id);
      closeEmotions.click();

      let emPic;

      emoPicArray.forEach(em => { em.classList.remove("shown") })
      emoPicArray.forEach((pic) => {
        if (pic.dataset.symbol == currentSymbol && em.dataset.id ==  pic.dataset.id) {
          emPic = pic
        }
      })

      showEmote(emPic);

    })
  })
}

function showEmote(em) {
  em.classList.add("shown");
  em.onclick = () => {
    em.classList.remove("shown");
  }
  setTimeout(() => {
    em.classList.remove("shown")
  }, 5700)
}

function resetBoard(){
  updateAvatars();
  currentSymbolSet = false;
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
    cells[getCentralCell()].innerHTML = `<img src=/img/searching.svg>`

  }
  else if (boolean == false) {
    setStatusBarMessage();
    cells[getCentralCell()].innerHTML = ""
  }
}

function getCentralCell(){
  if (cells.length == 9) {
    return 2 - 1
  }
  else if (cells.length == 25) {
    return 3 - 1
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

function processGameOver(gameover = undefined, winlose = undefined) {
  if (winlose == undefined && gameover != true && gameFinished == false) {
    setStatusBarMessage("Opponent Left");
  }
  else if (winlose == undefined && gameover == true) {
    setStatusBarMessage("Game over");
    gameFinished = true;
  }
  else if (winlose == true) {
    setStatusBarMessage("You win!");
    gameFinished = true;
  }
  else if (winlose == false) {
    setStatusBarMessage("You lose!");
    gameFinished = true;
  }
}

function prePlaceSymbol(cell) {
  if (cell.innerHTML == "" && currentSymbol != undefined) {
    cell.innerHTML = `<img src=/img/${currentSymbol}.svg>`
  }
}

function checkCellsForGameOver() {
  console.log("checkcells procs")
  cells.forEach(element => {
    if (element.innerHTML == '') {
      return false
    }
  });
  return true
}