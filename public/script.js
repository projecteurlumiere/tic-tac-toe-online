// let delay = ms => new Promise(res => setTimeout(res, ms));
// let response
// async function readyToPlay(){
//   await delay(3000);
//   response = await fetch('http://localhost:4567/', {
//     method: 'POST',
//     headers: 
//     {
//         "Content-Type": "application/x-www-form-urlencoded"
//     },
//     body: "ready_for_game=true",
//   })
  
//   console.log(typeof response);
//   console.log(typeof response.status)
//   console.log(response.status)
//   if (response.status != 200)  {
//     readyToPlay();
//   }
// }

// readyToPlay();

let socket = new WebSocket("ws://localhost:4567/")

socket.onopen = () => {
  console.log("connection established")
  socket.send("My name is Ashot");
};

socket.onmessage = function(event) {
  console.log(event.data)
};