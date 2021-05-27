SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_DROP_SEQUENCE_IF_EXISTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DBTD_DROP_SEQUENCE_IF_EXISTS] AS' 
END
GO

--************************************************************************************************
--NOTE: Object is supported in SQL Server 2012 
--      earlier version do not support SEQUENCE objects
ALTER PROCEDURE [construct].[DBTD_DROP_SEQUENCE_IF_EXISTS]
(
	@v_Object_Name	SYSNAME	--Sequence Name
)
  AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_SQL NVARCHAR(255);
	DECLARE @v_Message VARCHAR(2000);

	SET @v_Message = 'Cannot drop "' + @v_Object_Name + '" sequence. Functionality is not supported for compatibility with earlier versions of SQL Server.';
	PRINT @v_Message;
	RETURN 0; 
	SELECT @@VERSION
	--BEGIN TRY 
	--	IF EXISTS (	SELECT 1 FROM SYS.SEQUENCES  
	--				WHERE name = OBJECT_ID(v_Object_Name))
	--	BEGIN
	--		SET @v_SQL = 'DROP SEQUENCE ' + v_Object_Name;
	--		EXECUTE sp_executesql @v_SQL;
	--		SET @v_Message = 'Sequence "' + @v_Object_Name + '" has been dropped.';
	--		PRINT @v_Message;
	--		RETURN 1; 
	--	END
	--	ELSE BEGIN 
	--		SET @v_Message = 'Cannot find sequence "' + v_Object_Name + '" ';
	--		PRINT @v_Message;
	--		RETURN 0; 
	--	END; 
	--END TRY
	--BEGIN CATCH
	--	SET @v_Message = 'Cannot drop "' + v_Object_Name + '" sequence ';
	--	PRINT @v_Message;
	--	RETURN 0; 
	--END CATCH 
END;

GO
