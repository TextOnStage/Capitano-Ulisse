document.addEventListener("DOMContentLoaded", () => {
  const pageSelect   = document.getElementById("page-select");
  const layerSelect  = document.getElementById("layer-select");
  const metadataBtn  = document.getElementById("metadata-toggle");
  const metadataPane = document.getElementById("metadata-panel");
  const layout       = document.querySelector(".viewer-layout");
  const pages        = Array.from(document.querySelectorAll("#page-viewer .page"));

  const metaPage = document.getElementById("meta-page-number");
  const metaFacs = document.getElementById("meta-facs-id");

  const peopleList = document.getElementById("meta-people-list");
  const placesList = document.getElementById("meta-places-list");
  const otherList  = document.getElementById("meta-other-list");

  if (!pages.length) return;

  function getActivePage() {
    return document.querySelector("#page-viewer .page.is-active");
  }

  function setEmptyList(ul) {
    if (!ul) return;
    ul.innerHTML = "";
    const li = document.createElement("li");
    li.textContent = "—";
    ul.appendChild(li);
  }

  function updateMetadataForActivePage() {
    const active = getActivePage();
    if (!active) return;
    if (metaPage) metaPage.textContent = active.getAttribute("data-page") || "–";
    if (metaFacs) metaFacs.textContent = active.getAttribute("data-facs") || "–";
  }

  function bucketForType(type) {
    if (type === "placeName") return placesList;
    if (type === "persName") return peopleList;
    return otherList;
  }

  function updateEntitiesForActivePage() {
    if (!peopleList || !placesList || !otherList) return;

    peopleList.innerHTML = "";
    placesList.innerHTML = "";
    otherList.innerHTML  = "";

    const active = getActivePage();
    if (!active) {
      setEmptyList(peopleList);
      setEmptyList(placesList);
      setEmptyList(otherList);
      return;
    }

    const source = active.querySelector(".page-entities-source");
    if (!source) {
      setEmptyList(peopleList);
      setEmptyList(placesList);
      setEmptyList(otherList);
      return;
    }

    const items = Array.from(source.querySelectorAll("li"));

    const seen = new Map(); 

    for (const it of items) {
      const type  = (it.getAttribute("data-type") || "").trim();
      const role  = (it.getAttribute("data-role") || "").trim();
      const wd    = (it.getAttribute("data-wd") || "").trim();
      const key   = (it.getAttribute("data-key") || "").trim();
      const label = (it.textContent || "").trim();

      if (!label) continue;

      const ul = bucketForType(type);
      if (!ul) continue;

      
      const li = document.createElement("li");

      if (wd && /^https?:\/\//i.test(wd)) {
        const a = document.createElement("a");
        a.href = wd;
        a.target = "_blank";
        a.rel = "noopener noreferrer";
        a.textContent = label;
        if (role === "speaker") a.style.fontWeight = "700";
        li.appendChild(a);
      } else {
        li.textContent = label;
        if (role === "speaker") li.style.fontWeight = "700";
      }

      const dedupKey = key || (wd ? wd : `${type}|${label}`);

      if (seen.has(dedupKey)) {
        const prev = seen.get(dedupKey);
        if (role === "speaker" && prev.role !== "speaker") {
          prev.li.replaceWith(li);
          seen.set(dedupKey, { li, role, type, label });
        }
        continue;
      }

      seen.set(dedupKey, { li, role, type, label });
      ul.appendChild(li);
    }

    if (!peopleList.children.length) setEmptyList(peopleList);
    if (!placesList.children.length) setEmptyList(placesList);
    if (!otherList.children.length)  setEmptyList(otherList);

    
    function sortUL(ul) {
      if (!ul) return;
      const lis = Array.from(ul.querySelectorAll("li"));
      if (lis.length === 1 && lis[0].textContent.trim() === "—") return;

      lis.sort((a, b) => {
        const ta = (a.textContent || "").trim().toLowerCase();
        const tb = (b.textContent || "").trim().toLowerCase();
        return ta.localeCompare(tb);
      });

      ul.innerHTML = "";
      lis.forEach(li => ul.appendChild(li));
    }

    sortUL(peopleList);
    sortUL(placesList);
    sortUL(otherList);
  }

  function setActivePage(pageNum) {
    const target = String(pageNum);
    pages.forEach(p => {
      if (p.getAttribute("data-page") === target) p.classList.add("is-active");
      else p.classList.remove("is-active");
    });

    updateMetadataForActivePage();
    updateEntitiesForActivePage();
  }

  
  function updateVariantsForLayer(layerId) {
    const layer = String(layerId || "").trim();
    if (!layer) return;

    document.querySelectorAll(".choice.text-block").forEach(block => {
      const variants = Array.from(block.querySelectorAll(".variant"));
      if (!variants.length) return;

      const map = {};
      variants.forEach(v => {
        const wit = (v.dataset.wit || "").trim();
        if (wit) map[wit] = v;
        v.classList.remove("is-active", "is-direct");
      });

      function chooseVariant(selectedWit) {
        if (map[selectedWit]) return { el: map[selectedWit], direct: true };

        const m = selectedWit.match(/^([^\d]*)(\d+)$/);
        if (m) {
          const prefix = m[1];
          let num = parseInt(m[2], 10);
          while (num > 0) {
            num -= 1;
            const candidate = prefix + num;
            if (map[candidate]) return { el: map[candidate], direct: false };
          }
        }

        const keys = Object.keys(map);
        if (!keys.length) return null;

        keys.sort((a, b) => {
          const ma = a.match(/^([^\d]*)(\d+)$/);
          const mb = b.match(/^([^\d]*)(\d+)$/);
          const na = ma ? parseInt(ma[2], 10) : 9999;
          const nb = mb ? parseInt(mb[2], 10) : 9999;
          return na - nb;
        });

        return { el: map[keys[0]], direct: false };
      }

      const chosen = chooseVariant(layer);
      if (chosen && chosen.el) {
        chosen.el.classList.add("is-active");
        if (chosen.direct && chosen.el.dataset.wit !== "strato0") {
          chosen.el.classList.add("is-direct");
        }
      }
    });
  }

  
  const initial = getActivePage() || pages[0];
  const initialNum = initial.getAttribute("data-page");
  if (pageSelect && initialNum) pageSelect.value = initialNum;
  setActivePage(initialNum);

  if (pageSelect) {
    pageSelect.addEventListener("change", function () {
      setActivePage(this.value);
    });
  }

  if (layerSelect) {
    updateVariantsForLayer(layerSelect.value);
    layerSelect.addEventListener("change", function () {
      updateVariantsForLayer(this.value);
    });
  }

  if (metadataBtn && metadataPane) {
    metadataBtn.addEventListener("click", () => {
      const isHidden = metadataPane.hasAttribute("hidden");
      if (isHidden) {
        metadataPane.removeAttribute("hidden");
        if (layout) layout.classList.add("with-metadata");
        updateMetadataForActivePage();
        updateEntitiesForActivePage();
      } else {
        metadataPane.setAttribute("hidden", "hidden");
        if (layout) layout.classList.remove("with-metadata");
      }
    });
  }
});



(function () {
  "use strict";

  const layerSelect = document.getElementById("layer-select");
  if (!layerSelect) return;

  const choiceBlocks = Array.from(document.querySelectorAll(".choice.text-block"));
  if (!choiceBlocks.length) return;

  let previousWit = layerSelect.value || "strato0";

  const witIndex = (wit) => {
    const m = String(wit || "").match(/(\d+)$/);
    return m ? parseInt(m[1], 10) : 0;
  };


  function pickReading(choiceEl, targetWit) {
    const target = witIndex(targetWit);

    for (let i = target; i >= 0; i--) {
      const w = `strato${i}`;
      const candidate = choiceEl.querySelector(`.variant[data-wit="${w}"]`);
      if (candidate) return candidate;
    }

    
    return choiceEl.querySelector(".variant") || null;
  }

  function textOf(el) {
    return (el?.textContent || "").replace(/\s+/g, " ").trim();
  }

  function clearState(choiceEl) {
    const variants = choiceEl.querySelectorAll(".variant");
    variants.forEach((v) => {
      v.classList.remove("is-active", "is-direct", "is-delta");
      v.style.display = "none";
    });
  }

  function applyLayer(targetWit) {
    const targetIdx = witIndex(targetWit);

    choiceBlocks.forEach((choiceEl) => {
    
      const prevEl = pickReading(choiceEl, previousWit);
      const prevText = textOf(prevEl);

   
      const activeEl = pickReading(choiceEl, targetWit);
      const activeText = textOf(activeEl);

      clearState(choiceEl);

      if (!activeEl) return;

      activeEl.style.display = "inline";
      activeEl.classList.add("is-active");

  
      const activeWit = activeEl.getAttribute("data-wit");
      if (activeWit === targetWit && targetIdx !== 0) {
        activeEl.classList.add("is-direct");
      }

      if (previousWit && prevText !== activeText) {
        activeEl.classList.add("is-delta");
      }

      
    });

    previousWit = targetWit;
  }


  applyLayer(previousWit);

  layerSelect.addEventListener("change", () => {
    const selected = layerSelect.value || "strato0";
    applyLayer(selected);
  });
})();
