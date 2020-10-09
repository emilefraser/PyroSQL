SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROC [APP].[sp_Audit_Trail_Insert] (
    @TransactionPerson varchar(80) = null, -- user who actioned
    @MasterEntity  varchar(50) = null, -- from which app the record comes
    @TransactionAction nvarchar(20) = '', -- the type of action, "Create", "Update", "Delete"
    @JSONData VARCHAR(MAX) = NULL, -- data to be stored
    @TransactionDT DATETIME2(7) = null, -- date when the audit data is inserted
    @PrimaryKeyID int = null, -- primary key of the table freom which the data is coming
    @TableName VARCHAR(100) = null -- the table name from which the entry is coming
    )
AS
BEGIN

    --modify JSON correctly
    SET @JSONData = JSON_MODIFY(@JSONData, '$.ModifiedDT', FORMAT(CONVERT(datetime, @TransactionDT), 'dd MMM yyyy HH:mm:ss')) -- adds Transaction Date to the Audit Data
    SET @JSONData = JSON_MODIFY(@JSONData, '$.TransactionAction', @TransactionAction) -- adds Transaction Action to the Audit Data
    SET @JSONData = JSON_MODIFY(@JSONData, '$.TransactionPerson', @TransactionPerson) -- adds Transaction Person to the Audit Data
    SET @JSONData = JSON_MODIFY(@JSONData, '$.CreatedDT', Null) -- Delete CreatedDT
    SET @JSONData = JSON_MODIFY(@JSONData, '$.UpdatedDT', Null) -- Delete UpdatedDT
	SET @JSONData = JSON_MODIFY(@JSONData, '$."Created Date"', Null) -- Delete Created Date
    SET @JSONData = JSON_MODIFY(@JSONData, '$."Updated Date"', Null) -- Delete Updated Date

    BEGIN
        --insert the record into the audit table
        INSERT INTO AUDIT.AuditTrail (AuditData, TransactionDT, TransactionPerson, TransactionAction, MasterEntity, PrimaryKeyID, TableName)
        VALUES (@JSONData, @TransactionDT, @TransactionPerson, @TransactionAction, @MasterEntity, @PrimaryKeyID, @TableName)
    END

END

GO
