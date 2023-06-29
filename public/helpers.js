function ping_ready() {
  readyInterval = setInterval(() => {
    send_msg(socket, 0)
  }, 1000)
}

function send_msg(socket, message){
  socket.send(JSON.stringify({
    msg: `${message}`
  }))
}

async function update_main(boardSize){
  console.log("update main works")
  response = await fetch(`http://${serverAddress}?board=${boardSize}`);
  main = document.getElementsByTagName("main")[0]; // needed?
  body = document.getElementsByTagName("body")[0];
  if (response.ok) {
    response = await response.text();
    console.log(response);
    body.innerHTML = response;
    arrange_board();
    htmlFetched = true;
  }
  else {
    main.innerHTML = "<p>cannot fetch the board :(</p>";
  }
}

function arrange_board(){
  board = document.getElementById("board"); 

  board.addEventListener("click", (event) => {
    if (event.target.className != "cell" ||
    event.target.innerHTML == undefined) return;
    send_msg(socket, event.target.id);
  })
}

function update_board(board_array){
  console.log("update board procs");
  console.log(cells)
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

function enableInput(boolean){
  console.log("ENABLE INPUT PROCS");
  if (boolean == true) {
    board.classList.remove("unclickable");
    console.log("ENABLE INPUT PROCS TRUE");
  }
  else { 
    board.classList.add("unclickable");
    console.log("ENABLE INPUT PROCS FALSE");
  }
}

function statusBar_message(message = "") {
  statusBar.innerHTML = `${message}`;
}

function offerRematch() {
  if (confirm("rematch?")) {
    statusBar_message("searching for opponent");
    ping_ready();
  }
  else socket.close();
}

function updateAvatars(symbol) {
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

function enableWaitingAnimation(boolean, boardSize = undefined) {
  if (boolean == true) {
    statusBar_message("Searching for opponent");
  }
  else if (boolean == false) {
    statusBar_message();
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