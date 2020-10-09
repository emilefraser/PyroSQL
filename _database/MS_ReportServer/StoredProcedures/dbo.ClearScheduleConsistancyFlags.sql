SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[ClearScheduleConsistancyFlags]
AS
update [Schedule] with (tablock, xlock) set [ConsistancyCheck] = NULL
GO
