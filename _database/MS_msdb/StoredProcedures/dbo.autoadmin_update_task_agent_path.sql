SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE autoadmin_update_task_agent_path
        @assembly_name		VARCHAR(255),
        @new_assembly_path	VARCHAR(MAX)
AS
BEGIN
    UPDATE autoadmin_task_agents 
	SET task_assembly_path = @new_assembly_path
    WHERE autoadmin_task_agents.task_assembly_name = @assembly_name
END

GO
