SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[InsertJsonToSqlFromLocalFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[InsertJsonToSqlFromLocalFile] AS' 
END
GO

/*
	Written by: Emile Frser
	Date: 2020-10-01
	Description: Inserts json to column/variable from local file 
*/


ALTER PROCEDURE [inout].[InsertJsonToSqlFromLocalFile]
AS
BEGIN

DECLARE @json NVARCHAR(MAX)
-- Load file contents into a variable
SELECT @json = BulkColumn
 FROM OPENROWSET (BULK 'C:\JSON\Books\book.json', SINGLE_CLOB) as j

-- Load file contents into a table 
SELECT BulkColumn
 INTO #temp 
 FROM OPENROWSET (BULK 'C:\JSON\Books\book.json', SINGLE_CLOB) as j

 END
GO
