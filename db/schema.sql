CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL
);

CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    DepartmentID INT,
    CreatedAt DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Employees_Departments FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE SET NULL
);

CREATE TABLE Tasks (
    TaskID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(150) NOT NULL,
    Description NVARCHAR(MAX),
    AssignedTo INT, 
    Status NVARCHAR(20) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'In Progress', 'Done')),
    DueDate DATE,
    CreatedAt DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Tasks_Employees FOREIGN KEY (AssignedTo)
        REFERENCES Employees(EmployeeID)
        ON DELETE SET NULL
);
