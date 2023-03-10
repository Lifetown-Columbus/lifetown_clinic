import { Model } from "sequelize";

export interface Component {
  render(model: Model): void;
  destroy(): void;
}
