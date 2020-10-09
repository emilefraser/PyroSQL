SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE [PERFMASTER].[sp_Execute_Cleanup]
	@TargetObject SYSNAME
AS
BEGIN
	SET NOCOUNT ON;
  
	DECLARE @sql_statement NVARCHAR(MAX)

	SET @sql_statement = 'TRUNCATE TABLE ' + @TargetObject
	RAISERROR(@sql_statement, 0, 1) WITH NOWAIT
	EXEC(@sql_statement)


	-- Clear Proc cashe and drops buffers
	-- CHECKPOINT
	-- DBCC [FreeProcCache | FreeSystemCache | FlushProcInDB(<dbid>) ]
	DBCC FREEPROCCACHE;
	DBCC DROPCLEANBUFFERS;
END

GO
