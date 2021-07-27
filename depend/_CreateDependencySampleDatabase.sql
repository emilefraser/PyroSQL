USE master
GO

USE PyroMasterDB
GO

DROP TABLE IF EXISTS meta.TestReferenceInMeta
GO

CREATE TABLE meta.TestReferenceInMeta (
	TestId INT IDENTITY(1,1) PRIMARY KEY NOT NULL
,	TestName VARCHAR(50)
,	TestType VARCHAR(50)
,	IsCrossSchema BIT
,	IsCrossDatabase BIT
,	IsCrossServer BIT
,	TestDefinition NVARCHAR(MAX)
)
GO





DROP DATABASE IF EXISTS ReferenceDB1
GO
DROP DATABASE IF EXISTS ReferenceDB2
GO

CREATE DATABASE ReferenceDB1
GO

CREATE DATABASE ReferenceDB2
GO

-- START BY CREATING A COUPLE OF TABLES



CREATE TABLE dbo.tableA (ID INT PRIMARY KEY)
GO
CREATE TABLE dbo.tableB (ID INT PRIMARY KEY, ParentID INT)
GO
ALTER TABLE dbo.tableB ADD FOREIGN KEY (ParentID) REFERENCES dbo.tableA(ID)
GO




DROP TABLE dbo.tableA
USE ReferenceTest;
GO

DROP TABLE IF EXISTS dbo.BaseTable 
GO

CREATE TABLE dbo.BaseTable (
	BaseTableId INT PRIMARY KEY IDENTITY(1,1) NOT NULL
,	ValueOfBaseTableId INT NULL
)
GO


DROP TABLE IF EXISTS dbo.ReferencedTable 
GO


CREATE TABLE dbo.ReferencedTable (
	ReferencedTableId INT PRIMARY KEY IDENTITY(1,1) NOT NULL
,	ValueOfReferenceTableId INT NULL
)
GO

CREATE SCHEMA crschema
GO


DROP TABLE IF EXISTS crschema.ReferencedTableCross
GO


CREATE TABLE crschema.ReferencedTableCross (
	ReferencedTableCrossId INT PRIMARY KEY IDENTITY(1,1) NOT NULL
,	ValueOfReferenceTableCrossId INT NULL
)
GO

ALTER TABLE dbo.ReferencedTable
ADD CONSTRAINT FK_ReferencedTable_BaseTable
FOREIGN KEY (ValueOfReferenceTableId) 
REFERENCES dbo.BaseTable(BaseTableId);
GO

ALTER TABLE dbo.ReferencedTable
ADD CONSTRAINT FK_ReferencedTableCross_BaseTable
FOREIGN KEY (ValueOfReferenceTableCrossId) 
REFERENCES crschema.ReferencedTableCross(BaseTableId);
GO

DROP VIEW IF EXISTS dbo.vw_BaseTable 
GO

CREATE VIEW dbo.vw_BaseTable 
AS
SELECT * FROM dbo.BaseTable 
GO

DROP VIEW IF EXISTS dbo.vw_BaseTable_ReferencedTable
GO
CREATE VIEW dbo.vw_BaseTable_ReferencedTable
AS
SELECT
	*
FROM
	dbo.BaseTable AS bt
INNER JOIN
	dbo.ReferencedTable  AS rt
	ON rt.ValueOfReferenceTableId = bt.BaseTableId
GO

CREATE VIEW dbo.vw_BaseTable_ReferencedTable
AS
SELECT
	*
FROM
	dbo.BaseTable AS bt
INNER JOIN
	crschema.ReferencedTableCross AS cc
	ON cc.ValueOfReferenceTableCrossId = bt.BaseTableId
GO

DROP FUNCTION IF EXISTS dbo.fn_GetBaseTable
GO

CREATE FUNCTION dbo.fn_GetBaseTable
RETURNS INT
AS 
	RETURN ValueOfBaseTableId FROM dbo.BaseTable
GO

DROP FUNCTION IF EXISTS dbo.tvf_GetBaseTable
GO

CREATE FUNCTION dbo.tvf_GetBaseTable
RETURNS TABLE
AS
 
	SELECT * FROM dbo.BaseTable
GO


DROP PROCEDURE IF EXISTS dbo.sp_SetBaseTableValue
GO

CREATE PROCEDURE dbo.sp_SetBaseTableValue
AS

	INSERT INTO dbo.BaseTable
	SELECT 100
GO


DROP PROCEDURE IF EXISTS dbo.sp_CreateAndSetAndGetNewTableValue
GO
CREATE PROCEDURE dbo.sp_CreateAndSetAndGetNewTableValue
BEGIN
AS

DROP TABLE IF EXISTS dbo.NewTable

CREATE TABLE dbo.NewTable (
	NewTableId INT PRIMARY KEY IDENTITY(1,1) NOT NULL
,	ValueOfNewTableId INT NULL
)

INSERT INTO
	dbo.NewTable
	VALUES( 100)


SELECT * FROM  dbo.NewTable
END
GO