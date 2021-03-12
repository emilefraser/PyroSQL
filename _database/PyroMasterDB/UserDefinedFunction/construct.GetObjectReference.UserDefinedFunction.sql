SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[GetObjectReference]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'


CREATE   FUNCTION [construct].[GetObjectReference](
	@ServerName			SYSNAME = NULL
,	@DatabaseName		SYSNAME = NULL
,	@SchemaName			SYSNAME = NULL
,	@ObjectName			SYSNAME = NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN ((
		SELECT @ObjectName
	))
END
' 
END
GO
