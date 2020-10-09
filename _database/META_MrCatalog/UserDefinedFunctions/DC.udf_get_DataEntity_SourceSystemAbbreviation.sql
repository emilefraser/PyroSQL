SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2019/01/11
-- Description: Get the source system abbreviation for a data entity
-- =============================================

-- Sample Execution
/*

	select DC.udf_get_TopLevelParentDataEntity_SourceSystemAbbr(7128)

*/

CREATE FUNCTION [DC].[udf_get_DataEntity_SourceSystemAbbreviation]
(
    -- Add the parameters for the function here
    @DataEntityID int
)
RETURNS varchar(50)
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result varchar(50)

	SELECT	@Result = [system].SystemAbbreviation
	FROM DC.[Database] db
		LEFT JOIN DC.[DatabaseInstance] dbinst ON
			dbinst.DatabaseInstanceID = db.DatabaseInstanceID
		LEFT JOIN DC.[Server] serv ON
			serv.ServerID = dbinst.ServerID
		LEFT JOIN DC.[System] [system] ON
			[system].SystemID = db.SystemID
		LEFT JOIN DC.[Schema] s ON
			s.DatabaseID = db.DatabaseID
		LEFT JOIN DC.DataEntity de ON
			de.SchemaID = s.SchemaID
		--LEFT JOIN DC.Field f ON
		--	f.DataEntityID = de.DataEntityID
	WHERE	de.DataEntityID = @DataEntityID	

	RETURN	@Result

END

GO
