SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      <RJ Oosthuizen>
-- Create Date: <2019/07/11>
-- Description: <Stored Proc for the assigning and unassigning of fields to satellites >
-- =============================================
CREATE PROCEDURE [APP].[sp_Link_Satellite_Field_To_Satellite_Internal]
(
   -- Add the parameters for the stored procedure here
   @SatelliteFieldID int, --primary key of the table
   @SatelliteID int,
   @FieldIDString varchar(max),
   --Generic Parameters
   @TransactionAction nvarchar(100),
   @TransactionPerson varchar(100),
   @MasterEntity varchar(50)
)
AS
BEGIN
----testing
 --declare @SatelliteID int = 48
 --  declare @FieldIDString varchar(max) = '10097,10096,2050,' 
 --  declare @TransactionAction varchar(20) = 'UnAssign'

 Declare @TransactionDT datetime2(7) = getdate()
  --Declare @JSONData varchar(max)

 --Declare temp table for the selected roles from powerapps
 DECLARE @SatelliteFieldsToLink Table 
 (
   FieldID int,
   SatelliteID int
 )
 --insert into @RolesToLink the roles sent from powerapps
 INSERT INTO @SatelliteFieldsToLink (FieldID, SatelliteID)
	SELECT value, --value is the split up field id's
	@SatelliteID --the satellite name to which to assign to
	FROM  DC.tvf_Split_StringWithDelimiter(@FieldIDString, ',') -- call split function

--delete role id 0 created by split function
 DELETE FROM @SatelliteFieldsToLink 
 WHERE FieldID = 0

--select * from @SatelliteFieldsToLink



 If @TransactionAction = 'Assign'
 BEGIN

 --NEW FIELDS
 --Declare temp table for the selected fields from powerapps that do not exist in the table yet
 DECLARE @NewSatelliteFieldsToLink Table 
 (
   FieldID int,
   SatelliteID int,
   CreatedDT datetime2(7),
   IsActive bit
 )
 --populate @NewSatelliteFieldsToLink with the new fields to be added to the table
 INSERT INTO @NewSatelliteFieldsToLink(FieldID, SatelliteID, CreatedDT, IsActive)
 SELECT sftl.FieldID, sftl.SatelliteID, @TransactionDT, 1 
 FROM @SatelliteFieldsToLink sftl
 WHERE NOT EXISTS (SELECT * FROM [DMOD].[SatelliteField] sf
					WHERE sftl.FieldID = sf.FieldID
					AND sftl.SatelliteID = sf.SatelliteID) 

--select * from @NewSatelliteFieldsToLink

--insert new fields into linking table
INSERT INTO [DMOD].[SatelliteField](FieldId, SatelliteID, CreatedDT, IsActive)
SELECT FieldID, SatelliteID, @TransactionDT, 1
FROM @NewSatelliteFieldsToLink 


 --UPDATE FIELDS
 --Declare temp table for the selected fields from powerapps that already exist in the table and must be updated to isactive 1
 DECLARE @UpdateSatelliteFieldsToLink Table 
 (
   SatelliteFieldID int,
   FieldID int,
   SatelliteID int,
   UpdatedDT datetime2(7),
   IsActive bit
 )
 --populate @UpdateSatelliteFieldsToLink with the existing fields to be added to the table
 INSERT INTO @UpdateSatelliteFieldsToLink(SatelliteFieldID, FieldID, SatelliteID, UpdatedDT, IsActive)
 SELECT sf.SatelliteFieldID, sf.FieldID, sf.SatelliteID, @TransactionDT, 1 
 FROM [DMOD].[SatelliteField] sf
 WHERE EXISTS (SELECT * FROM @SatelliteFieldsToLink sftl
					WHERE sftl.FieldID = sf.FieldID
					AND sftl.SatelliteID = sf.SatelliteID)
					AND sf.IsActive = 0 

--select * from @UpdateSatelliteFieldsToLink

UPDATE [DMOD].[SatelliteField]
	SET IsActive = 1, 
	UpdatedDT = @TransactionDT
	FROM @UpdateSatelliteFieldsToLink sftl
		left join [DMOD].[SatelliteField] sf
		ON sftl.SatelliteFieldID = sf.SatelliteFieldID
END
 



 If @TransactionAction = 'UnAssign'
 BEGIN
 --UNASSIGN FIELDS
 --Declare temp table for the selected fields from powerapps that already exist in the table and must be updated to isactive 1
 DECLARE @SatelliteFieldsToUnLink Table 
 (
   SatelliteFieldID int,
   FieldID int,
   SatelliteID int,
   UpdatedDT datetime2(7),
   IsActive bit
 )
 --populate @@SatelliteFieldsToUnLink with the new roles to be added to the table
 INSERT INTO @SatelliteFieldsToUnLink(SatelliteFieldID, FieldID, SatelliteID, UpdatedDT, IsActive)
 SELECT sf.SatelliteFieldID, sf.FieldID, sf.SatelliteID, @TransactionDT, 1 
 FROM [DMOD].[SatelliteField] sf
 WHERE EXISTS (SELECT * FROM @SatelliteFieldsToLink sftl
					WHERE sftl.FieldId = sf.FieldID
					AND sftl.SatelliteID = sf.SatelliteID)
					AND sf.IsActive = 1 

--select * from @SatelliteFieldsToUnLink

UPDATE [DMOD].[SatelliteField]
	SET IsActive = 0, 
	UpdatedDT = @TransactionDT
	FROM @SatelliteFieldsToUnLink sful
		left join [DMOD].[SatelliteField] sf
		ON sful.SatelliteFieldID = sf.SatelliteFieldID
 END
END

GO
