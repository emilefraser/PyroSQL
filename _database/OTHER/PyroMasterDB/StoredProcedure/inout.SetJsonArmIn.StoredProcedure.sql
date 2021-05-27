SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[SetJsonArmIn]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[SetJsonArmIn] AS' 
END
GO

ALTER PROCEDURE [inout].[SetJsonArmIn] @JsonString [nvarchar](max) AS
BEGIN
	TRUNCATE TABLE [inout].[JsonArmIn]

	INSERT INTO inout.[JsonArmIn] ([JsonArmString])
	SELECT @JsonString 

END

select * from [inout].[JsonArmIn]
GO
