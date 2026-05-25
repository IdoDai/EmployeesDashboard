CREATE PROCEDURE usp_GetEmployeeTaskSummary
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            e.EmployeeID,
            e.FullName,
            e.DepartmentID,
            e.Email,
            COUNT(t.TaskID) AS TotalTasks,
            SUM(CASE WHEN t.Status = 'Pending' THEN 1 ELSE 0 END) AS PendingCount,
            SUM(CASE WHEN t.Status = 'In Progress' THEN 1 ELSE 0 END) AS InProgressCount,
            SUM(CASE WHEN t.Status = 'Done' THEN 1 ELSE 0 END) AS DoneCount,            
            MIN(CASE WHEN t.Status <> 'Done' AND t.DueDate >= CAST(GETDATE() AS DATE) THEN t.DueDate END) AS NearestUpcomingDueDate
        FROM Employees e
        LEFT JOIN Tasks t ON e.EmployeeID = t.AssignedTo
        GROUP BY e.EmployeeID, e.FullName, e.DepartmentID, e.Email;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Error in usp_GetEmployeeTaskSummary: %s', 16, 1, @ErrMsg);
    END CATCH
END;
GO

CREATE PROCEDURE usp_GetAllTasks
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            t.TaskID,
            t.Title,
            t.Description,
            t.Status,
            t.DueDate,
            t.CreatedAt,
            e.FullName,
            d.DepartmentName
        FROM Tasks t
        LEFT JOIN Employees e ON t.AssignedTo=e.EmployeeID
        LEFT JOIN Departments d ON e.DepartmentID=d.DepartmentID
        ORDER BY t.CreatedAt DESC
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Error in usp_GetAllTasks: %s', 16, 1, @ErrMsg);
    END CATCH
END;
GO

CREATE PROCEDURE usp_AssignTask
    @TaskID INT,
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Tasks WHERE TaskID = @TaskID)
        BEGIN
            RAISERROR('The recieved TaskID cannot be found', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @EmployeeID)
        BEGIN
            RAISERROR('The recieved EmployeeID cannot be found', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Tasks WHERE TaskID = @TaskID AND Status = 'Done')
        BEGIN
            RAISERROR('The recieved TaskID is allready completed', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

            UPDATE Tasks
            SET AssignedTo=@EmployeeID
            WHERE TaskID=@TaskID

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Error in usp_AssignTask: %s', 16, 1, @ErrMsg);
    END CATCH
END;
GO

CREATE PROCEDURE usp_UpdateTaskStatus
    @TaskID INT,
    @NewStatus NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        DECLARE @CurrentStatus NVARCHAR(20);
        SELECT @CurrentStatus = Status FROM Tasks WHERE TaskID = @TaskID;

        IF @CurrentStatus IS NULL
        BEGIN
            RAISERROR('The given task cannot be found.', 16, 1);
            RETURN;
        END

        IF (@CurrentStatus = 'Pending' AND @NewStatus <> 'In Progress')
           OR (@CurrentStatus = 'In Progress' AND @NewStatus <> 'Done')
           OR (@CurrentStatus = 'Done' AND @NewStatus <> 'Done')
        BEGIN
            DECLARE @Msg NVARCHAR(250) = FORMATMESSAGE(N'The system encountered a try for an invalid transition in the status field, Please notice that the only valid transitions are in this order: Pending -> In Progress -> Done.', @CurrentStatus, @NewStatus);
            RAISERROR(@Msg, 16, 1);
            RETURN;
        END

        UPDATE Tasks
        SET Status=@NewStatus
        WHERE TaskID=@TaskID;

    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Error in usp_UpdateTaskStatus: %s', 16, 1, @ErrMsg);
    END CATCH
END;
GO

CREATE PROCEDURE usp_GetOverdueTasks
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            t.TaskID,
            t.Title,
            t.Description,
            t.Status,
            t.DueDate,
            t.CreatedAt,
            e.FullName,
            d.DepartmentName
        FROM Tasks t
        LEFT JOIN Employees e ON t.AssignedTo=e.EmployeeID
        LEFT JOIN Departments d ON e.DepartmentID=d.DepartmentID
        WHERE t.DueDate < CAST(GETDATE() AS DATE) AND t.Status <> 'Done'
        ORDER BY t.DueDate ASC
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Error in usp_GetOverdueTasks: %s', 16, 1, @ErrMsg);
    END CATCH
END;
GO

CREATE PROCEDURE usp_RebalanceTasks
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        CREATE TABLE #EmployeeLoad (
            EmployeeID INT PRIMARY KEY,
            DepartmentID INT,
            ActiveTaskCount INT
        );

        INSERT INTO #EmployeeLoad (EmployeeID, DepartmentID, ActiveTaskCount)
        SELECT e.EmployeeID, e.DepartmentID, COUNT(t.TaskID)
        FROM Employees e
        LEFT JOIN Tasks t ON e.EmployeeID = t.AssignedTo AND t.Status <> 'Done'
        GROUP BY e.EmployeeID, e.DepartmentID;

        DECLARE overloaded_employee_cursor CURSOR LOCAL FOR
            SELECT EmployeeID, DepartmentID, ActiveTaskCount
            FROM #EmployeeLoad
            WHERE ActiveTaskCount > 3;

        DECLARE @OverloadedEmpID INT;
        DECLARE @DepartmentID INT;
        DECLARE @OpenTaskCount INT;

        BEGIN TRANSACTION;

        OPEN overloaded_employee_cursor;
        FETCH NEXT FROM overloaded_employee_cursor INTO @OverloadedEmpID, @DepartmentID, @OpenTaskCount;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @ExcessCount INT = @OpenTaskCount - 3;

            WHILE @ExcessCount > 0
            BEGIN
                DECLARE @TargetEmployeeID INT = NULL;

                SELECT TOP 1 @TargetEmployeeID = EmployeeID
                FROM #EmployeeLoad
                WHERE DepartmentID = @DepartmentID 
                  AND EmployeeID <> @OverloadedEmpID
                  AND ActiveTaskCount < 3 
                ORDER BY ActiveTaskCount ASC, EmployeeID ASC;

                IF @TargetEmployeeID IS NULL
                BEGIN
                    BREAK; 
                END

                DECLARE @TaskToMove INT;
                SELECT TOP 1 @TaskToMove = TaskID 
                FROM Tasks 
                WHERE AssignedTo = @OverloadedEmpID AND Status <> 'Done'
                ORDER BY DueDate DESC;

                UPDATE Tasks
                SET AssignedTo = @TargetEmployeeID
                WHERE TaskID = @TaskToMove;

                UPDATE #EmployeeLoad 
                SET ActiveTaskCount = ActiveTaskCount + 1 
                WHERE EmployeeID = @TargetEmployeeID;

                UPDATE #EmployeeLoad 
                SET ActiveTaskCount = ActiveTaskCount - 1 
                WHERE EmployeeID = @OverloadedEmpID;

                SET @ExcessCount = @ExcessCount - 1;
            END

            FETCH NEXT FROM overloaded_employee_cursor INTO @OverloadedEmpID, @DepartmentID, @OpenTaskCount;
        END

        CLOSE overloaded_employee_cursor;
        DEALLOCATE overloaded_employee_cursor;

        DROP TABLE #EmployeeLoad;

        COMMIT TRANSACTION;
        PRINT 'Task rebalancing completed successfully using cached load table.';

    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'overloaded_employee_cursor') >= 0
        BEGIN
            CLOSE overloaded_employee_cursor;
            DEALLOCATE overloaded_employee_cursor;
        END
        
        IF OBJECT_ID('tempdb..#EmployeeLoad') IS NOT NULL
            DROP TABLE #EmployeeLoad;

        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Error in usp_RebalanceTasks: %s', 16, 1, @ErrMsg);
    END CATCH
END;
GO