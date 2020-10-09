SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[SetPersistedStreamError]
@SessionID varchar(32),
@Index int,
@AllRows bit,
@Error nvarchar(512)
AS

if @AllRows = 0
BEGIN
    UPDATE [ReportServerTempDB].dbo.PersistedStream SET Error = @Error WHERE SessionID = @SessionID and [Index] = @Index
END
ELSE
BEGIN
    UPDATE [ReportServerTempDB].dbo.PersistedStream SET Error = @Error WHERE SessionID = @SessionID
END
GO
