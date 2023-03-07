import { Sequelize } from "sequelize";

const connect = () => {
  const sequelize = new Sequelize("sqlite::memory:");
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
