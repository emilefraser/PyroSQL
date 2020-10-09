SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [dbo].[syspolicy_policy_execution_history]
AS
    SELECT 
        history_id,
        policy_id,
        start_date,
        end_date,
        result,
        exception_message,
        exception
    FROM [dbo].[syspolicy_policy_execution_history_internal]

GO
