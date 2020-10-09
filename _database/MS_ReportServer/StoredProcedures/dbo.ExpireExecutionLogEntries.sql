SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[ExpireExecutionLogEntries]
AS
SET NOCOUNT OFF
-- -1 means no expiration
if exists (select * from ConfigurationInfo where [Name] = 'ExecutionLogDaysKept' and CAST(CAST(Value as nvarchar) as integer) = -1)
begin
return
end

delete from ExecutionLogStorage
where DateDiff(day, TimeStart, getdate()) >= (select CAST(CAST(Value as nvarchar) as integer) from ConfigurationInfo where [Name] = 'ExecutionLogDaysKept')
GO
