/***************

Job title generator
Author: Tomaz Kastrun
Date: 16.09.2018
Blog: tomaztsql.wordpress.com

****************/


CREATE DATABASE JTG


USE jtg;
GO


DROP TABLE IF EXISTS roles;
GO

CREATE TABLE roles
(id int identity(1,1) NOT NULL
,title VARCHAR(100)
);

INSERT into roles(title)
          SELECT 'Analyst'
UNION ALL SELECT 'Project Manager'
UNION ALL SELECT 'Expert'
UNION ALL SELECT 'Manager'
UNION ALL SELECT 'Person'
UNION ALL SELECT 'Artist'
UNION ALL SELECT 'Tamer'
UNION ALL SELECT 'Developer'
UNION ALL SELECT 'Administrator'
UNION ALL SELECT 'Technologist'
UNION ALL SELECT 'Uploader'
UNION ALL SELECT 'Downloader'
UNION ALL SELECT 'Sherpa'
UNION ALL SELECT 'Philosopher'
UNION ALL SELECT 'Designer'
UNION ALL SELECT 'Legend'
UNION ALL SELECT 'Evangelist'
UNION ALL SELECT 'Hero'
UNION ALL SELECT 'Guru'
UNION ALL SELECT 'Director'
UNION ALL SELECT 'Slayer'
UNION ALL SELECT 'Composer'
UNION ALL SELECT 'Reader'
UNION ALL SELECT 'Outliner'
UNION ALL SELECT 'Proof-reader'
UNION ALL SELECT 'Assistant'
UNION ALL SELECT 'Operator'
UNION ALL SELECT 'Coffee Maker'
UNION ALL SELECT 'Pizza re-heater'
UNION ALL SELECT 'Banana Cutter'
UNION ALL SELECT 'Tester'
UNION ALL SELECT 'Deep tester'
UNION ALL SELECT 'Backward tester'
UNION ALL SELECT 'Office hater'
UNION ALL SELECT 'Hater'
UNION ALL SELECT 'Warrior'
UNION ALL SELECT 'Junkie'
UNION ALL SELECT 'Wizard'
UNION ALL SELECT 'Leader'
UNION ALL SELECT 'King'
UNION ALL SELECT 'Approver'
UNION ALL SELECT 'Engineer'
UNION ALL SELECT 'Architect'
UNION ALL SELECT 'Rockstar'
UNION ALL SELECT 'Ninja'
UNION ALL SELECT 'Python Coder'
UNION ALL SELECT 'R and Python Hater'
UNION ALL SELECT 'C# Lover'
UNION ALL SELECT 'Java evangelist'
UNION ALL SELECT 'Ninja'
UNION ALL SELECT 'Captain'
UNION ALL SELECT 'Strategist'
UNION ALL SELECT 'Consultant'
UNION ALL SELECT 'Organizer'
UNION ALL SELECT 'Coffee spiller'
UNION ALL SELECT 'Endorser'
UNION ALL SELECT 'Cow'
UNION ALL SELECT 'Dog'
UNION ALL SELECT 'Cheever'
UNION ALL SELECT 'Lazy'
UNION ALL SELECT 'Fanboy'
UNION ALL SELECT 'Copy/Paster'
UNION ALL SELECT 'Researcher'
UNION ALL SELECT 'Cloner sheep'
UNION ALL SELECT 'Copy cat'
UNION ALL SELECT 'Shadower'
UNION ALL SELECT 'Guerilla'
UNION ALL SELECT 'Bullshiter'
UNION ALL SELECT 'Updater'
UNION ALL SELECT 'F5key presser'
UNION ALL SELECT 'Helper'
UNION ALL SELECT 'Knows everything'
UNION ALL SELECT 'Coffee Addict'
UNION ALL SELECT 'ASAP Doer'
UNION ALL SELECT 'Complicator'
UNION ALL SELECT 'Helpdesk dispatcher'
UNION ALL SELECT 'His Awesomeness'
UNION ALL SELECT 'Hers Awesomeness'
UNION ALL SELECT 'Advanced Copy/paster'
UNION ALL SELECT 'Stackover subscriber'
UNION ALL SELECT 'Over-engineering'


DROP TABLE IF EXISTS sqlstuff;

CREATE table sqlstuff
(ID INT IDENTITY(1,1) NOT NULL
,title VARCHAR(100)
)

INSERT INTO sqlstuff (title)
          SELECT 'Cardinality Estimator'
UNION ALL SELECT 'Stored Procedure'
UNION ALL SELECT 'Data Masking'
UNION ALL SELECT 'High Availability'
UNION ALL SELECT 'Database Durability'
UNION ALL SELECT 'Memory Optimized table'
UNION ALL SELECT 'User Defined Function'
UNION ALL SELECT 'Stale Statistics'
UNION ALL SELECT 'Azure'
UNION ALL SELECT 'Power BI'
UNION ALL SELECT 'Machine Learning service'
UNION ALL SELECT 'Reporting Service'
UNION ALL SELECT 'Notification Service'
UNION ALL SELECT 'Analysis Service'
UNION ALL SELECT 'Clustered Index'
UNION ALL SELECT 'Database Snapshot'
UNION ALL SELECT 'Query Store'
UNION ALL SELECT 'DBCC Check'
UNION ALL SELECT 'B-Tree'
UNION ALL SELECT 'Query Optimizer'
UNION ALL SELECT 'Linked Server'
UNION ALL SELECT 'Trigger'
UNION ALL SELECT 'Replication'
UNION ALL SELECT 'Resource Governor'
UNION ALL SELECT 'Maintenance Plan'
UNION ALL SELECT 'Server Log'
UNION ALL SELECT 'SQL Server Agent'
UNION ALL SELECT 'Extended Event'
UNION ALL SELECT 'Profiler'
UNION ALL SELECT 'Server Role'
UNION ALL SELECT 'Auditing'
UNION ALL SELECT 'Credentials'
UNION ALL SELECT 'Database Backup'
UNION ALL SELECT 'Extended Properties'
UNION ALL SELECT 'Log Shipping'
UNION ALL SELECT 'Database Mirroring'
UNION ALL SELECT 'Availability Group'
UNION ALL SELECT 'PowerShell'
UNION ALL SELECT 'Parameter Sniffing'
UNION ALL SELECT 'ANSI Default'
UNION ALL SELECT 'Service Broker'
UNION ALL SELECT 'Compatibility Level'
UNION ALL SELECT 'Containment Type'
UNION ALL SELECT 'Recovery Model'
UNION ALL SELECT 'Collation'
UNION ALL SELECT 'Primary Filegroup'
UNION ALL SELECT 'Database Log Backup'
UNION ALL SELECT 'Bulk Insert'
UNION ALL SELECT 'Left Join'
UNION ALL SELECT 'U-SQL'
UNION ALL SELECT 'Azure SQL Server'
UNION ALL SELECT 'MicroContainer'
UNION ALL SELECT 'Pandas Data-frame'
UNION ALL SELECT 'Numpy Array'
UNION ALL SELECT 'Parametrization'
UNION ALL SELECT 'Slow Query'
UNION ALL SELECT 'Long running query'
UNION ALL SELECT 'Nested Query'
UNION ALL SELECT 'R ggplot library'
UNION ALL SELECT 'SARGable Query'
UNION ALL SELECT 'WHERE clause'
UNION ALL SELECT 'WHILE loop'
UNION ALL SELECT 'DELETE statement'
UNION ALL SELECT 'CI/CD'
UNION ALL SELECT 'SQL Server 6.0'
UNION ALL SELECT 'Execution Plan'
UNION ALL SELECT 'String Aggregation'
UNION ALL SELECT 'Dynamic View Management'
UNION ALL SELECT 'User Defined Table'
UNION ALL SELECT 'Fortran OLEDB'
UNION ALL SELECT 'SQL Server 2017'
UNION ALL SELECT 'Cumulative Updates'
UNION ALL SELECT 'Monitoring resources'
UNION ALL SELECT 'Activity Monitor'


DROP TABLE IF EXISTS Fancystuff

CREATE table Fancystuff
(ID INT IDENTITY(1,1) NOT NULL
,title VARCHAR(100)
)


INSERT INTO Fancystuff

		  SELECT 'Regional'
UNION ALL SELECT 'Group'
UNION ALL SELECT 'Only the best'
UNION ALL SELECT 'Insane'
UNION ALL SELECT 'Qualitative'
UNION ALL SELECT 'Virtuous'
UNION ALL SELECT 'Senior'
UNION ALL SELECT 'Junior'
UNION ALL SELECT 'In-House'
UNION ALL SELECT 'Outsourced'
UNION ALL SELECT 'Magnificent'
UNION ALL SELECT 'Evolutionary'
UNION ALL SELECT 'Customer'
UNION ALL SELECT 'Product'
UNION ALL SELECT 'Forward'
UNION ALL SELECT 'Future'
UNION ALL SELECT 'Dynamic'
UNION ALL SELECT 'Corporate'
UNION ALL SELECT 'Legacy'
UNION ALL SELECT 'Investor'
UNION ALL SELECT 'Direct'
UNION ALL SELECT 'International'
UNION ALL SELECT 'Over-seas'
UNION ALL SELECT 'Internal'
UNION ALL SELECT 'Human'
UNION ALL SELECT 'Creative'
UNION ALL SELECT 'Volunteer'
UNION ALL SELECT 'Lead'
UNION ALL SELECT '4 Stages of'
UNION ALL SELECT 'Complete'
UNION ALL SELECT 'Most Advanced'
UNION ALL SELECT 'State of the art'
UNION ALL SELECT 'Super high'
UNION ALL SELECT 'First Class'
UNION ALL SELECT 'Powerful'
UNION ALL SELECT 'Data'
UNION ALL SELECT 'Head of'
UNION ALL SELECT 'Master of'
UNION ALL SELECT 'Chief of'
UNION ALL SELECT 'Officer'
UNION ALL SELECT 'Lead'
UNION ALL SELECT 'Specialist'




----------------------------------
----- Generating T-SQL job title
-----------------------------------

;WITH Fancy
AS
(
SELECT TOP 1
title
FROM
	Fancystuff
ORDER BY NEWID()
),
SQLy AS
(
SELECT TOP 1
title
FROM
	sqlstuff
ORDER BY NEWID()
),
Roley AS
(SELECT TOP 1
title
FROM roles
ORDER BY NEWID()
)

SELECT 
	CONCAT(f.title, ' ', s.title, ' ', r.title) AS TSQLJobGenerator

FROM fancy AS f
CROSS JOIN SQLy AS s
CROSS JOIN Roley AS r
