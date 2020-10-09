SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		Emile Fraser
-- Create date: 2020-04-04
-- Description:	Converts SAGE300 Times to UTC Times
-- =============================================
CREATE   FUNCTION [dbo].[udf_convertDate_Sage300_UTC] (
	@Sage300_Date INT = NULL
)
RETURNS DATE
AS
BEGIN
	
	-- Converts the INT Times value to UTC Times
	RETURN (		 
			CONVERT(
				DATE, CONVERT(
						VARCHAR(8), ISNULL(@Sage300_Date, NULL)
					  )
			)
	)
	
END

GO
