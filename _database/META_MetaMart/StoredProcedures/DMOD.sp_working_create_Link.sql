SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2018-12-13
-- Description: Create a LINK modelling object in the working tables based on a stagearea tables
-- Tables:		[DMOD].[LinkGroup_Working]
--				[DMOD].[LinkHubLink_Working]
-- =============================================

-- Sample execution: exec DMOD.sp_working_create_Hub 2281,'Hub_Department',22593, 1

CREATE PROCEDURE [DMOD].[sp_working_create_Link]
AS
BEGIN
    
	--TODO: Create this procedure to create entries in the [DMOD].[LinkGroup_Working] and [DMOD].[LinkHubLink_Working] tables
	--TODO: Not sure about the ERD and Interface design, how will you select which hubs need to link to each other?

	select 'Still TODO'
END

GO
