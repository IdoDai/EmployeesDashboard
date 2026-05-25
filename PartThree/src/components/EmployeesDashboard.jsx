import { useState, useEffect } from "react";
import { getEmployees } from "../services/api";

const styles = {
  container: {
    padding: "20px",
    fontFamily: "Arial, sans-serif",
    maxWidth: "1000px",
    margin: "0 auto",
    direction: "ltr",
  },
  title: { textAlign: "center", color: "#333" },
  table: { width: "100%", borderCollapse: "collapse", marginTop: "20px" },
  th: {
    backgroundColor: "#4CAF50",
    color: "white",
    padding: "12px",
    textAlign: "left",
    border: "1px solid #ddd",
  },
  td: { padding: "12px", border: "1px solid #ddd", textAlign: "left" },
  rowEven: { backgroundColor: "#f9f9f9" },
  loading: {
    textAlign: "center",
    fontSize: "18px",
    marginTop: "20px",
    color: "#666",
  },
  error: {
    padding: "15px",
    backgroundColor: "#fff0f0",
    color: "#d9534f",
    border: "1px solid #d9534f",
    borderRadius: "4px",
    marginTop: "20px",
    textAlign: "center",
  },
};

const EmployeesDashboard = () => {
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchEmployees = async () => {
      try {
        setLoading(true);
        const data = await getEmployees();
        setEmployees(data);
        setError(null);
      } catch (err) {
        console.error("Failed to fetch employees:", err);
        setError(
          "Could not load employee data. Please ensure the backend server is running.",
        );
      } finally {
        setLoading(false);
      }
    };

    fetchEmployees();
  }, []);

  if (loading) {
    return (
      <div style={styles.loading}>
        🔄 Loading dashboard data, please wait...
      </div>
    );
  }

  if (error) {
    return <div style={styles.error}>⚠️ {error}</div>;
  }

  return (
    <div style={styles.container}>
      <h1 style={styles.title}>Employee Dashboard</h1>
      {employees.length === 0 ? (
        <p style={{ textAlign: "center" }}>No employee data found.</p>
      ) : (
        <table style={styles.table}>
          <thead>
            <tr>
              <th style={styles.th}>Employee Name</th>
              <th style={styles.th}>Department</th>
              <th style={styles.th}>Email</th>
              <th style={styles.th}>Total Tasks</th>
              <th style={styles.th}>Pending</th>
              <th style={styles.th}>In Progress</th>
              <th style={styles.th}>Done</th>
            </tr>
          </thead>
          <tbody>
            {employees.map((employee, index) => (
              <tr
                key={employee.EmployeeID || index}
                style={index % 2 === 0 ? styles.rowEven : {}}
              >
                <td style={styles.td}>{employee.FullName}</td>
                <td style={styles.td}>{employee.DepartmentID || "N/A"}</td>
                <td style={styles.td}>{employee.Email}</td>
                <td
                  style={{ ...styles.td, color: "#f0ad4e", fontWeight: "bold" }}
                >
                  {employee.TotalTasks ?? 0}
                </td>
                <td
                  style={{ ...styles.td, color: "#f0ad4e", fontWeight: "bold" }}
                >
                  {employee.PendingCount ?? 0}
                </td>
                <td
                  style={{ ...styles.td, color: "#f0ad4e", fontWeight: "bold" }}
                >
                  {employee.InProgressCount ?? 0}
                </td>
                <td
                  style={{ ...styles.td, color: "#f0ad4e", fontWeight: "bold" }}
                >
                  {employee.DoneCount ?? 0}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default EmployeesDashboard;
