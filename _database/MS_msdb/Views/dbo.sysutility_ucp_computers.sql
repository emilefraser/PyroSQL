SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_computers
AS
   SELECT  
       server_table.id AS computer_id    -- todo (VSTS #345036): This column will be removed
       , server_table.virtual_server_name AS virtual_server_name
       , server_table.physical_server_name AS physical_server_name
       , server_table.is_clustered_server AS is_clustered
       , server_table.percent_total_cpu_utilization AS processor_utilization
       , server_table.cpu_name AS cpu_name
       , server_table.cpu_max_clock_speed AS cpu_max_clock_speed
       , server_table.processing_time AS processing_time
       , urn
       , powershell_path       
   FROM    [dbo].[syn_sysutility_ucp_computers] as server_table

GO
