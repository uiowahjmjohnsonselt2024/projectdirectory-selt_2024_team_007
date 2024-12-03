document.addEventListener('DOMContentLoaded', function () {
    const audio = document.getElementById('background-music');

    if (!audio) {
        console.error('Audio element not found');
        return;
    }


    if (audio.paused) {
        audio.play().catch((err) => {
            console.error('Audio playback error:', err);
        });
    }
});
