USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_execute_PresentationView_CreateOrAlter_Statement]    Script Date: 2020/06/12 1:40:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[sp_execute_PresentationView_CreateOrAlter_Statement]
	@schemaName AS SYSNAME
,	@viewName AS SYSNAME


AS
BEGIN

	DECLARE @sql AS NVARCHAR(MAX)

	SET @sql = (SELECT dbo.udf_get_PresentationView_CreateOrAlter_Statement('dbo', 'vw_DimEmployee'))

	RAISERROR(@sql, 0, 1) WITH NOWAIT
	EXEC sp_executesql @sql

END
