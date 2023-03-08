import { Model, ModelAttributes, Sequelize } from "sequelize";

export default class Lesson extends Model {
  static config(sequelize: Sequelize): void {
    this.init({}, { sequelize });
  }
}
