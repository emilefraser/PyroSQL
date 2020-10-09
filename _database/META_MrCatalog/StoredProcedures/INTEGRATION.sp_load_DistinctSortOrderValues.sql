SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [INTEGRATION].[sp_load_DistinctSortOrderValues] (
    @FieldID int = NULL, -- passed through when sort order grouping is created
	@SortOrderGroupingID int = NULL,
	@TransactionPerson varchar(80) -- who actioned
)
AS
--declare temp table var to store multiple sort order values
     DECLARE @DataValueTable Table ( 
		 SortOrderGroupingID int,
		 SortOrder int,
	     DataValue varchar(100),
		 CreatedDT datetime2(7),
		 IsActive bit
    )
	--declare temp audit table var
	DECLARE @TempAuditTable Table (
		AuditData varchar(max) NULL,
		MasterEntity varchar(50) NULL,
		TableName varchar(50) NULL,
		PrimaryKeyID int NULL,
		TransactionAction nvarchar(20) NULL,
		TransactionDT datetime2(7) NULL,
		TransactionPerson varchar(80) NULL
	)
    DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction
    DECLARE @TableName varchar(50) = 'MASTER.SortOrderValue' -- table name
    DECLARE @TransactionAction nvarchar(20) = 'BulkCreate' -- type of transaction, "BulkCreate""
    DECLARE @MasterEntity varchar(50) = 'Sort Orders' -- from where actioned

--get distinct values from ingress table and store in temp table var
	INSERT INTO @DataValueTable (SortOrderGroupingID, SortOrder, DataValue, CreatedDT, IsActive)
	SELECT DISTINCT TOP 100 @SortOrderGroupingID, 99, I.DataValue, @TransactionDT, 1 
	From INTEGRATION.ingress_DistinctSortOrderValues I 
	LEFT JOIN MASTER.SortOrderValue S ON (I.DataValue = S.DataValue) 
	WHERE S.DataValue is null AND I.FieldID = @FieldID -- only for the added field ID


--bulk update into MASTER.SortOrderValue
	INSERT INTO MASTER.SortOrderValue (SortOrderGroupingID, SortOrder, DataValue, CreatedDT, IsActive)
	SELECT SortOrderGroupingID, SortOrder, DataValue, CreatedDT, IsActive
	FROM @DataValueTable

--bulk audit insert into temp audit table var
INSERT INTO @TempAuditTable (PrimaryKeyID, MasterEntity, TableName, TransactionAction, TransactionDT, TransactionPerson, AuditData)
SELECT SV2.SortOrderValueID, @MasterEntity, @TableName, @TransactionAction, @TransactionDT, @TransactionPerson,
(SELECT *  
FROM MASTER.SortOrderValue SV1
WHERE SV1.CreatedDT = @TransactionDT
AND SV1.DataValue = SV2.DataValue
FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER) as JSONDATA
FROM MASTER.SortOrderValue SV2 
where SV2.CreatedDT = @TransactionDT

--format all json to correct standard
Update @TempAuditTable
SET AuditData = JSON_MODIFY(
					JSON_MODIFY(
						JSON_MODIFY(
							JSON_MODIFY(
								JSON_MODIFY(AuditData, '$.ModifiedDT', FORMAT(CONVERT(datetime, @TransactionDT), 'dd MMM yyyy HH:mm:ss')), 
							'$.TransactionAction', @TransactionAction), 
						'$.TransactionPerson', @TransactionPerson), 
					'$.UpdatedDT', Null), 
				'$.CreatedDT', Null) 

--bulk insert into audit table
INSERT INTO AUDIT.AuditTrail (AuditData, MasterEntity, TableName, PrimaryKeyID, TransactionAction, TransactionDT, TransactionPerson)
SELECT AuditData, MasterEntity, TableName, PrimaryKeyID, TransactionAction, TransactionDT, TransactionPerson
FROM @TempAuditTable

GO
