SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.PrintLong 
	@Script VARCHAR(MAX)
AS
declare @i int = 1
while Exists(Select(Substring(@Script,@i,4000))) and (@i < LEN(@Script))
begin
     print Substring(@Script,@i,4000)
     set @i = @i+4000
end
GO
