SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [dbo].[sysutility_ucp_dac_cpu_utilizations]
AS
SELECT
   dac.dac_name AS dac_name, 
   dac.dac_server_instance_name AS server_instance_name, 
   10 AS under_utilization, 
   dac.dac_percent_total_cpu_utilization AS current_utilization, 
   70 AS over_utilization
 FROM	msdb.dbo.sysutility_ucp_deployed_dacs AS dac

GO
