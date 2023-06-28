// rematch is offered infinitely
let socket

let readyInterval;
let board;
let cells;
let avatarLeft;
let avatarRight;
let nameLeft;
let nameRight;
let symbol;
let statusBar;

let htmlFetched = false;
let avatarsSet = false;

let buttons = document.getElementsByClassName("buttonsSize");

Array.from(buttons).forEach(element => { element.addEventListener("click", () => {
  console.log("click happens")  
  websocket(element.attributes["data-size"].value);
})});