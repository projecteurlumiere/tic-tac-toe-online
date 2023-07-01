function pingReady() {
  sendMsg(socket, 0);
}

function sendMsg(socket, message){
  socket.send(JSON.stringify({
    msg: `${message}`
  }))
}

function notifyLeaveGame(){
  sendMsg(socket, -1);
}