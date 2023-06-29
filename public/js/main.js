// rematch is offered infinitely

let buttons = document.getElementsByClassName("buttonsSize");

Array.from(buttons).forEach(element => { element.addEventListener("click", () => {
  console.log("click happens")  
  websocket(element.attributes["data-size"].value);
})});