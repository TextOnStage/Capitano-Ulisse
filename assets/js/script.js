document.addEventListener('DOMContentLoaded', () => {
    const globalSelector = document.getElementById('global-wit');
    const choices = document.querySelectorAll('choice');

    // Definizione dei colori per ogni wit
    const witColors = {
        'original': 'black',      // Colore per il testo originale
        'wit1': 'blue',          // Colore per il testimone 1
        'wit2': 'green'          // Colore per il testimone 2
    };

    // Gestione del cambio globale
    globalSelector.addEventListener('change', () => {
        const selectedWit = globalSelector.value;

        choices.forEach(choice => {
            const lemma = choice.querySelector('.lem');
            const variants = choice.querySelectorAll('.variant');

            // Trova la variante corrispondente al testimone selezionato
            let matchingVariant = null;
            if (selectedWit === 'original') {
                matchingVariant = choice.querySelector('.sic'); // Testo originale
            } else {
                matchingVariant = Array.from(variants).find(variant => 
                    variant.getAttribute('data-wit') === selectedWit
                );
            }

            // Aggiorna il lemma con la variante corrispondente
            if (matchingVariant) {
                lemma.textContent = matchingVariant.textContent;

                // Cambia il colore in base al wit selezionato
                lemma.style.color = witColors[selectedWit] || 'black';
            }
        });
    });
});
