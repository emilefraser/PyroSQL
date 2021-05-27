SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[printer].[PrintLong]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [printer].[PrintLong] AS' 
END
GO


ALTER PROCEDURE [printer].[PrintLong] 
	@Script VARCHAR(MAX)
AS
declare @i int = 1
while Exists(Select(Substring(@Script,@i,4000))) and (@i < LEN(@Script))
begin
     print Substring(@Script,@i,4000)
     set @i = @i+4000
end
GO
