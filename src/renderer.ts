const searchInput = document.getElementById("search") as HTMLInputElement;
const results = document.getElementById("results");
const api = window.api;

searchInput.onkeyup = async () => {
  api
    .search(searchInput.value)
    .then(() => (results.textContent = searchInput.value));
};
