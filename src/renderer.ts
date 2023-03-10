import { HeroCard } from "./components/hero-card";
import { Student } from "./models";

const searchInput = document.getElementById("search") as HTMLInputElement;
const results = document.getElementById("results");
const addStudentBtn = document.getElementById("add-student");
const cardContainer =
  document.getElementById("card-continer") || new HTMLElement();
const heroCard = new HeroCard(cardContainer);

// const api = window.api;

// searchInput.onkeyup = async () => {
//   api
//     .search(searchInput.value)
//     .then(() => (results.textContent = searchInput.value));
// };

if (addStudentBtn && heroCard && cardContainer) {
  addStudentBtn.onclick = () => {
    heroCard.render(Student.build({ name: "BobbyB" }));
    cardContainer.classList.remove("hidden");
  };
}
