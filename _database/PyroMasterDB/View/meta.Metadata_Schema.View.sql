SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Schema]'))
EXEC dbo.sp_executesql @statement = N'
CREATE   VIEW [meta].[Metadata_Schema]
AS

SELECT
	SchemaName			=	sch.name
  , SchemaID			=	sch.schema_id
  , SchemaOwner			=	usr.name
FROM
	sys.schemas AS sch
INNER JOIN
	sys.sysusers AS usr 
	ON usr.uid = sch.principal_id
' 
GO
