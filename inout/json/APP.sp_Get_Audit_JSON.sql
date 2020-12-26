SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [APP].[sp_Get_Audit_JSON] (
	@TableName varchar(40) = null, --identifier table name to capture record
    @TableBusinessKeyID int = null, --indentifier value to capture record (Primary key)
    @AppName VARCHAR(50) = null -- appname from which the record is captured
)
AS
BEGIN
    --declare temp table to store multiple results of audit data
    DECLARE @AuditTable Table (
	    AuditDataRecord VARCHAR(MAX) -- json data retrieved will be stored here
    )

    --get jsonfrom APP, TABLE and PRIMARY KEY
    INSERT INTO @AuditTable(AuditDataRecord)
        SELECT AuditData
        FROM AUDIT.AuditTrail
        WHERE MasterEntity = @AppName 
        AND TableName = @TableName 
        AND PrimaryKeyID = @TableBusinessKeyID

    --retrieve results from temp table
    SELECT AuditDataRecord FROM @AuditTable

END

GO
