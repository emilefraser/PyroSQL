SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Role]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [meta].[Metadata_Role]
AS
	SELECT 
	    [SchemaID]			= [sch].[schema_id]
	,	[SchemaName]		= [sch].[name]
	,	[RoleId]			= [sch].[principal_id]
	,	[RoleName]			= [usr].[name]
	,	[IsAppRole]			= IIF([usr].[isapprole] = 1, 1, 0)	
	,	[IsSqlRole]			= IIF([usr].[issqlrole] = 1, 1, 0)	
	,	[CreatedDT]			= [usr].[createdate]
	FROM 
		[sys].[schemas] AS [sch]
	INNER JOIN
		[sys].[sysusers] AS [usr]
		ON [usr].[uid] = [sch].[principal_id]
	WHERE
		[usr].[isapprole] = 1 OR [usr].[issqlrole]  = 1
' 
GO
