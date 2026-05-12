const searchInput = document.querySelector("#wiki-search");
const sections = [...document.querySelectorAll(".wiki-section")];
const emptyState = document.querySelector("#empty-state");
const navLinks = [...document.querySelectorAll(".nav a")];

function normalize(value) {
  return value.toLowerCase().replace(/\s+/g, " ").trim();
}

function applySearch() {
  const query = normalize(searchInput.value);
  let visible = 0;

  sections.forEach((section) => {
    const haystack = normalize(`${section.textContent} ${section.dataset.keywords || ""}`);
    const match = query === "" || haystack.includes(query);
    section.classList.toggle("is-hidden", !match);
    if (match) visible += 1;
  });

  emptyState.hidden = visible !== 0;
}

const observer = new IntersectionObserver(
  (entries) => {
    const active = entries
      .filter((entry) => entry.isIntersecting)
      .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];

    if (!active) return;

    navLinks.forEach((link) => {
      link.classList.toggle("is-active", link.getAttribute("href") === `#${active.target.id}`);
    });
  },
  { rootMargin: "-20% 0px -65% 0px", threshold: [0.1, 0.25, 0.5] }
);

sections.forEach((section) => observer.observe(section));
searchInput.addEventListener("input", applySearch);
