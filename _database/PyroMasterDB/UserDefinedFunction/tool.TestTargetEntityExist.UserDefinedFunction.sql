SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[TestTargetEntityExist]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE   FUNCTION [tool].[TestTargetEntityExist] (
	@TargetDatabaseName			SYSNAME = NULL
,	@TargetSchemaName			SYSNAME = ''dbo''
,	@TargetEntityName			SYSNAME = NULL
,	@TargetEnvironmentName		SYSNAME = ''''
)
RETURNS BIT
AS
BEGIN
	IF(@TargetDatabaseName IS NULL)
	BEGIN
		IF EXISTS (
			SELECT 
				1
			FROM 
				balance.GetSchemaRowCountFromPartition(@TargetSchemaName, NULL)
			WHERE
				DatabaseName = DB_NAME()
			AND
				TableName = @TargetEntityName + IIF(@TargetEnvironmentName = '''', '''', ''_'' + @TargetEnvironmentName)
		)
		BEGIN
			RETURN 1
		END
		ELSE
		BEGIN
			RETURN 0
		END
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT 
					1
				FROM 
					balance.GetSchemaRowCountFromPartition(@TargetSchemaName, NULL)
				WHERE
					DatabaseName = @TargetDatabaseName
				AND
					TableName = @TargetEntityName + IIF(@TargetEnvironmentName = '''', '''', ''_'' + @TargetEnvironmentName)
			)
			BEGIN
				RETURN 1
			END
			ELSE
			BEGIN
				RETURN 0
			END
	END

	RETURN 0
END

' 
END
GO
