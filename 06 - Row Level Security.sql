-- Use TutorialDB
-- GO

CREATE TABLE dbo.Orders
(
SupplierID INT,
Name VARCHAR(10),
Orderdate DATETIME,
OrderQuantity INT,
ProcessedBy VARCHAR(10)
)           
 
 -- Sample data
INSERT INTO dbo.orders VALUES(101,'ABC Inc','2018-08-11',1789,'BILL')
INSERT INTO dbo.orders VALUES(102,'XYZ Inc','2015-01-08',767,'BILL')
INSERT INTO dbo.orders VALUES(103,'BFG Inc','2018-08-19',500,'BEN')
INSERT INTO dbo.orders VALUES(102,'BFG Inc','2016-08-19',1099,'SUE')
INSERT INTO dbo.orders VALUES(101,'AXP Inc','2017-08-04',654,'BEN')
INSERT INTO dbo.orders VALUES(103,'BFG Inc','2017-08-10',498,'SUE')
INSERT INTO dbo.orders VALUES(102,'XYZ Inc','2016-04-17',999,'BILL')
INSERT INTO dbo.orders VALUES(101,'ABC Inc','2017-08-21',543,'BILL')
INSERT INTO dbo.orders VALUES(103,'BFG Inc','2017-08-06',876,'BEN')
INSERT INTO dbo.orders VALUES(102,'XYZ Inc','2017-08-26',665,'BOB')
GO

SELECT * FROM DBO.Orders
GO

CREATE FUNCTION dbo.fn_securitypredicateOrder (@processedby sysname)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_securityPredicateOrder_result
FROM 
dbo.orders
WHERE @processedby = user_name()  -- it will be Filter applied while running the query
GO

CREATE SECURITY POLICY dbo.fn_security
ADD FILTER PREDICATE
dbo.fn_securitypredicateOrder(processedby)
ON dbo.orders
GO

CREATE USER BILL without login
CREATE USER BEN without Login
CREATE USER SUE without Login
GRANT SELECT ON dbo.Orders to BILL
GRANT SELECT ON dbo.Orders to BEN 
GRANT SELECT ON dbo.Orders to SUE

GRANT SHOWPLAN TO BILL 
GRANT SHOWPLAN TO BEN 
GRANT SHOWPLAN TO SUE 
--execute ('select * from dbo.orders') as user = 'BOB'

-- EXECUTE AS USER = 'BOB'
-- SELECT * FROM dbo.Orders

EXECUTE AS USER = 'BILL'
SELECT * FROM dbo.Orders
REVERT

EXECUTE AS USER = 'BEN'
SELECT * FROM dbo.Orders
REVERT

EXECUTE AS USER = 'SUE'
SELECT * FROM dbo.Orders
REVERT

--examine Execution plan :Select * from dbo.orders where processedby=user_name()
--User_name is the Security Context of the User executing the query

--without RLS, just get table scan, with RLS its a join to the predicate function.

--Modify RLS

--Disable Security policy
ALTER SECURITY POLICY dbo.fn_security WITH (STATE = OFF)

--Remove Security policy
DROP SECURITY POLICY dbo.fn_security
DROP FUNCTION dbo.fn_securitypredicateOrder 

--More complex example predicate function, restrict to user and order processed in last year.
GO
CREATE FUNCTION dbo.fn_securitypredicateOrder (@processedby SYSNAME, @Orderdate DATETIME)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_securityPredicateOrder_result
FROM 
dbo.orders
WHERE @processedby= USER_NAME()
AND @orderdate >= GETDATE()-365
GO

CREATE SECURITY POLICY dbo.fn_security
ADD FILTER PREDICATE
dbo.fn_securitypredicateOrder(processedby,Orderdate)
ON dbo.orders


--BILL has 1 order(s) within the last year.
EXECUTE AS USER = 'BILL'
SELECT * FROM dbo.Orders
REVERT


DROP TABLE dbo.Orders
-- Complete list of security recommendations.
-- https://www.mssqltips.com/sql-server-tip-category/19/security/
 



 




