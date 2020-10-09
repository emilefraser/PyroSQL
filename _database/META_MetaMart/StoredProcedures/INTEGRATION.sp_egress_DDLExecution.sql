SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

--Sample Execution: [EXECUTION].[sp_egress_DDLExecution]
CREATE procedure [INTEGRATION].[sp_egress_DDLExecution] as
select [DDLExecutionQueueID]
      ,[DDLQueryText]
      
  FROM [EXECUTION].[DDLExecutionQueue] 
  where [Result] = 'Pending'

GO
