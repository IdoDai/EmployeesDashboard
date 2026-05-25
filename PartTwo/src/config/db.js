const sql = require("mssql");

const dbConfig = {
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  options: {
    encrypt: true,
    trustServerCertificate: true,
  },
};

const connectDB = async () => {
  try {
    await sql.connect(dbConfig);
    console.log("Successfully connected to SQL Server!");
  } catch (err) {
    console.error("Database connection failed!", err);
    process.exit(1);
  }
};

module.exports = { sql, connectDB };
