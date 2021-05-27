SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[SetQueryDefine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [benchmark].[SetQueryDefine] AS' 
END
GO


ALTER PROCEDURE [benchmark].[SetQueryDefine]
    @QueryDefineCode		SYSNAME			= NULL
,	@QueryDefineName		NVARCHAR(300)	= NULL
,	@QueryDefinition		NVARCHAR(MAX)
AS
BEGIN
	
	DECLARE @QueryDefineId INT
	SET @QueryDefineId = (SELECT QueryDefineId FROM benchmark.QueryDefine WHERE QueryDefineCode = @QueryDefineCode)

	-- INSERT
	IF(@QueryDefineId IS NULL)
	BEGIN
		INSERT INTO benchmark.QueryDefine (QueryDefineCode, QueryDefineName, QueryDefinition)
		VALUES (@QueryDefineCode, @QueryDefineName, @QueryDefinition)

	END
	ELSE
	BEGIN
		IF (@QueryDefinition IS NULL)
		BEGIN
			-- DELETE
			DELETE FROM benchmark.QueryDefine 
			WHERE QueryDefineId = @QueryDefineId

		END
		ELSE
		BEGIN
			-- UPDATE
			UPDATE benchmark.QueryDefine 
			SET 
				QueryDefineName = COALESCE(@QueryDefineName, QueryDefineName)
			,	QueryDefinition = @QueryDefinition
			WHERE 
				QueryDefineId = @QueryDefineId

		END

	END





END
GO
