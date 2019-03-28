USE master;
  GO

--CREATE DATABASE

  CREATE DATABASE EmpData4;
  GO

 

  --CREATE TABLE- MASK SENSITIVE DATA WITH DEFAULT FUNCTION

    USE EmpData4;
  GO

  CREATE TABLE EmpInfo(
    EmpID INT PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) MASKED WITH (FUNCTION = 'default()') NOT NULL,
    Birthdate DATE MASKED WITH (FUNCTION = 'default()') NOT NULL,
    CurrentFlag BIT MASKED WITH (FUNCTION = 'default()') NOT NULL,
    SalesLastYear MONEY MASKED WITH (FUNCTION = 'default()') NOT NULL,
    EmailAddress NVARCHAR(50),
    SickLeave INT,
    SalesYTD MONEY,
    NatID NVARCHAR(15),
    PhoneNumber NVARCHAR(25));
  GO

  --INSERT DATA INTO TABLE

  INSERT INTO EmpInfo 
  SELECT e.BusinessEntityID,
    sp.FirstName, sp.LastName,
    e.BirthDate, e.CurrentFlag, sp.SalesLastYear,
    sp.EmailAddress, e.SickLeaveHours, sp.SalesYTD, 
    e.NationalIDNumber, sp.PhoneNumber
  FROM AdventureWorks2017.HumanResources.Employee e
    INNER JOIN AdventureWorks2017.Sales.vSalesPerson sp
    ON e.BusinessEntityID = sp.BusinessEntityID
  WHERE sp.CountryRegionName = 'United States';


  --SELECT DATA WITH PRIV ACCOUNT

  SELECT TOP 5
    EmpID, FirstName, LastName, 
    Birthdate, CurrentFlag, SalesLastYear 
  FROM EmpInfo;


  --CREATE NON PRIV USER

  USE EmpData4;
  GO
  CREATE USER user1 WITHOUT LOGIN;
  GRANT SELECT ON OBJECT::dbo.EmpInfo TO user1;  
  GO

  --SELECT DATA WITH NON-PRIV ACCOUNT

  EXECUTE AS USER = 'user1';
  SELECT TOP 5
    EmpID, FirstName, LastName, 
    Birthdate, CurrentFlag, SalesLastYear 
  FROM EmpInfo;
  REVERT;

  --GIVE USER UNMARSK PERMISSIONS

  Revoke UNMASK TO user1;
  GO

    --SELECT DATA WITH USER ACCOUNT

  EXECUTE AS USER = 'user1';
  SELECT TOP 5
    EmpID, FirstName, LastName, 
    Birthdate, CurrentFlag, SalesLastYear 
  FROM EmpInfo;
  REVERT;


  --TO VERIFY COLUMN MASKS

  SELECT OBJECT_NAME(object_id) TableName, 
    name ColumnName, 
    masking_function MaskFunction
  FROM sys.masked_columns
  ORDER BY TableName, ColumnName;

  --REVOKE USER UNMASK PERMISSION

  REVOKE UNMASK TO user1;  
  GO


  --SPECIAL MASKS

  --EMAIL MASKS

  ALTER TABLE EmpInfo
  ALTER COLUMN EmailAddress NVARCHAR(50)  
      MASKED WITH (FUNCTION = 'email()') NULL;

	--SELECT WITH PRIV ACCOUNT

	SELECT TOP 5 EmpID, EmailAddress 
		FROM EmpInfo;

	--SELECT WITH NON PRIV ACCOUNT

	EXECUTE AS USER = 'user1';
  SELECT TOP 5 EmpID, EmailAddress 
  FROM EmpInfo;
  REVERT;

  --RANDOM MASKS

  ALTER TABLE EmpInfo
  ALTER COLUMN SickLeave INT
      MASKED WITH (FUNCTION = 'random(1, 5)') NOT NULL;

	ALTER TABLE EmpInfo
  ALTER COLUMN SalesYTD MONEY  
      MASKED WITH (FUNCTION = 'random(101, 999)') NOT NULL;

--SELECT WITH PRIV ACCOUNT

	  SELECT TOP 5 EmpID, SickLeave, SalesYTD 
  FROM EmpInfo;


 --SELECT WITH NON PRIV ACCOUNT

 EXECUTE AS USER = 'user1';
  SELECT TOP 5 EmpID, SickLeave, SalesYTD  
  FROM EmpInfo;
  REVERT;


--PARTIAL MASKS

ALTER TABLE EmpInfo
  ALTER COLUMN NatID NVARCHAR(15)
      MASKED WITH (FUNCTION = 'partial(0, "xxxxx", 4)') NOT NULL;

ALTER TABLE EmpInfo
  ALTER COLUMN PhoneNumber NVARCHAR(25) 
      MASKED WITH (FUNCTION = 'partial(4, "xxx-xxxx", 0)') NULL;


--SELECT WITH PRIV ACCOUNT

SELECT TOP 5 EmpID, NatID, PhoneNumber 
  FROM EmpInfo;

--SELECT WITH NON PRIV ACCOUNT

EXECUTE AS USER = 'user1';
  SELECT TOP 5 EmpID, NatID, PhoneNumber  
  FROM EmpInfo;
  REVERT;

  --VERIFY MASKS

  SELECT OBJECT_NAME(object_id) TableName, 
    name ColumnName, 
    masking_function MaskFunction
  FROM sys.masked_columns
  ORDER BY TableName, ColumnName; 

  EXECUTE AS USER = 'user1';
  SELECT TOP 5 *  
  FROM EmpInfo;
  REVERT;

USE master
DROP DATABASE [EmpData4]