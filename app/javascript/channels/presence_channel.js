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
