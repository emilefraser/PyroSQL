SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION [DC].[udf_get_FieldRelationTypeID]
(
    @FieldRelationTypeCode varchar(50)
)
RETURNS INT
AS
BEGIN
	
	declare @FieldRelationTypeID int

    select	@FieldRelationTypeID = FieldRelationTypeID
	from	DC.FieldRelationType
	where	FieldRelationTypeCode = @FieldRelationTypeCode

	return	@FieldRelationTypeID
END

GO
