SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author: RJ Oosthuizen
-- Create Date: 13/05/2019
-- Description: Checks if the selected combination of SourceDataEntityID and TargetDatabase already exists
-- =============================================
CREATE PROCEDURE [APP].[sp_Validate_Dup_ODS_Load]
(
	@SourceDataEntityID INT, --selected from source table
	@TargetServerName VARCHAR(MAX), --selected from target table
	@TargetDatabaseInstanceName VARCHAR(MAX), --selected from target table
	@TargetDatabaseName VARCHAR(MAX) --selected from target table

)
AS
BEGIN

--declare temp table in case multiple records are found(there should be none in anyway, but just as a precaution)
--gets the loadconfig details already in existance(if there are any)
DECLARE @TempTable TABLE
(
LoadConfigID INT, 
SourceDataEntityName VARCHAR(MAX),
TargetServerName VARCHAR(MAX),
TargetDatabaseInstanceName VARCHAR(MAX),
TargetDatabaseName VARCHAR(MAX),
TargetDataEntityName VARCHAR(MAX)
)
--get details where source dataentity id exists in loadconfig table
INSERT INTO @TempTable(LoadConfigID, SourceDataEntityName, TargetServerName, TargetDatabaseInstanceName, TargetDataBaseName, TargetDataEntityName)
(SELECT LoadConfigID, SourceDataEntityName, TargetServerName, TargetDatabaseInstanceName, TargetDatabaseName, TargetDataEntityName
FROM ETL.[vw_mat_ODSLoadConfigDetails] 
WHERE SourceDataEntityID  = @SourceDataEntityID)

--for testing
--select * from @TempTable

--declare to store response
DECLARE @Response varchar(100)


--see if combination of selected target details exists for the current load config's found
IF ((SELECT count(*) FROM @TempTable WHERE @TargetServerName = TargetServerName) > 0)
AND ((SELECT count(*) FROM @TempTable WHERE @TargetDatabaseInstanceName = TargetDatabaseInstanceName) > 0)
AND ((SELECT count(*) FROM @TempTable WHERE @TargetDatabaseName = TargetDatabaseName) > 0) 
--if they exist then we return this message(else the user can continue)
	BEGIN
		--SELECT 'This combination of source and target selections already exist.'
		SET @Response = 'This combination of source and target selections already exist.'
		SELECT @Response
	END
ELSE
	BEGIN
		--SELECT ''
		SET @Response = ''
		SELECT @Response
	END

END

GO
