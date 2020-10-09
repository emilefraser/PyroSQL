SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
--===============================================================================================================================
--Stored Proc Version Control
--===============================================================================================================================
/*

	Author:						| Karl Dinkelmann
	Stored Proc Create Date:	| 2019-07-13
	Stored Proc Last Modified:	| N/A
	Last Modified User:			| N/A
	Description:				| Compares 2 databases to each other and shows differences DataEntities.

*/								

/* SAMPLE EXECUTION:
EXEC [DC].[sp_LeftRightDataEntityComparison] 6, 7
*/
CREATE PROCEDURE [DC].[sp_LeftRightDataEntityComparison]
	@LeftDatabaseID INT,
	@RightDatabaseID INT
AS

/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
--Stored Proc Management
	--===============================================================================================================================
	--Variable workbench
	--===============================================================================================================================
	---------------------------------------------------------------------------------------------------------------------------------
	--Testing variables (COMMENT OUT BEFORE ALTERING THE PROC)
	---------------------------------------------------------------------------------------------------------------------------------
	-- (If you uncomment this line the whole testing variable block will become active
		
	--DECLARE @LeftDatabaseID INT = 6,
	--		@RightDatabaseID INT = 7

	
	---------------------------------------------------------------------------------------------------------------------------------
	--Stored Proc Variables
	---------------------------------------------------------------------------------------------------------------------------------	
		--DECLARE	 



/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
--Stored Proc Logic

--DataEntity missing from Left/Right
SELECT deLeft.SchemaID AS LeftSchemaID,
	   deLeft.DataEntityID AS LeftDataEntityID,
	   deLeft.DataEntityName AS LeftDataEntityName,
	   deRight.SchemaID AS RightSchemaID,
	   deRight.DataEntityID AS RightDataEntityID,
	   deRight.DataEntityName AS RightDataEntityName
  FROM (
			SELECT sL.SchemaID,
				   deL.DataEntityID,
				   sL.SchemaName + '.' + deL.DataEntityName AS DataEntityName
			  FROM [DC].[Schema] sL
				   INNER JOIN [DC].[DataEntity] deL ON
						deL.SchemaID = sL.SchemaID
			 WHERE sL.DatabaseID = @LeftDatabaseID
	   ) deLeft
	   FULL OUTER JOIN
	   (
			SELECT sR.SchemaID,
				   deR.DataEntityID,
				   sR.SchemaName + '.' + deR.DataEntityName AS DataEntityName
			  FROM [DC].[Schema] sR
				   INNER JOIN [DC].[DataEntity] deR ON
						deR.SchemaID = sR.SchemaID
			 WHERE sR.DatabaseID = @RightDatabaseID
	   ) deRight ON
			deRight.DataEntityName = deLeft.DataEntityName
 WHERE deLeft.DataEntityName IS NULL OR
	   deRight.DataEntityName IS NULL



GO
