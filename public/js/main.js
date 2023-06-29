// rematch is offered infinitely

let buttonsSize = document.getElementsByClassName("buttonsSize");

Array.from(buttonsSize).forEach(button => { button.addEventListener("click", () => {
  websocket(button.attributes["data-size"].value);
})});