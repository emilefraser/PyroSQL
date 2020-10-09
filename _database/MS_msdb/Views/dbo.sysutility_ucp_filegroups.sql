SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW dbo.sysutility_ucp_filegroups
AS
   SELECT  [S].[urn]
        , [S].[parent_urn]
        , [S].[Name]
        , [S].[server_instance_name]
        , [S].[database_name]
        , [S].[powershell_path]
        , [S].[processing_time]
        FROM [dbo].[syn_sysutility_ucp_filegroups] S

GO
