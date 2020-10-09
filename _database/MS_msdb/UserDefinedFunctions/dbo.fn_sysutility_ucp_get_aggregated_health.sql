SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysutility_ucp_get_aggregated_health]
(
	@is_over_utilized INT,
	@is_under_utilized INT
)
RETURNS TABLE
AS
RETURN ((SELECT 
CASE WHEN 0 = @is_over_utilized AND 0 = @is_under_utilized THEN 1 
ELSE CASE WHEN @is_over_utilized > 0 THEN 3 
ELSE 2 END END AS val))

GO
