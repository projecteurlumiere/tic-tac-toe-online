function selectMainBody() {
  main = document.getElementsByTagName("main")[0];
  body = document.getElementsByTagName("body")[0];
}

function selectBoardElements() {
  statusBar = document.getElementById("statusBar");
  console.log(statusBar);

  cells = document.querySelectorAll(".cell");
  console.log(cells);
  avatarLeft = document.getElementById("avatarLeft");
  avatarRight = document.getElementById("avatarRight");
  nameLeft = document.getElementById("nameLeft");
  nameRight = document.getElementById("nameRight");
}

function selectAvatars() {
  avatarLeftImg = document.getElementById("avatarLeftImg");
  avatarRightImg = document.getElementById("avatarRightImg");
}