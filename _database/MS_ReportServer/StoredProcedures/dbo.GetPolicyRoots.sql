SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetPolicyRoots]
AS
SELECT
    [Path],
    [Type]
FROM
    [Catalog]
WHERE
    [PolicyRoot] = 1
GO
