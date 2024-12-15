import consumer from "./consumer"

document.addEventListener("DOMContentLoaded", () => {
    const gameElement = document.querySelector("[data-game-id]");
    if (!gameElement) return;

    const gameId = gameElement.dataset.gameId;

    consumer.subscriptions.create({ channel: "QuestsChannel", game_id: gameId }, {
        received(data) {
            const questOverlay = document.querySelector(".quest-overlay");
            if (questOverlay && data.quests) {
                questOverlay.innerHTML = "<h3>Quests</h3>";

                data.quests.forEach((quest) => {
                    const { quest_type, condition, progress, reward } = quest;
                    let questDescription;
                    switch(quest_type){
                        case 1: questDescription = `Type ${condition} times in the chat box`; break
                        case 2: questDescription = `Use the item ${condition} times`; break
                        case 3: questDescription = `Successfully defeat ${condition} players`; break
                        default: questDescription = "Unknown quest"
                    }

                    const progressPercentage = (progress / condition) * 100;
                    const questItem = document.createElement("div");
                    questItem.innerHTML = `
            <p>${questDescription} (Reward: ${reward} shards)</p>
            <div class="progress-bar-container" style="background:#555; width:100%; height:20px; border-radius:5px; margin-bottom:10px;">
              <div class="progress-bar" style="width:${progressPercentage}%; background:#3c3; height:100%; border-radius:5px;"></div>
            </div>
          `;
                    questOverlay.appendChild(questItem);
                });

                const closeBtn = document.createElement("button");
                closeBtn.id = "close-quest-overlay";
                closeBtn.classList.add("btn","btn-secondary","mt-3");
                closeBtn.textContent = "Close";
                closeBtn.addEventListener("click", () => {
                    questOverlay.style.display = "none";
                });
                questOverlay.appendChild(closeBtn);
            }
        }
    });
});
