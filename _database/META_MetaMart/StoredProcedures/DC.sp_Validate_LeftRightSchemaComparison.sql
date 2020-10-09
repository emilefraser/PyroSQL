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
	Description:				| Compares 2 databases to each other and shows differences Schemas.

*/
								
/* SAMPLE EXECUTION:
EXEC [DC].[sp_LeftRightSchemaComparison] 6, 7
*/
CREATE PROCEDURE [DC].[sp_Validate_LeftRightSchemaComparison]
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

--Schema missing from Left/Right
SELECT sLeft.SchemaID AS LeftSchemaID,
	   sLeft.SchemaName AS LeftSchemaName,
	   sRight.SchemaID AS RightSchemaID,
	   sRight.SchemaName AS RightSchemaName
  FROM (
			SELECT sL.SchemaID,
				   sL.SchemaName
			  FROM [DC].[Schema] sL
			 WHERE sL.DatabaseID = @LeftDatabaseID
	   ) sLeft
	   FULL OUTER JOIN
	   (
			SELECT sR.SchemaID,
				   sR.SchemaName
			  FROM [DC].[Schema] sR
			 WHERE sR.DatabaseID = @RightDatabaseID
	   ) sRight ON
			sRight.SchemaName = sLeft.SchemaName
 WHERE sLeft.SchemaName IS NULL OR
	   sRight.SchemaName iS NULL

GO
