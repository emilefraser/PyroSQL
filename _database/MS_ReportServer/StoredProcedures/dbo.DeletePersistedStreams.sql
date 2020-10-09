SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeletePersistedStreams]
@SessionID varchar(32)
AS
SET NOCOUNT OFF
delete top (10) p
from [ReportServerTempDB].dbo.PersistedStream p
where p.SessionID = @SessionID;
GO
