SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Emile Fraser
-- Create date: 2020-04-04
-- Description:	Converts SAGE300 Times to UTC Times
-- =============================================
CREATE   FUNCTION dbo.udf_convertDateTime_Sage300_UTC (
	@Sage300_Date INT = NULL
,	@Sage300_Time INT = NULL
)
RETURNS DATETIME2(7)
AS
BEGIN
	
	-- Converts the INT Times value to UTC Times
	RETURN ( 
			CONVERT(DATETIME2(7), 
				CONVERT(DATETIME, dbo.udf_convertDate_Sage300_UTC(@Sage300_Date)) 
			 +  CONVERT(DATETIME, dbo.udf_convertTime_Sage300_UTC(@Sage300_Time)) 
			)
	)
	
END

GO
