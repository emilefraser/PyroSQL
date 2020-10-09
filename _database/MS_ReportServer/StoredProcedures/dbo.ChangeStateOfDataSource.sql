SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[ChangeStateOfDataSource]
@ItemID [uniqueidentifier],
@Enable bit
AS
IF @Enable != 0 BEGIN
   UPDATE [DataSource]
      SET
         [Flags] = [Flags] | 1
   WHERE [ItemID] = @ItemID
END
ELSE
BEGIN
   UPDATE [DataSource]
      SET
         [Flags] = [Flags] & 0x7FFFFFFE
   WHERE [ItemID] = @ItemID
END
GO
