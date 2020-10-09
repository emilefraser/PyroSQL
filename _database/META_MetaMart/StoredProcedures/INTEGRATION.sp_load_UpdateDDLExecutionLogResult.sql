SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

 


-- =====================================================================
-- Author:        Francois Senekal
-- Create date: 24 Oct 2018
-- Description:    Update [EXECUTION].[DDLExecutionQueue] after DDL ran
-- =====================================================================

 

CREATE PROCEDURE [INTEGRATION].[sp_load_UpdateDDLExecutionLogResult]
AS
UPDATE   deq
SET         deq.[Result] = idel.[Result]
        ,deq.[ErrorMessage] = idel.[ErrorMessage]
        ,deq.[ErrorID] = idel.[ErrorID]
        ,deq.[ExecutedDT] = idel.[CreatedDT]
FROM [INTEGRATION].[ingress_DDLExecutionLog] idel
    join [EXECUTION].[DDLExecutionQueue] deq
        ON deq.DDLExecutionQueueID = idel.DDLExecutionQueueID

 

TRUNCATE TABLE [INTEGRATION].[ingress_DDLExecutionLog]

GO
