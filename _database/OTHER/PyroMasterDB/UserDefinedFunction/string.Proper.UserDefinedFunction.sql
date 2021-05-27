SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[Proper]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
Create Function [string].[Proper](@Data VarChar(8000))
Returns VarChar(8000)
As
Begin
  Declare @Position Int

  Select @Data = Stuff(Lower(@Data), 1, 1, Upper(Left(@Data, 1))),
         @Position = PatIndex(''%[^a-zA-Z][a-z]%'', @Data COLLATE Latin1_General_Bin)

  While @Position > 0
    Select @Data = Stuff(@Data, @Position, 2, Upper(SubString(@Data, @Position, 2))),
           @Position = PatIndex(''%[^a-zA-Z][a-z]%'', @Data COLLATE Latin1_General_Bin)

  Return @Data
End
' 
END
GO
