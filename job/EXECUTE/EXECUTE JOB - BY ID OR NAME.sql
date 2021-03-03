-- Executes a SQL JOB
DECLARE @RC INT
EXEC @RC = sp_start_job 
			--[@job_name] or [@job_id ]
			--[,@error_flag ] 
			--[,@server_name] 
			--[,@step_name ] 
			--[,@output_flag ]

SELECT 