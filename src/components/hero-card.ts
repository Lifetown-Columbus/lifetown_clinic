import { Component } from "./component";
import { Student } from "../models";

export class HeroCard implements Component {
  root: HTMLElement;
  element: HTMLElement;
  template = `
    <div class="card hidden">
        <h1>Superhero Card</h1>
        <form>
            <label for="name">Name:</label>
            <input type="text" id="name" />
            <label for="school">School:</label>
            <input type="text" id="school" />
        </form>

        <ul class="progress">
            <span>☆</span
            ><span>☆</span
            ><span>☆</span
            ><span>☆</span
            ><span>☆</span
            ><span>☆</span>
        </ul>
        <button>Save</button>
    </div>
  `;

  constructor(root: HTMLElement) {
    this.root = root;
    this.element = new HTMLElement();
  }

  render(model: Student) {
    this.destroy();
    this.element = new HTMLElement();
    this.element.textContent = this.template;
    this.root.appendChild(this.element);
  }

  destroy() {
    this.element.remove();
  }
}
