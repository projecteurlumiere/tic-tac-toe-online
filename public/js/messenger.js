async function websocket(boardSize) {
  socket = new WebSocket(`ws://${serverAddress}`);

  socket.onopen = async () => {
    if (htmlFetched == false) { 
      selectMainBody();
      await updateMain(boardSize);
      selectBoardElements();
    }
    pingReady();
  };


  socket.onmessage = async function(event) {
    let responseObject = JSON.parse(event.data);

    if (responseObject.found_game == false) {
      enableWaitingAnimation(true, boardSize);
    }
    else if (responseObject.found_game == true) {
      enableWaitingAnimation(false);
    }
    else if (htmlFetched == true && responseObject.board) {
      
      if (avatarsSet == false) { 
        updateAvatars(responseObject.symbol);
        selectAvatars();
      }

      updateBoard(responseObject.board);
      
      if (responseObject.win != undefined) {
        // enableInput(false);
        // offerRematch();
      }
      else if (responseObject.turn == responseObject.symbol) {
        highlightWhoseTurn(true);
        enableInput(true);

      }
      else if (responseObject.turn != responseObject.symbol) {
        highlightWhoseTurn(false);
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