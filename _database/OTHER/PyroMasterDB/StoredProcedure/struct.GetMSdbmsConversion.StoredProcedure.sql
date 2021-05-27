SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[struct].[GetMSdbmsConversion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [struct].[GetMSdbmsConversion] AS' 
END
GO
 ALTER PROCEDURE [struct].[GetMSdbmsConversion]
 AS
 BEGIN
		SELECT * FROM msdb.dbo.MSdbms dest
		SELECT * FROM msdb.dbo.MSdbms_datatype srcdt
		SELECT * FROM msdb.dbo.MSdbms_map
		SELECT * FROM msdb.dbo.MSdbms_datatype_mapping
END
GO
