SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 2019-07-13
-- Description: Get DatabaseID from the FieldID
-- =============================================
CREATE FUNCTION [DC].[udf_get_DatabaseID_from_FieldID]
(
    @FieldID int
)
RETURNS int
AS
BEGIN
    DECLARE @Result int

    SELECT	@Result = s.DatabaseID
	FROM	[DC].[Field] f
		    INNER JOIN [DC].[DataEntity] de ON
				de.DataEntityID = f.DataEntityID
			INNER JOIN [DC].[Schema] s ON
				s.SchemaID = de.SchemaID
	WHERE	f.FieldID = @FieldID

    RETURN @Result
END

GO
