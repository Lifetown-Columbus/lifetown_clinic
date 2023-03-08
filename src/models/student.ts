import { Model, DataTypes, Sequelize } from "sequelize";

export default class Student extends Model {
  static config(sequelize: Sequelize): void {
    this.init(
      {
        name: {
          type: DataTypes.STRING,
          unique: true,
          allowNull: false,
        },
      },
      { sequelize }
    );
  }
}
