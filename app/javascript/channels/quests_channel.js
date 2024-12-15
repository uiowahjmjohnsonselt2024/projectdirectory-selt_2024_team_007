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
                        case 2: questDescription = `A party member takes damage ${condition} times`; break
                        case 3: questDescription = `Pick up item(s) from a chat ${condition} times`; break
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
