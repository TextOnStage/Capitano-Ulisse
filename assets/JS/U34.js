document.addEventListener("DOMContentLoaded", () => {
  const pageSelect   = document.getElementById("page-select");
  const layerSelect  = document.getElementById("layer-select");
  const metadataBtn  = document.getElementById("metadata-toggle");
  const metadataPane = document.getElementById("metadata-panel");
  const layout       = document.querySelector(".viewer-layout");
  const pages        = Array.from(document.querySelectorAll("#page-viewer .page"));

  const peopleList = document.getElementById("meta-people-list");
  const placesList = document.getElementById("meta-places-list");
  const otherList  = document.getElementById("meta-other-list");

  if (!pages.length) return;

  const BASE_WIT = "U34";

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
          seen.set(dedupKey, { li, role });
        }
        continue;
      }

      seen.set(dedupKey, { li, role });
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
    let found = false;

    pages.forEach(p => {
      if (p.getAttribute("data-page") === target) {
        p.classList.add("is-active");
        found = true;
      } else {
        p.classList.remove("is-active");
      }
    });

    if (!found && pages[0]) {
      pages[0].classList.add("is-active");
      if (pageSelect) pageSelect.value = pages[0].getAttribute("data-page") || "";
    }

   
    applyWitnessToActivePage();
    updateEntitiesForActivePage();
  }

  function parseWitnesses(witString) {
    if (!witString) return [];
    return witString.split(/\s+/).map(s => s.trim()).filter(Boolean);
  }

  function textOf(el) {
    return (el && (el.textContent || "")).replace(/\s+/g, " ").trim();
  }

  function isOnlyNotPresentMessage(variantEl) {
    if (!variantEl) return false;
    const markers = variantEl.querySelectorAll(".gap .gap-marker");
    if (markers.length !== 1) return false;
    const whole = textOf(variantEl);
    const msg = textOf(markers[0]);
    return msg && whole === msg;
  }

  function resetDecorations(scope) {
    scope.querySelectorAll(".choice.text-block").forEach(block => {
      block.classList.remove("has-direct-variant", "has-fallback-variant", "is-not-present");
      block.querySelectorAll(".variant").forEach(v => {
        v.classList.remove("is-active", "is-direct", "is-fallback");
      });
    });
  }

  function applyWitness(scope, selectedWitness) {
    const wit = String(selectedWitness || "").trim();
    if (!wit) return;

    const decorateMode = (wit !== BASE_WIT);

    scope.querySelectorAll(".choice.text-block").forEach(block => {
      const variants = Array.from(block.querySelectorAll(".variant"));
      if (!variants.length) return;

    
      const map = {};
      variants.forEach(v => {
        const wits = parseWitnesses(v.dataset.wit || "");
        wits.forEach(w => { map[w] = v; });
      });

      
      const baseEl = map[BASE_WIT] || variants.find(v => v.classList.contains("lem")) || variants[0];

      
      const directEl = map[wit] || null;
      const chosenEl = directEl || baseEl;

      
      chosenEl.classList.add("is-active");

      
      const differsFromBase = (chosenEl !== baseEl);

      if (decorateMode && differsFromBase) {
        const isDirect = !!directEl;

        chosenEl.classList.add(isDirect ? "is-direct" : "is-fallback");
        block.classList.add(isDirect ? "has-direct-variant" : "has-fallback-variant");

        if (isOnlyNotPresentMessage(chosenEl)) {
          block.classList.add("is-not-present");
        }
      }
    });
  }

  function applyWitnessToActivePage() {
    const active = getActivePage();
    if (!active) return;

    const wit = (layerSelect && layerSelect.value) ? layerSelect.value : BASE_WIT;

    resetDecorations(active);
    applyWitness(active, wit);
  }

  
  if (layerSelect) {
    const hasU34 = !!Array.from(layerSelect.options).find(o => o.value === BASE_WIT);
    if (hasU34) layerSelect.value = BASE_WIT;
  }

  const initialPage = pages[0];
  if (pageSelect && initialPage) pageSelect.value = initialPage.getAttribute("data-page") || "";
  setActivePage(pageSelect ? pageSelect.value : (initialPage ? initialPage.getAttribute("data-page") : "1"));

 
  if (pageSelect) {
    pageSelect.addEventListener("change", function () {
      setActivePage(this.value);
    });
  }

  if (layerSelect) {
    layerSelect.addEventListener("change", function () {
     
      applyWitnessToActivePage();
    });
  }

  if (metadataBtn && metadataPane) {
    metadataBtn.addEventListener("click", () => {
      const isHidden = metadataPane.hasAttribute("hidden");
      if (isHidden) {
        metadataPane.removeAttribute("hidden");
        if (layout) layout.classList.add("with-metadata");
        updateEntitiesForActivePage();
      } else {
        metadataPane.setAttribute("hidden", "hidden");
        if (layout) layout.classList.remove("with-metadata");
      }
    });
  }

  if (metadataPane && !metadataPane.hasAttribute("hidden")) {
    if (layout) layout.classList.add("with-metadata");
    updateEntitiesForActivePage();
  }
});

