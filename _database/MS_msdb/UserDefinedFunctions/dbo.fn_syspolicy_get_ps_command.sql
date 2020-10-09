SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION [dbo].[fn_syspolicy_get_ps_command] (@schedule_uid uniqueidentifier)
RETURNS nvarchar(max)
AS
BEGIN
	
	DECLARE @schedule_uid_string nvarchar(max);
	SET @schedule_uid_string = CONVERT(nvarchar(36), @schedule_uid);
	
	-- translate to PSPath root name, for default instances 
	-- we need to add \default as instance name
	DECLARE @root_name nvarchar(100);
	SET @root_name = @@SERVERNAME
	IF( 0 = CHARINDEX('\', @@SERVERNAME))
		SET @root_name = @root_name + N'\default';
	
	DECLARE @command nvarchar(max);
	SET @command = N'dir SQLSERVER:\SQLPolicy\' + @root_name + 
				N'\Policies | where { $_.ScheduleUid -eq "' + @schedule_uid_string + 
				N'" } |  where { $_.Enabled -eq 1} | where {$_.AutomatedPolicyEvaluationMode -eq 4} | Invoke-PolicyEvaluation -AdHocPolicyEvaluationMode 2 -TargetServerName ' + @@SERVERNAME
				
	RETURN @command
END

GO
