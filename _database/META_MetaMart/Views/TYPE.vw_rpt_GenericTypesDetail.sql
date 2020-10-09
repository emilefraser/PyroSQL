SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [TYPE].[vw_rpt_GenericTypesDetail]
AS
SELECT	gh.HeaderID, gh.HeaderCode, gh.HeaderTypeGroupName, gh.IsActive AS Header_Active
		, gd.DetailID, gd.DetailTypeCode, gd.DetailTypeDescription, gd.CreatedDT, gd.ModifiedDT, gd.IsActive AS Detail_Active
FROM	[TYPE].Generic_Header gh
	INNER JOIN [TYPE].Generic_Detail gd
		ON gh.HeaderID = gd.HeaderID

GO
