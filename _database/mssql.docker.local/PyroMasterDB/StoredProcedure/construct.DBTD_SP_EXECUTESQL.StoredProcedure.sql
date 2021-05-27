SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_SP_EXECUTESQL]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DBTD_SP_EXECUTESQL] AS' 
END
GO
--************************************************************************************************
ALTER PROCEDURE [construct].[DBTD_SP_EXECUTESQL]
(
	@v_TargetDatabase SYSNAME,	--Target database
	@v_SQLCode NVARCHAR(MAX)	--SQL Code that will be executed in the target database
)
  AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @v_InterDBCode NVARCHAR(MAX),
			@v_ProcName	NVARCHAR(128) = OBJECT_NAME(@@PROCID)

	CREATE TABLE #DBTD_INTER_DB_SQL(
		SQLCode NVARCHAR(MAX)
	);
	INSERT INTO #DBTD_INTER_DB_SQL (SQLCode) VALUES (@v_SQLCode);
	IF OBJECT_ID('dbo.DBTD_TBL_LOG') IS NOT NULL
	BEGIN
		INSERT INTO dbo.DBTD_TBL_LOG 
			(EventType, EventSource, EventTime, [Message]) 
			VALUES ('INFO', 'DBTD_SP_EXECUTESQL', GETDATE(), @v_SQLCode);
	END

	SET @v_InterDBCode = 
		'
		DECLARE @v NVARCHAR(MAX); 
		SELECT @v = SQLCode FROM #DBTD_INTER_DB_SQL; 
		EXECUTE '+@v_TargetDatabase+'.dbo.sp_executesql @v;
		';

	EXECUTE dbo.sp_executesql @v_InterDBCode;

	DROP TABLE #DBTD_INTER_DB_SQL --explicity drop the table
END;

GO
