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
  if (boolean) board.classList.remove("unclickable")
  else board.classList.add("unclickable")
}

function statusBar_message(message) {
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
    avatarLeft.innerHTML = '<img src="img/x_eyes.svg" style="-webkit-transform: scaleX(-1); transform: scaleX(-1);">';
    avatarRight.innerHTML = '<img src="img/o_eyes.svg" style="-webkit-transform: scaleX(-1); transform: scaleX(-1);">'
  }
  else if (symbol == 'O') {
    avatarLeft.innerHTML = '<img src="img/o_eyes.svg">';
    avatarRight.innerHTML = '<img src="img/x_eyes.svg">'
  }
  nameLeft.innerHTML = 'You';
  nameRight.innerHTML = 'Opponent';
  avatarsSet = true;
}

enableWaitingAnimation(boardSize); {

}