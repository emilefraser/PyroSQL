SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetSystemPolicy]
@AuthType int
AS
SELECT SecData.NtSecDescPrimary, SecData.XmlDescription
FROM Policies
LEFT OUTER JOIN SecData ON Policies.PolicyID = SecData.PolicyID AND AuthType = @AuthType
WHERE PolicyFlag = 1
GO
