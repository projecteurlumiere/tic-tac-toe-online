async function websocket(boardSize){
  console.log("websocket happens")
  socket = new WebSocket(`ws://${serverAddress}`);

  socket.onopen = () => {
    console.log("connection established");
    if (htmlFetched == false) { update_main(boardSize) }
    ping_ready();
  };


  socket.onmessage = async function(event) {
    let responseObject = JSON.parse(event.data);
    console.log(responseObject);
    console.log(`${responseObject.found_game}`);
    console.log(`html fetched is ${htmlFetched}`)

    if (responseObject.found_game == false) {
      enableWaitingAnimation(boardSize);
    }
    else if (responseObject.found_game == true) {
      console.log("condition procs")
      clearInterval(readyInterval);
      symbol = responseObject.symbol; // do i need this?
    }
    else if (htmlFetched == true && responseObject.board) {
      console.log("procs");
      statusBar = document.getElementsByClassName("statusBar")[0];
      cells = document.querySelectorAll(".cell");
      avatarLeft = document.getElementById("avatarLeft");
      avatarRight = document.getElementById("avatarRight");
      nameLeft = document.getElementById("nameLeft");
      nameRight = document.getElementById("nameRight");
      
      if (avatarsSet == false) { updateAvatars(responseObject.symbol) }

      console.log(cells);
      console.log(statusBar);
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
}

// To server:
// msg: 0 or 1-25; integer 0 if ready, 1-25 if make a choice

// emoji: emoji string to show

// From server:
// found_game: boolean; false or true when found game; otherwise UNDEFINED (null)
// board: Array; 
// turn: boolean; (true if turn is yours)
// symbol: X or O; string (this is your symbol)
// error: boolean;
// win: boolean; (if none then undef)
// leaver: true (otherwise undefined)