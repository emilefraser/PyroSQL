SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[ListInfoForReencryption]
@ConfigNames AS [dbo].[EncryptedConfigList] READONLY
AS

SELECT [DSID]
FROM [dbo].[DataSource] WITH (XLOCK, TABLOCK)

SELECT [SubscriptionID]
FROM [dbo].[Subscriptions] WITH (XLOCK, TABLOCK)

SELECT [InstallationID], [PublicKey]
FROM [dbo].[Keys] WITH (XLOCK, TABLOCK)
WHERE [Client] = 1 AND ([SymmetricKey] IS NOT NULL)

SELECT [Name],[Value]
FROM [dbo].[ConfigurationInfo]
WHERE [Name] IN (SELECT [ConfigName] FROM @ConfigNames)

SELECT [UserID]
FROM [dbo].[Users]
WHERE ([ServiceToken] IS NOT NULL)

SELECT [DSID]
FROM [dbo].[DataModelDataSource]
GO
