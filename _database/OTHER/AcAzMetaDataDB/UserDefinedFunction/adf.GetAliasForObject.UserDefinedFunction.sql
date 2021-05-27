SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetAliasForObject]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE   FUNCTION [adf].[GetAliasForObject] (
	@ObjectName SYSNAME
,	@ObjectType SYSNAME
)
RETURNS SYSNAME
AS
BEGIN
	RETURN (
		SELECT 
			COALESCE((
						SELECT 
							ObjectAlias
						FROM 
							adf.LoadObjectAlias
						WHERE	
							ObjectName = @ObjectName
						AND 
							ObjectType = @ObjectType
			), @ObjectName
			)
	)			
END

' 
END
GO
