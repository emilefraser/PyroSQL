SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[GetServerIpAndPort]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[GetServerIpAndPort] AS' 
END
GO
ALTER   PROCEDURE [dba].[GetServerIpAndPort]
AS
BEGIN


--EXEC master.dbo.xp_readerrorlog 0, 1, N'Server is listening on' 

SELECT DISTINCT 
    local_tcp_port 
FROM sys.dm_exec_connections 
WHERE local_tcp_port IS NOT NULL 


select * from sys.dm_tcp_listener_states 


END
GO
