async function websocket(boardSize) {
  socket = new WebSocket(`ws://${serverAddress}/game`);

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
    console.log(responseObject);
    console.log(responseObject.leaver)

    if (responseObject.found_game == false) {
      enableWaitingAnimation(true, boardSize);
      enableInput(false)
    }
    else if (responseObject.found_game == true) {
      enableWaitingAnimation(false);
      enableInput(true)
    }
    else if (responseObject.leaver == true) {
      console.log("leaver procs");
      enableInput(false);
      processGameOver();
    }
    else if (htmlFetched == true && responseObject.board) {
      gameFinished = false

      if (currentSymbolSet == false) {
        currentSymbol = responseObject.symbol.toLowerCase();
        currentSymbolSet = true;
      }

      if (avatarsSet == false) {
        updateAvatars(responseObject.symbol);
        selectAvatars();
      }

      updateBoard(responseObject.board);

      if (responseObject.gameover == true) {
        processGameOver(responseObject.gameover, responseObject.win);
        enableInput(false);
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