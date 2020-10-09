SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetUpgradeItems]
AS
SELECT
    [Item],
    [Status]
FROM
    [UpgradeInfo]
GO
