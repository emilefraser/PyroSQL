SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spDouble]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spDouble] AS' 
END
GO

ALTER   PROCEDURE [dbo].[spDouble] 
  @input int
AS
    BEGIN
        RETURN @input *2;
    END
GO
