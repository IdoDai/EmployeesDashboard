🛠️ Step 1: Database Setup & Seed
Before running the servers, you need to set up the database and populate it with initial data using SQL Server Management Studio (SSMS) or any preferred SQL client.

1. Create the Database:

Create a new database named TaskManagerDB (or use your own existing database).

2. Run the Database Scripts:
Navigate to the /db folder and execute the scripts in the following order:

  2.1.Tables Creation: Run the script that defines the schema for Employees, Departments, and Tasks.
  
  2.2.Stored Procedures: Run the script containing the Stored Procedures, specifically making sure usp_GetEmployeeTaskSummary is compiled.
  
  2.3.Seed Script: Run the seed script to populate the tables with initial test employees, departments, and tasks.

⚙️ Step 2: Environment Configuration

The project utilizes a `.env` file located inside the backend source folder (`PartTwo/.env`) to manage database credentials and server ports.

Make sure to update the `.env` file at `PartTwo/.env` with your local SQL Server credentials:

env
# Server Port Configuration
PORT=3000

# SQL Server Configuration
DB_USER=your_db_username
DB_PASSWORD=your_db_password
DB_SERVER=localhost
DB_DATABASE=TaskManagerDB/your_db_name

---

🟢 Step 3: Start the Backend API (Node.js & Express)

The backend server exposes the REST API endpoints and communicates with your SQL Server database using the credentials provided in the `.env` file.

1. Open a new terminal window and navigate to the backend folder:
   cd PartTwo
   
2. Install all required backend dependencies (including express, mssql, and cors):
  npm install

3. Start the API server:
   npm start

The server will start running and listening on http://localhost:3000.

🔍 API Endpoints Summary
Once the backend is running on port 3000, the following endpoints are fully functional:

  GET http://localhost:3000/employees - Fetches the comprehensive task breakdown summary for all employees (executes the usp_GetEmployeeTaskSummary stored procedure).
  
  GET http://localhost:3000/tasks - Returns all tasks with employee name and department (executes usp_GetAllTasks).
  
  PATCH http://localhost:3000/tasks/:id/status - Updates the status of a specific task by its ID (executes usp_UpdateTaskStatus).

🔵 Step 4: Start the Frontend App (React & Vite)
The frontend is a single-page application built with Vite. It is pre-configured to fetch statistics directly from the backend server running on port 3000.
1. Open a second terminal window and navigate to the frontend folder:
   cd PartThree
2. Install the lightweight frontend dependencies:
   npm install
3. Start the Vite development server:
   npm run dev

View the Application:
Open your browser and navigate to the local address provided by Vite (typically http://localhost:5173).

Note: The frontend will seamlessly handle communication with the backend via CORS, fetching and rendering the employee task breakdown summary in real-time.

******
I assumed that the only possible values for the status field in the usp_UpdateTaskStatus procedure are the three values specified during database creation. Furthermore, I assumed that if the input status matches the task's current status, an error should be raised (as this state is invalid) with the exception of the 'Done' status. I am aware that handling this would simply require adjusting the conditional statements inside the procedure.

