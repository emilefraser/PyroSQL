SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[mssql].[ClassifyObjectAsSystemObject]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [mssql].[ClassifyObjectAsSystemObject] AS' 
END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [mssql].[ClassifyObjectAsSystemObject]
	-- Add the parameters for the stored procedure here
	@DatabaseName	SYSNAME = NULL
,	@SchemaName		SYSNAME
,	@ObjectName		SYSNAME 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FullObjectName NVARCHAR(264) = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName)

	--mark the procedure as system procedure
	IF(@DatabaseName IS NULL)
	BEGIN
		EXEC sp_ms_marksystemobject 
						@objname = @FullObjectName
	END
	ELSE
	BEGIN
		EXEC sp_ms_marksystemobject 
							@objname	= @FullObjectName
						,	@namespace	= @DatabaseName
	END

END
GO
