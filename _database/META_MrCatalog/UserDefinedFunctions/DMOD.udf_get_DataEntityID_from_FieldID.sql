SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2019-06-20
-- Description: Get DataEntityID from the FieldID
-- =============================================
CREATE FUNCTION [DMOD].[udf_get_DataEntityID_from_FieldID]
(
    -- Add the parameters for the function here
    @FieldID int
)
RETURNS int
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result int

    -- Add the T-SQL statements to compute the return value here
    SELECT	@Result = DataEntityID
	FROM	DMOD.[Field] f
	WHERE	FieldID = @FieldID

    -- Return the result of the function
    RETURN @Result
END

GO
