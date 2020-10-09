SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[CleanExpiredContentCache]
AS
    SET DEADLOCK_PRIORITY LOW
    SET NOCOUNT ON
    DECLARE @now as datetime

    SET @now = DATEADD(minute, -1, GETDATE())

    DELETE
    FROM
       [ReportServerTempDB].dbo.[ContentCache]
    WHERE
       ExpirationDate < @now

    SELECT @@ROWCOUNT
GO
