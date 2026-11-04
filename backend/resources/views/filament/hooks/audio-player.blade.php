<audio id="order-sound" src="https://actions.google.com/sounds/v1/alarms/beep_short.ogg" preload="auto"></audio>
<script>
    document.addEventListener('livewire:initialized', () => {
        Livewire.on('play-sound', (event) => {
            const audio = document.getElementById('order-sound');
            if (audio) {
                audio.play().catch(e => console.log('Audio play error:', e));
            }
        });
    });
</script>
