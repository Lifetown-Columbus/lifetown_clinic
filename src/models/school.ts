import { Sequelize, DataTypes, Model } from "sequelize";

export default class School extends Model {
  static config(sequelize: Sequelize): void {
    School.init(
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
