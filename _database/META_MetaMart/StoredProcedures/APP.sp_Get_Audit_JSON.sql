SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [APP].[sp_Get_Audit_JSON] (
	@TableName varchar(40) = null, --identifier table name to capture record
    @TableBusinessKeyID int = null, --indentifier value to capture record (Primary key)
    @AppName VARCHAR(50) = null, -- appname from which the record is captured
	@TransactionPerson varchar(80) = null -- who actioned
)
AS
BEGIN
	--TESTING
 --   DECLARE @TableName varchar(40) = 'ETL.LoadConfig'
 --   DECLARE @TableBusinessKeyID int = 1
 --   DECLARE @AppName VARCHAR(50) = 'ODS Loader'
	--DECLARE @TransactionPerson varchar(80) = 'tmokwetli@tharisa.com'
	--DECLARE @NEWDATE int = NULL

	--TimeZone conversion

	DECLARE @NEWDATE INT = (SELECT [MASTER].[udf_TimeZone_Conversion](@TransactionPerson))

	--SELECT @NEWDATE
    --declare temp table to store multiple results of audit data
    DECLARE @AuditTable Table (
		AuditTrailID INT, -- audit trail primary key id, used later to order by for newest first
		AuditDataRecord VARCHAR(MAX) -- json data retrieved will be stored here
    )

    --get jsonfrom APP, TABLE and PRIMARY KEY
    INSERT INTO @AuditTable(AuditTrailID, AuditDataRecord)
        SELECT AuditTrailID, AuditData
        FROM AUDIT.AuditTrail
        WHERE MasterEntity = @AppName 
        AND TableName = @TableName 
        AND PrimaryKeyID = @TableBusinessKeyID

	
	If(@NEWDATE is null)
	BEGIN
	UPDATE @AuditTable
	SET AuditDataRecord = JSON_MODIFY(AuditDataRecord,'$.ModifiedDT',JSON_VALUE(AuditDataRecord,'$.ModifiedDT') + 'Time zone conversion not executed. This user has no time zone setting configured.')
	FROM @AuditTable
	
	END
	ELSE
	BEGIN
	--SELECT @NEWDATE
	UPDATE @AuditTable
	SET AuditDataRecord = JSON_MODIFY(AuditDataRecord,'$.ModifiedDT',FORMAT(DATEADD(hour,@NEWDATE,JSON_VALUE(AuditDataRecord,'$.ModifiedDT')),'yyyy-MM-dd HH:mm:ss'))
	FROM @AuditTable
	
	END

	--DECLARE @AuditTrailID int;
	--DECLARE @GetID Cursor
	----DECLARE @RunningTotal BIGINT = 0;
	----DECLARE @RowCnt BIGINT = (SELECT Count(0) FROM @AuditTable)
	--SET @GetID = CURSOR FOR 
	--SELECT AuditTrailID
	--FROM @AuditTable

	--OPEN @GetID

	--FETCH NEXT 
	--FROM @GetID INTO @AuditTrailID
	--WHILE @@FETCH_STATUS = 0
	--BEGIN 
	--If(@NEWDATE is null)
	--BEGIN
	--UPDATE @AuditTable
	--SET AuditDataRecord = JSON_MODIFY(AuditDataRecord,'$.ModifiedDT','Time zone conversion not executed. This user has no time zone setting configured.')
	--FROM @AuditTable
	
	--END
	--ELSE
	--BEGIN
	--UPDATE @AuditTable
	--SET AuditDataRecord = JSON_MODIFY(AuditDataRecord,'$.ModifiedDT',FORMAT(DATEADD(hour,@NEWDATE,JSON_VALUE(AuditDataRecord,'$.ModifiedDT')),'yyyy-MM-dd HH:mm:ss.ff'))
	--FROM @AuditTable
	--END
	--FETCH NEXT 
	--FROM @GetID INTO @AuditTrailID
	--END
	--CLOSE @GetID
	--DEALLOCATE @GetID

    --retrieve results from temp table
	SELECT AuditDataRecord FROM @AuditTable
	ORDER BY AuditTrailID DESC --get newest listed first


END





GO
