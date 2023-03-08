import { Sequelize, ModelAttributes, DataTypes } from "sequelize";
import { School, Student, Lesson } from "./models";

const connect = () => {
  const sequelize = new Sequelize("sqlite::memory:");

  School.config(sequelize);
  Student.config(sequelize);
  Lesson.config(sequelize);

  School.hasMany(Student);
  Student.belongsTo(School);

  Student.hasMany(Lesson);
  Lesson.belongsTo(Student);

  sequelize.sync();

  auth(sequelize);
  sequelize;
};

const auth = async (sequelize: Sequelize) => {
  try {
    await sequelize.authenticate();
    console.log("Connected to db");
  } catch {
    console.error("Unable to connect to the db");
  }
};

export default {
  connect: connect,
};
