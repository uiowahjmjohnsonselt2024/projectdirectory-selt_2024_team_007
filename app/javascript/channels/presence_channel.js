// # *********************************************************************
// # This file was crafted using assistance from Generative AI Tools. 
// # Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November 
// # 4th 2024 to December 15, 2024. The AI Generated code was not 
// # sufficient or functional outright nor was it copied at face value. 
// # Using our knowledge of software engineering, ruby, rails, web 
// # development, and the constraints of our customer, SELT Team 007 
// # (Cody Alison, Yusuf Halim, Ziad Hasabrabu, Bradley Johnson, 
// # and Sheng Wang) used GAITs responsibly; verifying that each line made
// # sense in the context of the app, conformed to the overall design, 
// # and was testable. We maintained a strict peer review process before
// # any code changes were merged into the development or production 
// # branches. All code was tested with BDD and TDD tests as well as 
// # empirically tested with local run servers and Heroku deployments to
// # ensure compatibility.
// # *******************************************************************
import consumer from "./consumer"

document.addEventListener("DOMContentLoaded", () => {
  const gameElement = document.querySelector("[data-game-id]");
  const userElement = document.querySelector("[data-user-id]");
  if (!gameElement || !userElement) return;

  const gameId = gameElement.dataset.gameId;
  const userId = userElement.dataset.userId;

  consumer.subscriptions.create({ channel: "PresenceChannel", game_id: gameId, user_id: userId }, {
    connected() {
      console.log(`Connected to PresenceChannel for game ${gameId}`);
    },
    disconnected() {
      console.log(`Disconnected from PresenceChannel for game ${gameId}`);
    },
    received(data) {
      const presenceList = document.getElementById("presence-list");
      if (presenceList) {
        if (data.status === 'online') {
          let userItem = document.getElementById(`user-${data.user}`);
          if (!userItem) {
            userItem = document.createElement("li");
            userItem.id = `user-${data.user}`;
            presenceList.appendChild(userItem);
          }
          userItem.innerHTML = `
            <img src="${data.profile_image}" alt="${data.user}'s avatar" style="width: 30px; height: 30px; border-radius: 50%; margin-right: 10px;">
            ${data.user} (Health: ${data.health || 'N/A'})
          `;
        } else if (data.status === 'offline') {
          const userItem = document.getElementById(`user-${data.user}`);
          if (userItem) {
            presenceList.removeChild(userItem);
          }
        }
      }
    },
  });
});
