INSERT INTO Departments (DepartmentName) VALUES 
('R&D'), 
('Product'), 
('HR'),
('Marketing'),
('QA'),
('Sales');

INSERT INTO Employees (FullName, Email, DepartmentID) VALUES 
('Ido Cohen', 'ido@company.com', 1),       
('Efrat Levi', 'efrat@company.com', 2),     
('Tomer Avraham', 'tomer@company.com', 1),  
('Maya Stern', 'maya@company.com', 3),       
('Nir Golan', 'nir@company.com', 1),       
('Roni Daniel', 'roni@company.com', 4),     
('Amit Bar', 'amit@company.com', 5),        
('Dana Shani', 'dana@company.com', 1),      
('Guy Kaplan', 'guy@company.com', 2),     
('Noa Feld', 'noa@company.com', 5),         
('Omer Paz', 'omer@company.com', 6),       
('Adi Lev', 'adi@company.com', 4);        

INSERT INTO Tasks (Title, Description, AssignedTo, Status, DueDate) VALUES 
('Home Page Architecture', 'Write the technical design document for the task manager dashboard', 2, 'Done', '2025-05-10'),
('Local DB Setup', 'Install SQL Express and establish connection inside SSMS client', 1, 'Done', '2025-05-20'),
('Create Database Schema', 'Design tables, primary keys, and foreign key relations', 1, 'Done', '2025-05-22'),
('QA Automation Infrastructure', 'Setup Playwright environment for E2E web testing', 7, 'Done', '2025-05-25'),
('Write T-SQL Procedures', 'Implement the 5 required stored procedures with custom error handling', 1, 'In Progress', '2027-05-28'),
('React UI Components', 'Build out the main Summary View dashboard layout using React tables', 3, 'In Progress', '2027-05-30'),
('Upgrade Node.js Environment', 'Bump outdated runtime packages to the latest LTS version on local servers', 1, 'In Progress', '2025-05-01'),
('Refactor API Middleware', 'Clean up routes and separate concerns using Express Router', 1, 'In Progress', '2027-06-01'),
('Bug Fix: CORS Policy', 'Resolve cross-origin resource sharing blocks on the dev server', 3, 'In Progress', '2027-06-02'),
('Product Specs v2', 'Define product workflow requirements for the upcoming mobile version', 9, 'In Progress', '2027-06-10'),
('Sanity Testing Run', 'Execute manual sanity testing on the current staging build', 10, 'In Progress', '2027-05-29'),
('Integration Testing', 'Conduct end-to-end integration testing between React components and API endpoints', 5, 'Pending', '2027-06-05'),
('Recruitment Screening', 'Filter incoming CVs for the open Junior Developer positions', 4, 'Pending', '2027-06-15'),
('Internal Launch Campaign', 'Prepare presentation slides and onboarding materials for department heads', 6, 'Pending', '2027-06-20'),
('Quarterly Budget Audit', 'Compile and submit the Q1 financial spending report to the Product Director', 2, 'Pending', '2025-05-15'),
('Fix Authentication Bug', 'Mitigate unauthorized login exploits by enforcing rigid SSL token policies', 5, 'Pending', '2025-05-18'),
('Performance Profiling', 'Identify slow running queries in SQL server and optimize indexes', 5, 'Pending', '2027-06-12'),
('Optimize Docker Images', 'Reduce multi-stage production Docker build sizes for faster deployment', 5, 'Pending', '2027-06-18'),
('UI Accessibility Audit', 'Verify WCAG compliance for colors, fonts, and keyboard navigation', 3, 'Pending', '2027-06-22'),
('SEO Keywords Strategy', 'Analyze competitor metrics and map out target high-volume phrases', 6, 'Pending', '2027-06-25'),
('B2B Sales Pitch Deck', 'Draft custom feature packages and pricing plans for corporate clients', 11, 'Pending', '2027-06-30'),
('Onboarding HR Docs', 'Update company code of conduct policy files and distribute via email', 4, 'Pending', '2027-07-05');
GO