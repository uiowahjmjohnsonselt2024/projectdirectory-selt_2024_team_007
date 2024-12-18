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
// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import consumer from "./channels/consumer";

import "channels"
import { application } from "controllers/application"



//Open connection to ActionCable
export function openConnection() {
    return new WebSocket('ws://localhost:3000/cable');
}

//ChatChannel subscription
document.addEventListener("DOMContentLoaded", () => {

    const gameElement = document.querySelector("[data-game-id]");
    if (!gameElement) return;
    const gameId = gameElement.dataset.gameId;

    // Define userId here so it’s available to all code inside this DOMContentLoaded block
    const userElement = document.querySelector("[data-user-id]");
    const userId = userElement ? userElement.dataset.userId : null;
    console.log("Retrieved userId from DOM:", userId);

    // Select inventory modal elements if needed
    const inventoryModal = document.getElementById("inventoryModal");
    const inventoryModalBody = inventoryModal ? inventoryModal.querySelector('.modal-body') : null;


    const connection = openConnection();
      connection.onopen = () => {
          const identifier = JSON.stringify({ channel: "ChatChannel", game_id: gameId });
          const subscribeMessage = { command: "subscribe", identifier: identifier };
          // const subscribeMessage = {"command": "subscribe", "identifier": "{\"channel\":\"ChatChannel\"}"};
          connection.send(JSON.stringify(subscribeMessage));
      };

    const responseField = document.getElementById("chatbot-response");
    const imageContainer = document.getElementById("gpt-image-box");
    const messageInput = document.getElementById("user-message");
    const sendButton = document.getElementById("send-message");

    // Add turn indicator
    const turnIndicator = document.createElement('div');
    turnIndicator.id = 'turn-indicator';
    turnIndicator.className = 'text-center mb-3';
    responseField.parentElement.insertBefore(turnIndicator, responseField);

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

        // Handle turn updates
        if (data.current_turn) {
          const isMyTurn = data.current_turn === currentUserName;
          turnIndicator.textContent = isMyTurn ? 
              "It's your turn!" : 
              `Waiting for ${data.current_turn}'s turn...`;
          turnIndicator.className = isMyTurn ? 'text-success' : 'text-muted';
          
          // Enable/disable input
          if (messageInput && sendButton) {
              messageInput.disabled = !isMyTurn;
              sendButton.disabled = !isMyTurn;
          }
      }

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

        // Update players list
        if (data.updated_players) {
            data.updated_players.forEach((player) => {
                // Find the corresponding li by player.id
                const li = document.querySelector(`#player-health-list [data-player-id="${player.id}"]`);
                if (li) {
                    // Update the health text
                    const healthText = li.querySelector('span:first-child');
                    if (healthText) {
                        healthText.textContent = `${player.name} (${player.health}/100)`;
                    }

                    // Update the health bar width
                    const healthBar = li.querySelector('span > span'); // The inner red bar
                    if (healthBar) {
                        const healthPercentage = (player.health / 100) * 100;
                        healthBar.style.width = `${healthPercentage}%`;
                    }
                }
            });

            // Update the current user's inventory modal
            if (userId && inventoryModalBody) {
                const currentUser = data.updated_players.find(p => String(p.id) === String(userId));

                if (currentUser) {
                    // Update consumable quantities
                    const consumables = [
                        { id: "teleport-quantity", value: currentUser.teleport_token },
                        { id: "health-potion-quantity", value: currentUser.health_potion },
                        { id: "resurrection-token-quantity", value: currentUser.resurrection_token },
                    ];

                    consumables.forEach(consumable => {
                        const quantitySpan = document.getElementById(consumable.id);
                        if (quantitySpan) {
                            quantitySpan.textContent = consumable.value || 0; // Default to 0 if value is undefined
                        } else {
                            console.warn(`Element with ID ${consumable.id} not found.`);
                        }
                    });

                    // Handle in-game items if needed
                    const inGameItemsContainer = document.querySelector("#in-game-items");
                    if (inGameItemsContainer) {
                        inGameItemsContainer.innerHTML = ""; // Clear existing in-game items

                        if (currentUser.equipment && currentUser.equipment.length > 0) {
                            const ul = document.createElement('ul');
                            currentUser.equipment.forEach(item => {
                                const li = document.createElement('li');
                                li.textContent = item.name; // Add item name
                                ul.appendChild(li);
                            });
                            inGameItemsContainer.appendChild(ul);
                        } else {
                            const p = document.createElement('p');
                            p.textContent = "No items in your inventory.";
                            inGameItemsContainer.appendChild(p);
                        }
                    }
                } else {
                    console.warn("Current user not found in updated_players. Data received:", data.updated_players);
                }
            }
        }
        updateMapModal();
      },
    });
  });
  
//PresenceChannel subscription
let gameId;
let userId;
let currentUserName;
let currentUserTeleports;

let isProcessingMove = false;

document.addEventListener("DOMContentLoaded", () => {
  const gameElement = document.querySelector("[data-game-id]");
  if (!gameElement) return;
  gameId = gameElement.dataset.gameId;
  userId = document.querySelector("[data-user-id]").dataset.userId;
  const userElement = document.querySelector("[data-user-id]");
  currentUserName = document.querySelector("[data-user-name]").dataset.userName;

  const userTeleportsElement = document.querySelector("[data-user-teleports]");
  if (userTeleportsElement) {
    currentUserTeleports = parseInt(userTeleportsElement.dataset.userTeleports, 10);
  } else {
    currentUserTeleports = 0;
  }

  const currentTurnElement = document.querySelector("[data-current-turn-user-id]");
  const messageInput = document.getElementById("user-message");
  const sendButton = document.getElementById("send-message");
  const responseField = document.getElementById("chatbot-response");
  const mapButton = document.getElementById("map_button");


  // Add turn indicator
  const turnIndicator = document.createElement('div');
  turnIndicator.id = 'turn-indicator';
  turnIndicator.className = 'text-center mb-3';
  
  if (responseField) {
    responseField.parentElement.insertBefore(turnIndicator, responseField);
  }

  // Safely check current turn
  const isCurrentUserTurn = currentTurnElement ? 
    currentTurnElement.dataset.currentTurnUserId == userId : 
    false;

  // Initialize the turn indicator
  if (currentTurnElement && currentTurnElement.dataset.currentTurnUserName) {
    turnIndicator.textContent = `Current Turn: ${currentTurnElement.dataset.currentTurnUserName}`;
  }

  // Safely enable/disable controls
  if (messageInput) messageInput.disabled = !isCurrentUserTurn;
  if (sendButton) sendButton.disabled = !isCurrentUserTurn;
  if (mapButton) mapButton.disabled = !isCurrentUserTurn;


  // Updated PresenceChannel subscription
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

        if (data.action === 'update_turn') {
          if (turnIndicator) {
            turnIndicator.textContent = `Current Turn: ${data.current_turn_user_name}`;
          }

          const isCurrentUserTurn = data.current_turn_user_id == userId;
          messageInput.disabled = !isCurrentUserTurn;
          sendButton.disabled = !isCurrentUserTurn;
          mapButton.disabled = !isCurrentUserTurn;
        }
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
              ${data.user}`;
          } else if (data.status === 'offline') {
            const userItem = document.getElementById(`user-${data.user}`);
            if (userItem) {
              presenceList.removeChild(userItem);
            }
          } else if (data.status === 'moved') {
            // Update the player's position on the map
            updatePlayerPosition(data.user, data.x, data.y);

            // If it's another player's move, update the map modal
            if (data.user !== currentUserName) {
              updateMapModal();
            }
          }
        }
      },
    }
  );
});

function generateMoveMessage(newX, newY, isAdjacent) {
  const mapModal = bootstrap.Modal.getInstance(document.getElementById('mapModal'));
  mapModal.hide();
  
  // Get current player position
  const currentPlayer = document.querySelector(`.players [data-player="${currentUserName}"]`);
  const currentTile = currentPlayer ? currentPlayer.closest('.tile') : null;
  
  return `I am ${currentUserName}. I move to (${newX},${newY}).` 
}

// Modify the click listener
document.addEventListener('click', async (e) => {
  const tile = e.target.closest('.tile');
  // const gridMap = document.querySelector('.grid-map');
  
  if (tile && tile.closest('.grid-map') && !isProcessingMove) {
    const newX = parseInt(tile.dataset.x);
    const newY = parseInt(tile.dataset.y);
    
    const currentPlayer = document.querySelector(`.players [data-player="${currentUserName}"]`);
    const currentTile = currentPlayer ? currentPlayer.closest('.tile') : null;
    
    const isAdjacent = currentTile ? (
      Math.abs(parseInt(currentTile.dataset.x) - newX) <= 1 &&
      Math.abs(parseInt(currentTile.dataset.y) - newY) <= 1
    ) : true;
    
    if (!isAdjacent) {
      if (currentUserTeleports <= 0) {
        showNoTeleportsMessage();
        return;
      }
    }

    isProcessingMove = true;
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    try {
      // First send the move command
      const moveResponse = await fetch(`/games/${gameId}/move`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({ x: newX, y: newY })
      });

      if (moveResponse.ok) {
        // If move successful, send the chat message
        const moveMessage = generateMoveMessage(newX, newY, isAdjacent);
        const chatResponse = await fetch(`/games/${gameId}/chat`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken
          },
          body: JSON.stringify({ message: moveMessage })
        });

        if (chatResponse.ok) {
          updatePlayerPosition(currentUserName, newX, newY);
        }
      } else {
        throw new Error('Move failed');
      }
    } catch (error) {
      console.error('Error:', error);
      alert('Failed to move. Please try again.');
    } finally {
      isProcessingMove = false;
    }
  }
});

// Update helper function to show error more prominently
function showNoTeleportsMessage() {
  const modalFlashMessages = document.querySelector('#mapModal #map-flash-messages');
  if (modalFlashMessages) {
    modalFlashMessages.innerHTML = '<div class="alert alert-danger" style="position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 9999; padding: 15px;">Cannot move to non-adjacent tiles! No more teleports left!</div>';
    setTimeout(() => {
      modalFlashMessages.innerHTML = '';
    }, 2000);
  }
}


function updatePlayerPosition(username, x, y) {
  if (!username) {
    // console.error('Username is missing:', username);
    return false;
  }

  // Remove the player from their current position
  const currentPlayer = document.querySelector(`.players [data-player="${username}"]`);
  const currentTile = currentPlayer ? currentPlayer.closest('.tile') : null;
  
  // Calculate if move is adjacent
  const isAdjacent = currentTile ? (
    Math.abs(parseInt(currentTile.dataset.x) - x) <= 1 &&
    Math.abs(parseInt(currentTile.dataset.y) - y) <= 1
  ) : true;

  // Handle non-adjacent moves
  if (!isAdjacent) {
    if (currentUserTeleports <= 0) {
      showNoTeleportsMessage();
      return false;
    }
    // Decrement teleports only for the current user
    if (username === currentUserName) {
      currentUserTeleports--;
    }
  }

  // Remove from current position
  if (currentPlayer) {
    currentPlayer.remove();
  }

  // Add to new position
  const newTile = document.querySelector(`.tile[data-x="${x}"][data-y="${y}"]`);
  if (newTile) {
    let playersContainer = newTile.querySelector('.players');
    if (!playersContainer) {
      playersContainer = document.createElement('div');
      playersContainer.className = 'players';
      newTile.appendChild(playersContainer);
    }

    const playerSpan = document.createElement('span');
    playerSpan.className = 'player-name';
    playerSpan.dataset.player = username;
    playerSpan.textContent = `(${username})`;
    playersContainer.appendChild(playerSpan);

    // Close map modal after successful move
    const mapModal = bootstrap.Modal.getInstance(document.getElementById('mapModal'));
    if (mapModal) {
      mapModal.hide();
    }
  }

  return true;
}

function updateMapModal() {
  const mapModal = document.getElementById('mapModal');
  if (mapModal && gameId) {
    const modalBody = mapModal.querySelector('.modal-body');
    fetch(`/games/${gameId}/map`)
      .then(response => response.text())
      .then(html => {
        modalBody.innerHTML = html;
      })
      .catch(error => console.error('Error updating map:', error));
  }
}

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



