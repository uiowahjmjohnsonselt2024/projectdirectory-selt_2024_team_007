document.addEventListener("DOMContentLoaded", () => {
    const sendButton = document.getElementById("send-message");
    const messageField = document.getElementById("user-message");
    const gameElement = document.querySelector("[data-game-id]");
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    if (!gameElement || !sendButton || !messageField) return;

    const gameId = gameElement.dataset.gameId;

    sendButton.addEventListener("click", async () => {
        const message = messageField.value.trim();

        if (!message) {
            alert("Please enter a message.");
            return;
        }

        try {
            const response = await fetch(`/games/${gameId}/chat`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    "X-CSRF-Token": csrfToken,
                },
                body: JSON.stringify({ message }),
            });

            if (response.ok) {
                messageField.value = "";
                const flashDiv = document.createElement("div");
                flashDiv.className = "alert alert-success";
                flashDiv.textContent = "Message sent!";
                document.body.prepend(flashDiv);
                setTimeout(() => flashDiv.remove(), 3000);
            } else {
                alert("Failed to send your message. Please try again.");
            }
        } catch (error) {
            console.error("Error sending message:", error);
            alert("An error occurred while sending your message.");
        }
    });
});
