SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[GetPartFromSplitString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'Create function [string].[GetPartFromSplitString]
(@BigStr varchar(200),
 @seperator char(1),
 @ind int 
) returns varchar(200)
as
begin
declare @xpos int
declare @i int
declare @res varchar(200)  
set @i=1
set @xpos = CharIndex (@seperator,@BigStr)
while @i < @ind
 begin  
  set @i = @i + 1
  set @BigStr = substring (@BigStr, @xpos + 1,len(@BigStr) - @xpos )
  set @xpos = CharIndex (@seperator,@BigStr)
 end
if @xpos = 0 
  set @res =  @BigStr
else 
 begin 
  set @BigStr = substring (@BigStr,1,@xpos - 1) + ''.'' + 
                substring (@BigStr, @xpos + 1,len(@BigStr) - @xpos )
  set @res = ParseName (@BigStr,2)
 end
return @res
end 
' 
END
GO
