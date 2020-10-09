SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROC [dbo].[UpgradeSharePointPaths]
    @OldPrefix nvarchar(440),
    @NewPrefix nvarchar(440),
    @PrefixLen int

AS
BEGIN
UPDATE [Catalog]
  SET [Path] = @NewPrefix + SUBSTRING([Path], @PrefixLen, 5000)
  WHERE [Path] like @OldPrefix escape '*';
END
GO
