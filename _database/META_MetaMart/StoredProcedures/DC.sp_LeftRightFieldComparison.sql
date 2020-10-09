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
	Description:				| Compares 2 databases to each other and shows differences in Fields.

*/								

/* SAMPLE EXECUTION:
EXEC [DC].[sp_LeftRightFieldComparison] 6, 7
*/
CREATE PROCEDURE [DC].[sp_LeftRightFieldComparison]
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

--Field missing from Left/Right
SELECT fLeft.SchemaID AS LeftSchemaID,
	   fLeft.DataEntityID AS LeftDataEntityID,
	   fLeft.FieldID AS LeftFieldID,
	   fLeft.FieldName AS LeftFieldName,
	   fRight.SchemaID AS RightSchemaID,
	   fRight.DataEntityID AS RightDataEntityID,
	   fRight.FieldID AS RightFieldID,
	   fRight.FieldName AS RightFieldName
  FROM (
			SELECT sL.SchemaID,
				   deL.DataEntityID,
				   fL.FieldID,
				   sL.SchemaName + '.' + deL.DataEntityName + '.' + fL.FieldName AS FieldName
			  FROM [DC].[Schema] sL
				   INNER JOIN [DC].[DataEntity] deL ON
						deL.SchemaID = sL.SchemaID
				   INNER JOIN [DC].[Field] fL ON
						fL.DataEntityID = deL.DataEntityID
			 WHERE sL.DatabaseID = @LeftDatabaseID
	   ) fLeft
	   FULL OUTER JOIN
	   (
			SELECT sR.SchemaID,
				   deR.DataEntityID,
				   fR.FieldID,
				   sR.SchemaName + '.' + deR.DataEntityName + '.' + fR.FieldName AS FieldName
			  FROM [DC].[Schema] sR
				   INNER JOIN [DC].[DataEntity] deR ON
						deR.SchemaID = sR.SchemaID
				   INNER JOIN [DC].[Field] fR ON
						fR.DataEntityID = deR.DataEntityID
			 WHERE sR.DatabaseID = @RightDatabaseID
	   ) fRight ON
			fRight.FieldName = fLeft.FieldName
 WHERE fLeft.FieldName IS NULL OR
	   fRight.FieldName IS NULL

GO
