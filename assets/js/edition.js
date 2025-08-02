document.addEventListener('DOMContentLoaded', () => {
  const globalSelector = document.getElementById('global-wit');
  const choices = document.querySelectorAll('.choice');
  const pages = document.querySelectorAll('.page-block');
  let currentPageIndex = 0;

  function normalizeWit(value) {
    if (value === 'lem') return 'lem';
    return value.startsWith('wit') ? value : 'wit' + value;
  }

  function extractWitNumber(wit) {
    return parseInt(wit.replace('wit', ''), 10);
  }

  function applyWitness(rawSelectedWit) {
    const selectedWit = normalizeWit(rawSelectedWit);

    choices.forEach(choice => {
      const allLemmas = Array.from(choice.querySelectorAll('.lem'));
      const allVariants = Array.from(choice.querySelectorAll('.variant'));

      // Nascondi tutto
      choice.querySelectorAll('.lem, .variant').forEach(span => {
        span.style.display = 'none';
        span.classList.remove('fallback', 'wit0', 'wit1', 'wit2', 'wit3', 'wit4', 'wit5', 'wit6', 'wit7');
      });

      // Costruisci mappa cumulativa dei contenuti
      const witMap = {};
      let lastContent = null;
      for (let i = 0; i <= 7; i++) {
        const witKey = 'wit' + i;
        const variant = allVariants.find(v => v.getAttribute('data-wit') === witKey);
        const lemma = allLemmas.find(l => l.getAttribute('data-wit') === witKey);
        if (variant) {
          witMap[witKey] = { el: variant, own: true };
          lastContent = { el: variant, own: false };
        } else if (lemma) {
          witMap[witKey] = { el: lemma, own: true };
          lastContent = { el: lemma, own: false };
        } else if (lastContent) {
          witMap[witKey] = { ...lastContent, own: false };
        }
      }

      // Applica contenuto corretto
      if (selectedWit === 'lem') {
        const lemma = allLemmas.find(l => l.classList.contains("lem"));
        if (lemma) {
          lemma.style.display = '';
          return;
        }
      } else if (witMap[selectedWit]) {
        const { el, own } = witMap[selectedWit];
        el.style.display = '';
        if (own) {
          el.classList.add(selectedWit);
        } else {
          el.classList.add('fallback');
        }
      }
    });
  }

  function showPage(index) {
    pages.forEach((page, i) => {
      page.classList.toggle('active', i === index);
    });
  }

  document.getElementById('nextPage').addEventListener('click', () => {
    if (currentPageIndex < pages.length - 1) {
      currentPageIndex++;
      showPage(currentPageIndex);
    }
  });

  document.getElementById('prevPage').addEventListener('click', () => {
    if (currentPageIndex > 0) {
      currentPageIndex--;
      showPage(currentPageIndex);
    }
  });

  globalSelector.addEventListener('change', () => {
    applyWitness(globalSelector.value);
  });

  // Navigazione da <pb>
  document.querySelectorAll('.pb').forEach(pb => {
    pb.addEventListener('click', () => {
      const page = pb.getAttribute('data-page');
      const img = document.getElementById('manuscript-image');
      const caption = document.getElementById('image-caption');
      if (img && caption) {
        img.src = `images/page${page}.jpg`;
        caption.textContent = `Pagina ${page}`;
      }

      const allPages = document.querySelectorAll('.page-block');
      allPages.forEach((pageDiv, index) => {
        if (pageDiv.getAttribute('data-page') === page) {
          pageDiv.classList.add('active');
          currentPageIndex = index;
        } else {
          pageDiv.classList.remove('active');
        }
      });
    });
  });

  

  globalSelector.value = "lem";
  applyWitness("lem");
  showPage(currentPageIndex);

});