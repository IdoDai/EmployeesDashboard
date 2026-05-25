const express = require("express");
const router = express.Router();
const { sql } = require("../config/db");

// Get all Employees Info
router.get("/employees", async (req, res) => {
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
router.get("/tasks", async (req, res) => {
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
router.patch("/tasks/:id/status", async (req, res) => {
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

module.exports = router;
