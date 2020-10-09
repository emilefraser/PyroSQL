SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE VIEW dbo.sysoriginatingservers_view(originating_server_id, originating_server, master_server)
AS
   SELECT
      0 AS originating_server_id,
      UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))) AS originating_server,
      0 AS master_server
   UNION
   SELECT
      originating_server_id,
      originating_server,
      master_server
   FROM
      dbo.sysoriginatingservers

GO
