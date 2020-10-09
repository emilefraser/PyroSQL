SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [dbo].[sysutility_ucp_computer_cpu_utilizations]
AS
SELECT comp.physical_server_name AS physical_server_name, 
   10 AS under_utilization, 
   comp.processor_utilization AS current_utilization, 
   70 AS over_utilization
FROM	msdb.dbo.sysutility_ucp_computers AS comp

GO
