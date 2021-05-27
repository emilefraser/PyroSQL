SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[SetJsonIn]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[SetJsonIn] AS' 
END
GO

ALTER PROCEDURE [inout].[SetJsonIn] @JsonString [nvarchar](max) AS
BEGIN
	TRUNCATE TABLE [inout].[JsonIn]

	INSERT INTO inout.JsonIn (JsonString)
	SELECT @JsonString 

END
GO
