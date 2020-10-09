SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Emile Fraser
-- Create date: 2019-07-19
-- Description:	Insert a log entry into the ETL.ExecutionLog_StoredProcedures table
-- =============================================
CREATE FUNCTION [ETL].[udf_get_ExecutionLogID] 
(
			  @DatabaseName  VARCHAR(100)
			, @SchemaName  VARCHAR(100)
			, @LoadConfigID INT
			, @DataEntityName VARCHAR(100)
)
RETURNS INT
AS
 
BEGIN

		DECLARE @ExecutionLogID_Latest INT = 
		(
			SELECT MAX(ExecutionLogID) AS ExecutionLogID
			FROM [ETL].[ExecutionLog]
			WHERE DatabaseName = @DatabaseName
			AND SchemaName = @SchemaName
			AND LoadConfigID = @LoadConfigID
			AND DataEntityName = @DataEntityName
		)

	RETURN @ExecutionLogID_Latest

END


GO
