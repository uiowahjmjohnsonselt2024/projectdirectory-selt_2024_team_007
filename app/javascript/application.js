// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// import "@hotwired/turbo-rails"
import consumer from "./channels/consumer";
// import "./chat";
//import "app/javascript/controllers"
// import "bootstrap";
// import "popper.js";
import "channels"
import { application } from "controllers/application"

export function openConnection() {
    return new WebSocket('ws://localhost:3000/cable');
}

document.addEventListener("DOMContentLoaded", () => {

    const gameElement = document.querySelector("[data-game-id]");
    if (!gameElement) return;
    const gameId = gameElement.dataset.gameId;  
  
    const connection = openConnection();
      connection.onopen = () => {
          const identifier = JSON.stringify({ channel: "ChatChannel", game_id: gameId });
          const subscribeMessage = { command: "subscribe", identifier: identifier };
          // const subscribeMessage = {"command": "subscribe", "identifier": "{\"channel\":\"ChatChannel\"}"};
          connection.send(JSON.stringify(subscribeMessage));
      };
    
    const responseField = document.getElementById("chatbot-response");
    const imageContainer = document.getElementById("gpt-image-box");

    if (!responseField || !gameElement || !imageContainer) return;

    // const gameId = gameElement.dataset.gameId;
    console.log(`Connecting to ChatChannel for game ${gameId}`);
  
    consumer.subscriptions.create({ channel: "ChatChannel", game_id: gameId }, {
      connected() {
        console.log(`Connected to ChatChannel for game ${gameId}`);
      },
      disconnected() {
        console.log(`Disconnected from ChatChannel for game ${gameId}`);
      },
      received(data) {
        const newMessage = `
          <p><strong>${data.user}:</strong> ${data.message}</p>
          <p><em>GPT:</em> ${data.gpt_response}</p>
        `;
        responseField.innerHTML += newMessage;
        responseField.scrollTop = responseField.scrollHeight; // Auto-scroll to the bottom

        // Update GPT image box
        if (imageContainer) {
            imageContainer.innerHTML = ""; // Clear existing content

            if (data.gpt_img_resp) {
                const img = document.createElement("img");
                img.src = data.gpt_img_resp;
                img.alt = data.image_prompt || "Generated image";
                img.style.maxWidth = "100%";
                img.style.maxHeight = "100%";
                imageContainer.appendChild(img);
                console.log("Image updated in gpt-image-box.");
            } else {
                const noImageMessage = document.createElement("p");
                noImageMessage.textContent = "No image available.";
                noImageMessage.className = "text-muted";
                imageContainer.appendChild(noImageMessage);
            }
        }
      },
    });
  });
  

// document.addEventListener('DOMContentLoaded', () => {
//     // const connection = openConnection();
//     // connection.onopen = () => {
//     //     const subscribeMessage = {"command": "subscribe", "identifier": "{\"channel\":\"ChatChannel\"}"};
//     //     connection.send(JSON.stringify(subscribeMessage));
//     // };
// });

document.addEventListener("DOMContentLoaded", () => {
  const gameElement = document.querySelector("[data-game-id]");
  if (!gameElement) return;
  const gameId = gameElement.dataset.gameId;
  const userId = document.querySelector("[data-user-id]").dataset.userId;

  // Subscribe to PresenceChannel
  consumer.subscriptions.create(
    { channel: "PresenceChannel", game_id: gameId, user_id: userId },
    {
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
    }
  );
});


document.addEventListener('DOMContentLoaded', function () {
    const audio = document.getElementById('background-music');

    if (!audio) {
        return;
    }

    function playAudio() {
        audio.muted = false;
        audio.play().catch((err) => {
            console.error('Audio playback error:', err);
        });
        document.removeEventListener('click', playAudio);
    }

    document.addEventListener('click', playAudio);
});
