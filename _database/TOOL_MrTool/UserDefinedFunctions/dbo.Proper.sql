SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

Create Function dbo.Proper(@Data VarChar(8000))
Returns VarChar(8000)
As
Begin
  Declare @Position Int

  Select @Data = Stuff(Lower(@Data), 1, 1, Upper(Left(@Data, 1))),
         @Position = PatIndex('%[^a-zA-Z][a-z]%', @Data COLLATE Latin1_General_Bin)

  While @Position > 0
    Select @Data = Stuff(@Data, @Position, 2, Upper(SubString(@Data, @Position, 2))),
           @Position = PatIndex('%[^a-zA-Z][a-z]%', @Data COLLATE Latin1_General_Bin)

  Return @Data
End
GO
