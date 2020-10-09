SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Emile Fraser
-- Create date: 2019-07-19
-- Description:	Insert a log entry into the ETL.ExecutionLog_StoredProcedures table
-- =============================================
CREATE PROCEDURE [ETL].[sp_get_ExecutionLogID] 
(
			  @DatabaseName  VARCHAR(100)
			, @SchemaName  VARCHAR(100)
			, @LoadConfigID INT
			, @DataEntityName VARCHAR(100)
)
AS
 
BEGIN

		SELECT MAX(ExecutionLogID) AS ExecutionLogID
			FROM [ETL].[ExecutionLog]
			WHERE DatabaseName = @DatabaseName
			AND SchemaName = @SchemaName
			AND LoadConfigID = @LoadConfigID
			AND DataEntityName = @DataEntityName

END

GO
