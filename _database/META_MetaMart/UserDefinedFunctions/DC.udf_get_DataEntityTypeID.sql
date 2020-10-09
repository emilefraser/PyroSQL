SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [DC].[udf_get_DataEntityTypeID]
(
    @DataEntityTypeCode varchar(20)
)
RETURNS INT
AS
BEGIN
	
	DECLARE @DataEntityTypeID int

	select	@DataEntityTypeID = DataEntityTypeID
	from	DC.DataEntityType
	where	DataEntityTypeCode = @DataEntityTypeCode
    
	RETURN @DataEntityTypeID

END

GO
