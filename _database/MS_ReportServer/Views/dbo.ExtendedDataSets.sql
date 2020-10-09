SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].ExtendedDataSets
AS
SELECT
    ID, LinkID, [Name], ItemID
FROM DataSets
UNION ALL
SELECT
    ID, LinkID, [Name], ItemID
FROM [ReportServerTempDB].dbo.TempDataSets
GO
