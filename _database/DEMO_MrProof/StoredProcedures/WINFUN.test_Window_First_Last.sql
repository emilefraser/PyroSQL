SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
	EXEC WINFUN.test_Window_First_Last

	Terminology:
	ROWS or RANGE- specifying rows or range.
	PRECEDING – get rows before the current one.
	FOLLOWING – get rows after the current one.
	UNBOUNDED – when used with PRECEDING or FOLLOWING, it returns all before or after.
	CURRENT ROW

*/
CREATE   PROCEDURE WINFUN.test_Window_First_Last
AS
BEGIN

-- CREATE SCHEMA WINFUN

DROP TABLE IF EXISTS [WINFUN].[Window_First_Last]

CREATE TABLE [WINFUN].[Window_First_Last](
 [id] [int] IDENTITY(1,1) NOT NULL,
 [Department] [nchar](10) NOT NULL,
 [DateUpdate] DATE NOT NULL,
 [Code] [int] NOT NULL,
 CONSTRAINT [PK_Window_First_Last] PRIMARY KEY CLUSTERED 
(
 [id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

--Insert some test data
insert into WINFUN.[Window_First_Last] values('A','2010-07-11',111)
insert into WINFUN.[Window_First_Last] values('B','2020-01-01',29)
insert into WINFUN.[Window_First_Last] values('C','2028-04-21',258)
insert into WINFUN.[Window_First_Last] values('D','2019-05-01',999)
insert into WINFUN.[Window_First_Last] values('E','2020-01-16',15)
insert into WINFUN.[Window_First_Last] values('F','2020-11-21',449)
insert into WINFUN.[Window_First_Last] values('G','2020-10-25',419)
insert into WINFUN.[Window_First_Last] values('H','2020-03-09',555)
insert into WINFUN.[Window_First_Last] values('A','2010-07-12',524)
insert into WINFUN.[Window_First_Last] values('B','2020-03-30',698)
insert into WINFUN.[Window_First_Last] values('D','2020-02-22',269)
insert into WINFUN.[Window_First_Last] values('E','2020-04-01',259)
insert into WINFUN.[Window_First_Last] values('A','2020-01-01',139)
insert into WINFUN.[Window_First_Last] values('A','2019-03-28',219)
insert into WINFUN.[Window_First_Last] values('B','2020-12-05',869)

SELECT * FROM WINFUN.[Window_First_Last] 


-- In the above example FIRST_VALUE is the same and equal to the value in the first row 
--(i.e. 15) for the entire result set. While the LAST_VALUE changes for each record and is equal to the last value that was pulled (i.e. current value in the result set). 
SELECT id,department,code,
FIRST_VALUE(code) OVER (ORDER BY code) FstValue,
LAST_VALUE(code) OVER (ORDER BY code) LstValue
FROM WINFUN.[Window_First_Last] 

-- Same records for last
SELECT id,department,code,
FIRST_VALUE(code) OVER (ORDER BY code) FstValue,
LAST_VALUE(code) OVER (ORDER BY code ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) LstValue
FROM WINFUN.[Window_First_Last]


-- Partitioned
SELECT id,department,code,
FIRST_VALUE(code)  OVER (PARTITION BY department ORDER BY code) FstValue,
LAST_VALUE(code) OVER (PARTITION BY department ORDER BY code ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) LstValue
FROM WINFUN.[Window_First_Last]

-- Partitioned
SELECT id,department,code,
FIRST_VALUE(code)  OVER (PARTITION BY department ORDER BY code ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) FstValue,
LAST_VALUE(code) OVER (PARTITION BY department ORDER BY code ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) LstValue
FROM WINFUN.[Window_First_Last]
ORDER BY id

-- Partitioned
SELECT id,department,code,
FIRST_VALUE(code)  OVER (PARTITION BY department ORDER BY code) FstValue,
LAST_VALUE(code) OVER (PARTITION BY department ORDER BY code ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) LstValue
FROM WINFUN.[Window_First_Last]
ORDER BY id

-- Partitioned
SELECT id,department,code,[DateUpdate],
FIRST_VALUE(code)  OVER (PARTITION BY department ORDER BY [DateUpdate]) FstValue,
LAST_VALUE(code) OVER (PARTITION BY department ORDER BY [DateUpdate] ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) LstValue
FROM WINFUN.[Window_First_Last]


/*
use tempdb;

DROP TABLE IF EXISTS #Employee;

CREATE TABLE #Employee
(
    Id      INT
   ,Salary  INT
);

INSERT INTO #Employee
VALUES  (1, 200),
        (2, 100),
        (3, 300),
        (4, 500),
        (5, 400);

SELECT * FROM #Employee;

SELECT Id, Salary, FIRST_VALUE(Salary) OVER(ORDER BY Salary) as FirstValue
FROM   #Employee;

AST_VALUE – Without Partition By
Following example displays the last value from an ordered set of values. Make a note of using LAST_VALUE function without window frame produces an incorrect result because when we’ve not specified any window frame then it uses default RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW which only goes up to current row hence giving the incorrect row value which results in incorrect values.

Specifying the correct window frame ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING produces a correct result by taking all the rows into consideration before producing the last value.

use tempdb;

DROP TABLE IF EXISTS #Employee;

CREATE TABLE #Employee
(
    Id      INT
   ,Salary  INT
);

INSERT INTO #Employee
VALUES  (1, 200),
        (2, 100),
        (3, 300),
        (4, 500),
        (5, 400);

SELECT * FROM #Employee;

--Produces wrong output because default framing giving the wrong order 
SELECT Id, Salary, LAST_VALUE(Salary) OVER(ORDER BY Salary) as LastValue
FROM   #Employee;

--Produces correct output when correct window frame is applied
SELECT Id, Salary, LAST_VALUE(Salary) OVER(ORDER BY Salary 
					   ROWS BETWEEN UNBOUNDED PRECEDING 
                                           AND UNBOUNDED FOLLOWING) as LastValue
FROM   #Employee;



FIRST_VALUE and PARTITION BY
Running following example, we can observe that result of the query was partitioned by dept name column thus creating two logical windows of IT dept and HR dept. When we have two different windows then FIRST_VALUE function is applied to each partition to fetch first value from the ordered set using salary column in ascending order.

--First Value and Partition By
use tempdb;

DROP TABLE IF EXISTS #Employee;

CREATE TABLE #Employee
(
    Id      INT
   ,DeptName  VARCHAR(25)
   ,Salary  INT
);

INSERT INTO #Employee
VALUES  (1, 'IT', 200),
        (2, 'IT', 100),
        (3, 'IT', 300),
        (4, 'HR', 500),
        (5, 'HR', 400);

SELECT * FROM #Employee;

SELECT Id, DeptName, Salary, FIRST_VALUE(Salary) OVER(PARTITION BY DeptName ORDER BY Salary) as FirstValue
FROM   #Employee
ORDER BY Salary, Id;


Here is an example using PARTITION BY with LAST_VALUE function. Similar to the above example; the result of query divided into two partitions of I.T dept and HR dept and applying LAST_VALUE function to each partition to fetch last value from an ordered set of values.

We have used ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING window frame to make sure LAST_VALUE function considers rows between first row in partition to last row in partition.

use tempdb;

DROP TABLE IF EXISTS #Employee;

CREATE TABLE #Employee
(
    Id      INT
   ,DeptName  VARCHAR(25)
   ,Salary  INT
);

INSERT INTO #Employee
VALUES  (1, 'IT', 200),
        (2, 'IT', 100),
        (3, 'IT', 300),
        (4, 'HR', 500),
        (5, 'HR', 400);

SELECT * FROM #Employee;

SELECT Id, DeptName, Salary, LAST_VALUE(Salary) OVER(PARTITION BY DeptName 
                                                     ORDER BY Salary
                                                     ROWS BETWEEN UNBOUNDED PRECEDING
                                                     AND UNBOUNDED FOLLOWING) as LastValue
FROM   #Employee
ORDER BY Salary, Id;

CREATE TABLE REVENUE
(
[DepartmentID] int,
[Revenue] int,
[Year] int
);
 
insert into REVENUE
values (1,10030,1998),(2,20000,1998),(3,40000,1998),
 (1,20000,1999),(2,60000,1999),(3,50000,1999),
 (1,40000,2000),(2,40000,2000),(3,60000,2000),
 (1,30000,2001),(2,30000,2001),(3,70000,2001),
 (1,90000,2002),(2,20000,2002),(3,80000,2002),
 (1,10300,2003),(2,1000,2003), (3,90000,2003),
 (1,10000,2004),(2,10000,2004),(3,10000,2004),
 (1,20000,2005),(2,20000,2005),(3,20000,2005),
 (1,40000,2006),(2,30000,2006),(3,30000,2006),
 (1,70000,2007),(2,40000,2007),(3,40000,2007),
 (1,50000,2008),(2,50000,2008),(3,50000,2008),
 (1,20000,2009),(2,60000,2009),(3,60000,2009),
 (1,30000,2010),(2,70000,2010),(3,70000,2010),
 (1,80000,2011),(2,80000,2011),(3,80000,2011),
 (1,10000,2012),(2,90000,2012),(3,90000,2012);


 USE [tsql2012];
 
-- first lets look at the REVENUE table
 
SELECT *
 FROM Revenue;

 -- first simple sum and avg aggregates
SELECT sum(Revenue) as TotalRevenue,
 avg(Revenue) as AverageRevenue,
 count(*) as NumRows
 FROM Revenue;

 --First OVER Clause pre SQL 2012
SELECT *,
 avg(Revenue) OVER (PARTITION by DepartmentID) as AverageDeptRevenue,
 sum(Revenue) OVER (PARTITION by DepartmentID) as TotalDeptRevenue
FROM REVENUE
ORDER BY departmentID, year;


--ROWS PRECEDING
-- look at the sum of revenue over a trailing 3 year period
SELECT Year, DepartmentID, Revenue,
 sum(Revenue) OVER (PARTITION by DepartmentID
 ORDER BY [YEAR]
 ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as CurrentAndPrev3
FROM REVENUE
ORDER BY departmentID, year;


-- ROWS FOLLOWING
SELECT Year, DepartmentID, Revenue,
 sum(Revenue) OVER (PARTITION by DepartmentID
 ORDER BY [YEAR]
 ROWS BETWEEN CURRENT ROW AND 3 FOLLOWING) as CurrentAndNext3
FROM REVENUE
ORDER BY department--ROWS PRECEDING AND FOLLOWING
 
SELECT Year, DepartmentID, Revenue,
 sum(Revenue) OVER (PARTITION by DepartmentID
 ORDER BY [YEAR]
 ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as BeforeAndAfter
FROM REVENUE
ORDER BY departmentID, year;ID, year;


-- ROWS UNBOUNDED PRECEDING
SELECT Year, DepartmentID, Revenue,
 min(Revenue) OVER (PARTITION by DepartmentID
 ORDER BY [YEAR]
 ROWS UNBOUNDED PRECEDING) as MinRevenueToDate
FROM REVENUE
ORDER BY departmentID, year;

-- ROWS UNBOUNDED FOLLOWING
-- http://stevestedman.com/?p=1485
SELECT Year, DepartmentID, Revenue,
 min(Revenue) OVER (PARTITION by DepartmentID
 ORDER BY [YEAR]
 ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as MinRevenueBeyond
FROM REVENUE
ORDER BY departmentID, year;

-- ROWS vs RANGE UNBOUNDED PRECEDING
 
SELECT Year, DepartmentID, Revenue,
 sum(Revenue) OVER (PARTITION by DepartmentID
 ORDER BY [YEAR]
 ROWS UNBOUNDED PRECEDING) as RowsCumulative,
 sum(Revenue) OVER (PARTITION by DepartmentID
 ORDER BY [YEAR]
 RANGE UNBOUNDED PRECEDING) as RangeCumulative
FROM REVENUE
WHERE year between 2003 and 2008
ORDER BY departmentID, year;


-- INSERT A DUPLICATE VALUE FOR RANGE UNBOUNDED PRECEEDING
 
INSERT INTO REVENUE
VALUES (1,10000,2005),(2,20000,2005),(3,30000,2005);
 
-- same query as above
SELECT Year, DepartmentID, Revenue,
 sum(Revenue) OVER (PARTITION by DepartmentID
 ORDER BY [YEAR]
 ROWS UNBOUNDED PRECEDING) as RowsCumulative,
 sum(Revenue) OVER (PARTITION by DepartmentID
 ORDER BY [YEAR]
 RANGE UNBOUNDED PRECEDING) as RangeCumulative
FROM REVENUE
WHERE year between 2003 and 2008
ORDER BY departmentID, year;

-- INSERT A DUPLICATE VALUE FOR RANGE UNBOUNDED PRECEEDING
 
INSERT INTO REVENUE
VALUES (1,10000,2005),(2,20000,2005),(3,30000,2005);
 
-- same query as above
SELECT Year, DepartmentID, Revenue,
 sum(Revenue) OVER (PARTITION by DepartmentID
 ORDER BY [YEAR]
 ROWS UNBOUNDED PRECEDING) as RowsCumulative,
 sum(Revenue) OVER (PARTITION by DepartmentID
 ORDER BY [YEAR]
 RANGE UNBOUNDED PRECEDING) as RangeCumulative
FROM REVENUE
WHERE year between 2003 and 2008
ORDER BY departmentID, year;

*/

END
GO
