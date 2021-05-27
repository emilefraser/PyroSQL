SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Object_Schema]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [meta].[Object_Schema]
AS
	SELECT 
		[DatabaseId]		= DB_ID()
	,	[DatabaseName]		= DB_NAME()
    ,   [ObjectId]			= CONVERT(BIGINT, NULL)
	,   [SchemaId]			= [sch].[schema_id]
	,	[SchemaName]		= [sch].[name]
	,	[PrimcipalId]		= [sch].[principal_id]
	,	[SchemaOwner]		= [usr].[name]
	,	[IsSystemSchema]	= IIF([usr].[issqluser] = 1, 1, 0)
	,   [IsUserSchema]		= IIF([usr].[issqluser] = 0, 1, 0)
	,	[ObjectType]		= ''SC''
	,	[ObjectClass]		= ''COL''
	,	[CreatedDT]			= [usr].[createdate]
	FROM 
		[sys].[schemas] AS [sch]
	INNER JOIN
		[sys].[sysusers] AS [usr]
		ON [usr].[uid] = [sch].[principal_id]
	WHERE
		[usr].[isapprole] = 0 AND [usr].[issqlrole] = 0
' 
GO
