SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE  PROCEDURE [dbo].[GetDataSources]
@ItemID [uniqueidentifier],
@AuthType int
AS
BEGIN

SELECT -- select data sources and their links (if they exist)
    DS.[DSID],      -- 0
    DS.[ItemID],    -- 1
    DS.[Name],      -- 2
    DS.[Extension], -- 3
    DS.[Link],      -- 4
    DS.[CredentialRetrieval], -- 5
    DS.[Prompt],    -- 6
    DS.[ConnectionString], -- 7
    DS.[OriginalConnectionString], -- 8
    DS.[UserName],  -- 9
    DS.[Password],  -- 10
    DS.[Flags],     -- 11
    DSL.[DSID] AS DSLinkDSID,     -- 12
    DSL.[ItemID] AS DSLinkItemId,   -- 13
    DSL.[Name] AS DSLinkName,     -- 14
    DSL.[Extension] AS DSLinkExtension, -- 15
    DSL.[Link] AS DSLinkLink,     -- 16
    DSL.[CredentialRetrieval] AS DSLinkCredentialRetrieval, -- 17
    DSL.[Prompt] AS DSLinkPrompt,   -- 18
    DSL.[ConnectionString] AS DSLinkConnectionString, -- 19
    DSL.[UserName] AS DSLinkUserName, -- 20
    DSL.[Password] AS DSLinkPassword, -- 21
    DSL.[Flags] AS DSLinkFlags,	-- 22
    C.Path,         -- 23
    SD.NtSecDescPrimary, -- 24
    DS.[OriginalConnectStringExpressionBased], -- 25
    DS.[Version], -- 26
    DSL.[Version] AS DSLinkVersion, -- 27
    (SELECT 1 WHERE EXISTS (SELECT * from [ModelItemPolicy] AS MIP WHERE C.[ItemID] = MIP.[CatalogItemID])) AS IsModelItemPolicyEnabled, -- 28
    DS.[DSIDNum] --29
FROM
   ExtendedDataSources AS DS
   LEFT OUTER JOIN
    (DataSource AS DSL
     INNER JOIN Catalog C ON DSL.[ItemID] = C.[ItemID]
       LEFT OUTER JOIN [SecData] AS SD ON C.[PolicyID] = SD.[PolicyID] AND SD.AuthType = @AuthType)
   ON DS.[Link] = DSL.[ItemID]
WHERE
   DS.[ItemID] = @ItemID or DS.[SubscriptionID] = @ItemID
END
GO
