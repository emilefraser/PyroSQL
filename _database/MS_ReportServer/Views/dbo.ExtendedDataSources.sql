SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].ExtendedDataSources
AS
SELECT
    DSID, ItemID, SubscriptionID, Name, Extension, Link,
    CredentialRetrieval, Prompt, ConnectionString,
    OriginalConnectionString, OriginalConnectStringExpressionBased,
    UserName, Password, Flags, Version, DSIDNum
FROM DataSource
UNION ALL
SELECT
    DSID, ItemID, NULL as [SubscriptionID], Name, Extension, Link,
    CredentialRetrieval, Prompt, ConnectionString,
    OriginalConnectionString, OriginalConnectStringExpressionBased,
    UserName, Password, Flags, Version, null
FROM [ReportServerTempDB].dbo.TempDataSources
GO
