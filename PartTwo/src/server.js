require("dotenv").config();
const express = require("express");
const cors = require("cors");
const sql = require("mssql");

const app = express();
app.use(cors());
app.use(express.json());

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

// Get all Employees Info
app.get("/employees", async (req, res) => {
  try {
    const request = new sql.Request();

    const result = await request.query(`EXEC usp_GetEmployeeTaskSummary`);
    res.json(result.recordset);
  } catch (err) {
    res
      .status(500)
      .json({ error: "Internal Server Error", message: err.message });
  }
});

// Get all Tasks Info
app.get("/tasks", async (req, res) => {
  try {
    const request = new sql.Request();

    const result = await request.query(`EXEC usp_GetAllTasks`);
    res.json(result.recordset);
  } catch (err) {
    res
      .status(500)
      .json({ error: "Internal Server Error", message: err.message });
  }
});

// Update Task status
app.patch("/tasks/:id/status", async (req, res) => {
  const taskId = req.params.id;
  const { status } = req.body;

  if (!status) {
    return res.status(400).json({
      error: "Bad Request",
      message: "Status is required in request body to proceed.",
    });
  }

  try {
    await sql.query`EXEC usp_UpdateTaskStatus @TaskID = ${taskId}, @NewStatus = ${status}`;

    res.json({
      message: `Task ${taskId} status updated successfully to '${status}'.`,
    });
  } catch (err) {
    res.status(400).json({ error: "Validation Error", message: err.message });
  }
});

sql
  .connect(dbConfig)
  .then(() => {
    console.log("Successfully connected to SQL Server!");

    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      console.log(`Server is running smoothly on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("Database connection failed!", err);
  });
