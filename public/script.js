let readyInterval;
let board;
let cells;
let symbol;
let statusBar;

let htmlFetched = false;

let socket = new WebSocket("ws://localhost:4567/");

socket.onopen = () => {
  console.log("connection established");
  ping_ready();
};


socket.onmessage = async function(event) {
  let responseObject = JSON.parse(event.data);
  console.log(responseObject);
  console.log(`${responseObject.found_game}`)

  if (responseObject.found_game == false) return
  else if (responseObject.found_game == true) {
    console.log("condition procs")
    clearInterval(readyInterval);
    if (htmlFetched == false) { update_main() }
    symbol = responseObject.symbol;
  }
  else if (htmlFetched == true && responseObject.board) {
    update_board(responseObject.board);

    if (responseObject.win != undefined) {
      enableInput(false);
      if (responseObject.win) statusBar_message("you win")
      else statusBar_message("you lose");
      offerRematch();
    }
    else if (responseObject.turn == true) {
      enableInput(true);
      statusBar_message("your turn");
    }
    else if (responseObject.turn == false) {
      statusBar_message("opponent's turn");
      enableInput(false);
    }
  }
};

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

async function update_main(){
  console.log("update main works")
  response = await fetch("http://localhost:4567/?board=3");
  main = document.getElementsByTagName("main")[0]; // needed?
  body = document.getElementsByTagName("body")[0];
  if (response.ok) {
    response = await response.text();
    console.log(response);
    body.innerHTML = response;
    arrange_board();
    htmlFetched == true;
  }
  else {
    main.innerHTML = "<p>cannot fetch the board :(</p>";
  }
}

function arrange_board(){
  board = document.getElementsByClassName("board")[0]; 
  statusBar = document.getElementsByClassName("statusBar")[0];
  cells = document.querySelectorAll("cell");

  board.addEventListener("click", (event) => {
    if (event.target.className != "cell" ||
    event.target.innerHTML == undefined) return;
    send_msg(socket, event.target.id);
  })
}

function update_board(board_array){
  i = 0;
  cells.forEach(cell => {
    cell.innerHTML = board_array[i];
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

// To server:
// msg: 0 or 1-9; integer 0 if ready, 1-9 if make a choice

// From server:
// found_game: boolean; false or true when found game; otherwise UNDEFINED (null)
// board: Array; 
// turn: boolean; (true if turn is yours)
// symbol: X or O; string (this is your symbol)
// error: boolean;
// win: boolean; (if none then undef)
