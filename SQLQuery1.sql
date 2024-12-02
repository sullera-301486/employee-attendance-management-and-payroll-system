--CREATE TABLE Employee(EmployeeId int PRIMARY KEY, Position varchar(50),FirstName varchar(50), LastName varchar(50), Salary decimal(18, 2), Password NVARCHAR(256));
--CREATE TABLE Attendance( AttendanceID int PRIMARY KEY, EmployeeID INT FOREIGN KEY REFERENCES Employee(EmployeeID), TimeIN time, TimeOut time, Status varchar(50));
--CREATE TABLE Payroll(PayrollId decimal(18, 2), EmployeeID INT FOREIGN KEY REFERENCES Employee(EmployeeID), TotalDaysWorked int, GrossPay decimal(18, 2), Deduction decimal(18, 2), TotalPay decimal(18, 2));


/*
CREATE PROCEDURE AddEmployee
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Position VARCHAR(50),
    @Salary DECIMAL(18, 2),
    @Password VARCHAR(50) 
AS
BEGIN
    DECLARE @HashedPassword NVARCHAR(256);

    SET @HashedPassword = CONVERT(NVARCHAR(256), HASHBYTES('SHA2_256', CONVERT(NVARCHAR(50), @Password)), 2);

    INSERT INTO Employee (FirstName, LastName, Position, Salary, Password)
    VALUES (@FirstName, @LastName, @Position, @Salary, @HashedPassword);

    SELECT SCOPE_IDENTITY() AS EmployeeID;
END;
*/

/*
CREATE FUNCTION FullName (@EmployeeID INT) 
RETURNS VARCHAR(50)
AS 
BEGIN
    DECLARE @FullName VARCHAR(50);

    SELECT @FullName = FirstName + ' ' + LastName
    FROM Employee
    WHERE EmployeeID = @EmployeeID;

    RETURN @FullName;
END;
*/
/*
CREATE PROCEDURE PPayroll
    @EmployeeID INT,
    @TotalDaysWorked INT,
    @Deduction DECIMAL(18,2)
AS
BEGIN
    DECLARE @Salary DECIMAL(18,2);
    DECLARE @GrossPay DECIMAL(18,2);
    DECLARE @TotalPay DECIMAL(18,2);

    SELECT @Salary = Salary
    FROM Employee
    WHERE EmployeeID = @EmployeeID;

    SET @GrossPay = (@Salary / 30) * @TotalDaysWorked;

    SET @TotalPay = @GrossPay - @Deduction;

    INSERT INTO Payroll (EmployeeID, TotalDaysWorked, GrossPay, Deduction, TotalPay)
    VALUES (@EmployeeID, @TotalDaysWorked, @GrossPay, @Deduction, @TotalPay);
END;
*/
/*
CREATE PROCEDURE VerifyEmployeeLogin
    @EmployeeID INT,
    @Password VARCHAR(50)
AS
BEGIN
    DECLARE @StoredPassword NVARCHAR(256);
    DECLARE @HashedPassword NVARCHAR(256);

    SELECT @StoredPassword = Password
    FROM Employee
    WHERE EmployeeID = @EmployeeID;

    SET @HashedPassword = CONVERT(NVARCHAR(256), HASHBYTES('SHA2_256', CONVERT(NVARCHAR(50), @Password)), 2);

    IF @HashedPassword = @StoredPassword
    BEGIN

        PRINT 'Login successful.';
    END
    ELSE
    BEGIN

        PRINT 'Invalid password.';
    END
END;
*/

--INSERT INTO Employee (EmployeeId, Position, FirstName, LastName, Salary, Password) VALUES (005, 'CEO', 'FRANZ', 'LOUIES', 50000, 'FRANZ');

