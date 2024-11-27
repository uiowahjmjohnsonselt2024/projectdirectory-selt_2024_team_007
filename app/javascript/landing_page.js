// app/javascript/landing_page.js

document.addEventListener('DOMContentLoaded', () => {
  // Handle 'Create Game' button click
  const createGameButton = Array.from(document.querySelectorAll('button'))
    .find(btn => btn.textContent.trim() === 'Create Game');

  if (createGameButton) {
    createGameButton.addEventListener('click', () => {
      window.location.href = "/games/new";
    });
  } else {
    console.error("Create Game button not found.");
  }

  // Handle 'Join' buttons click
  const joinButtons = Array.from(document.querySelectorAll('button'))
    .filter(btn => btn.textContent.trim() === 'Join');

  joinButtons.forEach(button => {
    button.addEventListener('click', () => {
      const joinCode = button.getAttribute('data-join-code');
      const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

      // Create a form to submit the POST request
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = '/games/join';

      // CSRF Token
      const csrfInput = document.createElement('input');
      csrfInput.type = 'hidden';
      csrfInput.name = 'authenticity_token';
      csrfInput.value = csrfToken;
      form.appendChild(csrfInput);

      // Join Code
      const joinCodeInput = document.createElement('input');
      joinCodeInput.type = 'hidden';
      joinCodeInput.name = 'join_code';
      joinCodeInput.value = joinCode;
      form.appendChild(joinCodeInput);

      document.body.appendChild(form);
      form.submit();
    });
  });
});