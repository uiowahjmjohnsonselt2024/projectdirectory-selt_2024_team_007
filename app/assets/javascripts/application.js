document.addEventListener('DOMContentLoaded', function () {
    const audio = document.getElementById('background-music');

    if (!audio) {
        console.error('Audio element not found');
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
