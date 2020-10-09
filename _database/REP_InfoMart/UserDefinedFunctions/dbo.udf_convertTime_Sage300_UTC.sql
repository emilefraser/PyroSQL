SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Emile Fraser
-- Create date: 2020-04-04
-- Description:	Converts SAGE300 Times to UTC Times
-- =============================================
CREATE   FUNCTION dbo.udf_convertTime_Sage300_UTC (
	@Sage300_Time INT = NULL
)
RETURNS TIME
AS
BEGIN
	
	-- Converts the INT Times value to UTC Times
	RETURN (		 
			 CAST(
				STUFF(
					STUFF(
						STUFF(
							RIGHT('00000000' + CONVERT(VARCHAR, ISNULL(@Sage300_Time,'')), 8)
						,3,0,':')
					,6,0,':')
				,9,0,'.') AS TIME
			)
	)
	
END

GO
