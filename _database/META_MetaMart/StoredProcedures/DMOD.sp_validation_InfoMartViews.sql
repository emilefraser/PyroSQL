SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
Validation Procedure of InfoMart Views
*/

CREATE PROCEDURE [DMOD].[sp_validation_InfoMartViews] (
	@InfoMartDBName varchar(100)
	, @ReValidate bit = 0
	, @RevalidateDays int = 1
)
AS


--DECLARE
--	@InfoMartDBName varchar(100)
--	, @ReValidate bit
--	, @RevalidateDays int

--SELECT
--	@InfoMartDBName = 'DEV_InfoMart'
--	, @ReValidate = 0
--	, @RevalidateDays = 1

DECLARE
	@sql nvarchar(max)
	, @ViewsToValidateCount int
	, @ViewToValidateID int
	, @ViewToValidate nvarchar(500)
	, @ValidationStartTime datetime

SET NOCOUNT ON

SET @ValidationStartTime = GetDate()

-- Ensure the Validation Table exists
IF NOT EXISTS (
			SELECT
				1
			FROM
				sys.objects obj
					INNER JOIN sys.schemas sch ON obj.[schema_id] = sch.[schema_id]	
			WHERE
				obj.[type] = 'U'
				AND obj.[name] = 'Validation_InfoMart_Views'
				AND sch.[name] = 'DMOD'
			)
BEGIN
	CREATE TABLE [DMOD].[Validation_InfoMart_Views] (
		  ID int IDENTITY(1,1) NOT NULL
		, InfoMartDatabaseName varchar(500) NOT NULL
		, ViewSchema varchar(500) NOT NULL
		, ViewName varchar(500) NOT NULL
		, ValidationStatus varchar(50) DEFAULT('Not Validated') NOT NULL
		, ValidationMessage varchar(500) NULL
		, LastValidationDate datetime NULL
		)
END


-- Add All Views from selected InfoMart Database to the Validation Table not yet added
SELECT
	@sql = N'INSERT INTO [DMOD].[Validation_InfoMart_Views] (InfoMartDatabaseName, ViewSchema, ViewName) '
	+ N'SELECT ''' + @InfoMartDBName + N''' AS InfoMartDatabaseName, s.[name] AS ViewSchema, v.[name] AS ViewName '
	+ N'FROM [' + @InfoMartDBName + N'].[sys].[views] v INNER JOIN [sys].[schemas] s ON v.[schema_id] = s.[schema_id] '
	+ N'WHERE ''' + @InfoMartDBName + N''' + s.[name] + v.[name] NOT IN (SELECT InfoMartDatabaseName + ViewSchema + ViewName FROM [DMOD].[Validation_InfoMart_Views])'

EXECUTE sp_ExecuteSQL @sql

-- If ReValidate is set mark all views as Not Validated
IF @ReValidate = 1
BEGIN

	SELECT
		@sql = N'UPDATE [DMOD].[Validation_InfoMart_Views] '
		+ N'SET ValidationStatus = ''Not Validated'' '
		+ N'WHERE InfoMartDatabaseName = ''' + @InfoMartDBName + N''''

	EXECUTE sp_ExecuteSQL @sql

END

-- Mark views as Not Validated if they have not been validated in @ReValidateDays
SELECT
	@sql = N'UPDATE [DMOD].[Validation_InfoMart_Views] '
	+ N'SET ValidationStatus = ''Not Validated'' '
	+ N'WHERE InfoMartDatabaseName = ''' + @InfoMartDBName + N''' '
	+ N'AND DATEDIFF(DAY, LastValidationDate, GetDate()) > ' + CONVERT(nvarchar(20), @RevalidateDays)

EXECUTE sp_ExecuteSQL @sql

DROP TABLE IF EXISTS #ViewIDs
CREATE TABLE #ViewIDs (RowNo int identity(1,1), ID int)
INSERT INTO #ViewIDs (ID) SELECT ID FROM [DMOD].[Validation_InfoMart_Views] WHERE ValidationStatus <> 'Validation Succeeded' AND InfoMartDatabaseName = @InfoMartDBName AND (LastValidationDate < @ValidationStartTime OR LastValidationDate is null)

-- Get Count of Views to Validate
SELECT @ViewsToValidateCount = COUNT(1) FROM #ViewIDs
--SELECT @ViewsToValidateCount
PRINT 'Views to Validate ' + CONVERT(varchar(100), @ViewsToValidateCount)

SET @ViewToValidateID = 0

--Validate The Views
WHILE @ViewToValidateID < @ViewsToValidateCount
BEGIN
	
	--Select ID of View to Validate
	SET @ViewToValidateID = @ViewToValidateID + 1
	--PRINT 'View ID ' + @ViewToValidateID

	--Build View Name to Validate
	SELECT @ViewToValidate = N'[' + InfoMartDatabaseName + N'].[' + ViewSchema + N'].[' + ViewName + N']' FROM [DMOD].[Validation_InfoMart_Views] WHERE ID = (SELECT ID FROM #ViewIDs WHERE RowNo = @ViewToValidateID)
	PRINT 'View to Validate: ' + @ViewToValidate

	--Build SQL to Run as Validation
	SET @sql = N'SET NOEXEC ON SELECT TOP 1 1 FROM ' + @ViewToValidate +N' SET NOEXEC OFF'
	PRINT '' + @sql

	--Test the View
	BEGIN TRY
		
		EXECUTE sp_ExecuteSQL @sql
		
		--Update view as validated
		UPDATE [DMOD].[Validation_InfoMart_Views] SET ValidationStatus = 'Validation Succeeded', ValidationMessage = NULL, LastValidationDate = GetDate() WHERE ID = @ViewToValidateID

	END TRY
	
	--Catch views not valid
	BEGIN CATCH
		
		--Update the view as Invalid
		UPDATE [DMOD].[Validation_InfoMart_Views] SET ValidationStatus = 'Validation Failed', ValidationMessage = ERROR_MESSAGE(), LastValidationDate = GetDate() WHERE ID = @ViewToValidateID 
		
	END CATCH

	--Update the count of views to validate
	--SET @ViewsToValidateCount = 0
	--SELECT @ViewsToValidateCount = COUNT(1) FROM [DMOD].[Validation_InfoMart_Views] WHERE ValidationStatus <> 'Validation Succeeded' AND InfoMartDatabaseName = @InfoMartDBName AND (LastValidationDate < @ValidationStartTime OR LastValidationDate is null)

END

SET NOCOUNT OFF




--SELECT * FROM [DMOD].[Validation_InfoMart_Views]
--SELECT TOP 1 1 FROM dev_InfoMart.dbo.vw_DimColourStatus
--SET NOEXEC ON SELECT TOP 1 1 FROM [InfoMart].[dbo].[vw_DimContainer] SET NOEXEC OFF
SELECT TOP 1 1 FROM [InfoMart].[dbo].[vw_DimContainer]

GO
