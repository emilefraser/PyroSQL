SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE PERFMASTER.Test_Object_Existance
AS 
BEGIN
	DECLARE @sql NVARCHAR(MAX) = 'SELECT * FROM PERFORMANCE.PERFMASTER.Numbers'
	EXEC (@sql)

	--EXEC sp_executesql @sql
END
GO
