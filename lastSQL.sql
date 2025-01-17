USE dbEmployee;

CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    Position VARCHAR(50),
    FullName VARCHAR(50),
    EmployeeSalary DECIMAL(18, 2),
    Birthdate DATE,
    Hire_Date DATE,
    Phone_Number VARCHAR(15), 
    Email VARCHAR(255), 
    Address TEXT,
    Worked_For VARCHAR(50),
    EmployeePassword NVARCHAR(256),
    LeaveCount INT
);

CREATE TABLE Admin (
    AdminID INT PRIMARY KEY,
    EmployeeID INT,
    Position VARCHAR(50),
    FullName VARCHAR(50),
    AdminSalary DECIMAL(18, 2),
    Birthdate DATE,
    Hire_Date DATE,
    Phone_Number VARCHAR(15), 
    Email VARCHAR(255), 
    Address TEXT,
    Worked_For VARCHAR(50),
    AdminPassword NVARCHAR(256),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

CREATE TABLE AttendanceEmployee (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT,
    Date DATE,
    TimeIN TIME,
    TimeOut TIME,
    TotalHours INT,
    IsLate BIT,
	TotalDays INT,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

CREATE TABLE AttendanceAdmin (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    AdminID INT,
    Date DATE,
    TimeIN TIME,
    TimeOut TIME,
    TotalHours INT,
	TotalDays INT,
    FOREIGN KEY (AdminID) REFERENCES Admin(AdminID)
);

CREATE TABLE Payroll (
    PayrollID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT NULL,
    AdminID INT NULL,
    GrossPay DECIMAL(18, 2),
    SSSDeduction DECIMAL(18, 2),
    PhilHealthDeduction DECIMAL(18, 2),
    PagIbigDeduction DECIMAL(18, 2),
    TotalDeduction DECIMAL(18, 2),
    NetPay DECIMAL(18, 2),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (AdminID) REFERENCES Admin(AdminID)
);

CREATE TABLE LeaveRequests (
    LeaveID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT,
    LeaveType VARCHAR(50),
    StartDate DATE,
    EndDate DATE,
    Status VARCHAR(20),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

INSERT INTO Employee (EmployeeID, Position, FullName, EmployeeSalary, EmployeePassword, Phone_Number, Email, Birthdate, Address, Hire_Date, Worked_For)
VALUES 
(2001, 'Developer', 'Franz Deloritos', 50000, 'Deloritos', '09154375321', 'Deloritos@gmail.com', '2004-10-15', 'Angono', '2022-01-01', '2 year/s'),
(2002, 'Developer', 'Karl Fabon', 50000, 'Fabon', '09165975321', 'Fabon@gmail.com', '2003-10-24', 'Antipolo', '2023-02-02', '1 year/s');

INSERT INTO Admin (AdminID, Position, FullName, AdminSalary, AdminPassword, Phone_Number, Email, Birthdate, Address, Hire_Date, Worked_For)
VALUES 
(1001, 'CEO', 'EJ Sullera', 75000, 'Sullera', '09165975321', 'Sullera@gmail.com', '2002-02-08', 'Antipolo', '2019-01-01', '5 year/s');

CREATE PROCEDURE AddAdmin
    @FullName VARCHAR(50),
    @Position VARCHAR(50),
    @Salary DECIMAL(18, 2),
    @Password VARCHAR(50)
AS
BEGIN
    DECLARE @HashedPassword NVARCHAR(256);
    SET @HashedPassword = CONVERT(NVARCHAR(256), HASHBYTES('SHA2_256', @Password), 2);

    INSERT INTO Admin (FullName, Position, AdminSalary, AdminPassword)
    VALUES (@FullName, @Position, @Salary, @HashedPassword);

    SELECT SCOPE_IDENTITY() AS AdminID;
END;

CREATE PROCEDURE AddEmployee
    @FullName VARCHAR(50),
    @Position VARCHAR(50),
    @Salary DECIMAL(18, 2),
    @Password VARCHAR(50)
AS
BEGIN
    DECLARE @HashedPassword NVARCHAR(256);
    SET @HashedPassword = CONVERT(NVARCHAR(256), HASHBYTES('SHA2_256', @Password), 2);

    INSERT INTO Employee (FullName, Position, EmployeeSalary, EmployeePassword)
    VALUES (@FullName, @Position, @Salary, @HashedPassword);

    SELECT SCOPE_IDENTITY() AS EmployeeID;
END;


CREATE PROCEDURE LogAttendance
    @EmployeeID INT,
    @Date DATE,
    @TimeIN TIME,
    @TimeOut TIME
AS
BEGIN
    DECLARE @ExpectedTime TIME = '08:00:00';
    DECLARE @IsLate BIT;
    DECLARE @TotalHours DECIMAL(5, 2);
    DECLARE @TotalDays INT = 0;

    IF @TimeIN IS NOT NULL
    BEGIN
        SET @IsLate = CASE 
                        WHEN @TimeIN > @ExpectedTime THEN 1
                        ELSE 0
                     END;
    END
    ELSE
    BEGIN
        SET @IsLate = 0;
    END

    IF @TimeIN IS NOT NULL AND @TimeOut IS NOT NULL
    BEGIN
        SET @TotalHours = DATEDIFF(MINUTE, @TimeIN, @TimeOut) / 60.0;
        SET @TotalDays = 1;  
    END
    ELSE
    BEGIN
        SET @TotalHours = 0;
    END

    IF EXISTS (SELECT 1 FROM AttendanceEmployee WHERE EmployeeID = @EmployeeID AND Date = @Date)
    BEGIN
        UPDATE AttendanceEmployee
        SET TimeIN = @TimeIN,
            TimeOut = @TimeOut,
            TotalHours = @TotalHours,
            TotalDays = @TotalDays,
            IsLate = @IsLate
        WHERE EmployeeID = @EmployeeID AND Date = @Date;
    END
    ELSE
    BEGIN
        INSERT INTO AttendanceEmployee (EmployeeID, Date, TimeIN, TimeOut, TotalHours, TotalDays, IsLate)
        VALUES (@EmployeeID, @Date, @TimeIN, @TimeOut, @TotalHours, @TotalDays, @IsLate);
    END
END;

CREATE PROCEDURE RequestLeave
    @EmployeeID INT,
    @LeaveType VARCHAR(50),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    DECLARE @LeaveCount INT;
    DECLARE @LeaveStatus VARCHAR(20) = 'Pending';
    DECLARE @IsPaid BIT = 0;

    SELECT @LeaveCount = COUNT(*)
    FROM LeaveRequests
    WHERE EmployeeID = @EmployeeID
      AND YEAR(StartDate) = YEAR(@StartDate)
      AND MONTH(StartDate) = MONTH(@StartDate)
      AND Status = 'Approved';

    IF @LeaveCount >= 5
    BEGIN
        PRINT 'Leave limit for the month reached.';
        RETURN;
    END

    IF @LeaveStatus = 'Approved'
    BEGIN
        SET @IsPaid = 1;
    END

    INSERT INTO LeaveRequests (EmployeeID, LeaveType, StartDate, EndDate, Status)
    VALUES (@EmployeeID, @LeaveType, @StartDate, @EndDate, @LeaveStatus);
END;


CREATE PROCEDURE CalculatePayroll
    @EmployeeID INT = NULL,
    @AdminID INT = NULL
AS
BEGIN
    DECLARE @GrossPay DECIMAL(18, 2);
    DECLARE @SSSDeduction DECIMAL(18, 2) = 0.04;
    DECLARE @PhilHealthDeduction DECIMAL(18, 2) = 0.03;
    DECLARE @PagIbigDeduction DECIMAL(18, 2) = 0.02;
    DECLARE @TotalDeduction DECIMAL(18, 2);
    DECLARE @NetPay DECIMAL(18, 2);
    DECLARE @DaysAttended INT;
    DECLARE @EmployeeSalary DECIMAL(18, 2);
    DECLARE @DailyRate DECIMAL(18, 2);
    DECLARE @AdminSalary DECIMAL(18, 2);
    
    IF @EmployeeID IS NOT NULL
    BEGIN
        SELECT @EmployeeSalary = EmployeeSalary
        FROM Employee
        WHERE EmployeeID = @EmployeeID;

        SELECT @DaysAttended = COUNT(*)
        FROM AttendanceEmployee
        WHERE EmployeeID = @EmployeeID
          AND Date BETWEEN DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) 
                       AND DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 15)
          AND TimeIN IS NOT NULL
          AND TimeOut IS NOT NULL;

        SET @DailyRate = @EmployeeSalary / 22;
        SET @GrossPay = @DaysAttended * @DailyRate;

        SET @SSSDeduction = @GrossPay * @SSSDeduction;
        SET @PhilHealthDeduction = @GrossPay * @PhilHealthDeduction;
        SET @PagIbigDeduction = @GrossPay * @PagIbigDeduction;

        SET @TotalDeduction = @SSSDeduction + @PhilHealthDeduction + @PagIbigDeduction;
        SET @NetPay = @GrossPay - @TotalDeduction;

        INSERT INTO Payroll (EmployeeID, GrossPay, SSSDeduction, PhilHealthDeduction, PagIbigDeduction, TotalDeduction, NetPay)
        VALUES (@EmployeeID, @GrossPay, @SSSDeduction, @PhilHealthDeduction, @PagIbigDeduction, @TotalDeduction, @NetPay);

        SELECT @DaysAttended = COUNT(*)
        FROM AttendanceEmployee
        WHERE EmployeeID = @EmployeeID
          AND Date BETWEEN DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 16) 
                       AND EOMONTH(GETDATE())
          AND TimeIN IS NOT NULL
          AND TimeOut IS NOT NULL;

        SET @GrossPay = @DaysAttended * @DailyRate;

        SET @SSSDeduction = @GrossPay * @SSSDeduction;
        SET @PhilHealthDeduction = @GrossPay * @PhilHealthDeduction;
        SET @PagIbigDeduction = @GrossPay * @PagIbigDeduction;

        SET @TotalDeduction = @SSSDeduction + @PhilHealthDeduction + @PagIbigDeduction;
        SET @NetPay = @GrossPay - @TotalDeduction;

        INSERT INTO Payroll (EmployeeID, GrossPay, SSSDeduction, PhilHealthDeduction, PagIbigDeduction, TotalDeduction, NetPay)
        VALUES (@EmployeeID, @GrossPay, @SSSDeduction, @PhilHealthDeduction, @PagIbigDeduction, @TotalDeduction, @NetPay);
    END

    IF @AdminID IS NOT NULL
    BEGIN
        SELECT @AdminSalary = AdminSalary
        FROM Admin
        WHERE AdminID = @AdminID;

        SELECT @DaysAttended = COUNT(*)
        FROM AttendanceAdmin
        WHERE AdminID = @AdminID
          AND Date BETWEEN DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) 
                       AND DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 15)
          AND TimeIN IS NOT NULL
          AND TimeOut IS NOT NULL;

        SET @DailyRate = @AdminSalary / 22;
        SET @GrossPay = @DaysAttended * @DailyRate;

        SET @SSSDeduction = @GrossPay * @SSSDeduction;
        SET @PhilHealthDeduction = @GrossPay * @PhilHealthDeduction;
        SET @PagIbigDeduction = @GrossPay * @PagIbigDeduction;

        SET @TotalDeduction = @SSSDeduction + @PhilHealthDeduction + @PagIbigDeduction;
        SET @NetPay = @GrossPay - @TotalDeduction;

        INSERT INTO Payroll (AdminID, GrossPay, SSSDeduction, PhilHealthDeduction, PagIbigDeduction, TotalDeduction, NetPay)
        VALUES (@AdminID, @GrossPay, @SSSDeduction, @PhilHealthDeduction, @PagIbigDeduction, @TotalDeduction, @NetPay);

        SELECT @DaysAttended = COUNT(*)
        FROM AttendanceAdmin
        WHERE AdminID = @AdminID
          AND Date BETWEEN DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 16) 
                       AND EOMONTH(GETDATE())
          AND TimeIN IS NOT NULL
          AND TimeOut IS NOT NULL;

        SET @GrossPay = @DaysAttended * @DailyRate;

        SET @SSSDeduction = @GrossPay * @SSSDeduction;
        SET @PhilHealthDeduction = @GrossPay * @PhilHealthDeduction;
        SET @PagIbigDeduction = @GrossPay * @PagIbigDeduction;

        SET @TotalDeduction = @SSSDeduction + @PhilHealthDeduction + @PagIbigDeduction;
        SET @NetPay = @GrossPay - @TotalDeduction;

        INSERT INTO Payroll (AdminID, GrossPay, SSSDeduction, PhilHealthDeduction, PagIbigDeduction, TotalDeduction, NetPay)
        VALUES (@AdminID, @GrossPay, @SSSDeduction, @PhilHealthDeduction, @PagIbigDeduction, @TotalDeduction, @NetPay);
    END
END;

ALTER TABLE AttendanceEmployee
ADD OnTime BIT;
 DROP PROCEDURE CalculatePayroll

 
CREATE PROCEDURE CalculatePayroll
    @EmployeeID INT = NULL,
    @AdminID INT = NULL
AS
BEGIN
    DECLARE @GrossPay DECIMAL(18, 2);
    DECLARE @SSSDeduction DECIMAL(18, 2) = 0.04;
    DECLARE @PhilHealthDeduction DECIMAL(18, 2) = 0.03;
    DECLARE @PagIbigDeduction DECIMAL(18, 2) = 0.02;
    DECLARE @TotalDeduction DECIMAL(18, 2);
    DECLARE @NetPay DECIMAL(18, 2);
    DECLARE @DaysAttended INT;
    DECLARE @DaysOnTime INT;
    DECLARE @EmployeeSalary DECIMAL(18, 2);
    DECLARE @DailyRate DECIMAL(18, 2);
    DECLARE @AdminSalary DECIMAL(18, 2);

    -- Handle employee payroll calculation
    IF @EmployeeID IS NOT NULL
    BEGIN
        SELECT @EmployeeSalary = EmployeeSalary
        FROM Employee
        WHERE EmployeeID = @EmployeeID;

        -- Calculate attendance and on-time days
        SELECT @DaysAttended = COUNT(*), @DaysOnTime = SUM(CASE WHEN OnTime = 1 THEN 1 ELSE 0 END)
        FROM AttendanceEmployee
        WHERE EmployeeID = @EmployeeID
          AND Date BETWEEN DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) 
                       AND DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 15)
          AND TimeIN IS NOT NULL
          AND TimeOut IS NOT NULL;

        -- Calculate daily rate and gross pay
        SET @DailyRate = @EmployeeSalary / 22;
        SET @GrossPay = @DaysAttended * @DailyRate;

        -- Adjust gross pay for "on time" bonus if applicable
        SET @GrossPay = @GrossPay + (@DaysOnTime * @DailyRate * 0.05); -- Example: 5% bonus for on-time days

        -- Calculate deductions
        SET @SSSDeduction = @GrossPay * @SSSDeduction;
        SET @PhilHealthDeduction = @GrossPay * @PhilHealthDeduction;
        SET @PagIbigDeduction = @GrossPay * @PagIbigDeduction;

        SET @TotalDeduction = @SSSDeduction + @PhilHealthDeduction + @PagIbigDeduction;
        SET @NetPay = @GrossPay - @TotalDeduction;

        -- Insert payroll record
        INSERT INTO Payroll (EmployeeID, GrossPay, SSSDeduction, PhilHealthDeduction, PagIbigDeduction, TotalDeduction, NetPay)
        VALUES (@EmployeeID, @GrossPay, @SSSDeduction, @PhilHealthDeduction, @PagIbigDeduction, @TotalDeduction, @NetPay);
    END

    -- Handle admin payroll calculation
    IF @AdminID IS NOT NULL
    BEGIN
        SELECT @AdminSalary = AdminSalary
        FROM Admin
        WHERE AdminID = @AdminID;

        SELECT @DaysAttended = COUNT(*), @DaysOnTime = SUM(CASE WHEN OnTime = 1 THEN 1 ELSE 0 END)
        FROM AttendanceAdmin
        WHERE AdminID = @AdminID
          AND Date BETWEEN DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) 
                       AND DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 15)
          AND TimeIN IS NOT NULL
          AND TimeOut IS NOT NULL;

        SET @DailyRate = @AdminSalary / 22;
        SET @GrossPay = @DaysAttended * @DailyRate;

        SET @GrossPay = @GrossPay + (@DaysOnTime * @DailyRate * 0.05);

        SET @SSSDeduction = @GrossPay * @SSSDeduction;
        SET @PhilHealthDeduction = @GrossPay * @PhilHealthDeduction;
        SET @PagIbigDeduction = @GrossPay * @PagIbigDeduction;

        SET @TotalDeduction = @SSSDeduction + @PhilHealthDeduction + @PagIbigDeduction;
        SET @NetPay = @GrossPay - @TotalDeduction;

        INSERT INTO Payroll (AdminID, GrossPay, SSSDeduction, PhilHealthDeduction, PagIbigDeduction, TotalDeduction, NetPay)
        VALUES (@AdminID, @GrossPay, @SSSDeduction, @PhilHealthDeduction, @PagIbigDeduction, @TotalDeduction, @NetPay);
    END
END;

;

ALTER TABLE AttendanceAdmin
ADD OnTime BIT DEFAULT 0;



