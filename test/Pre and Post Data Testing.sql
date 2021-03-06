DECLARE 
	@sql_statement NVARCHAR(MAX)
,	@SchemaName	SYSNAME				=	 'infomart'
,	@TableName	SYSNAME				=	 'vw_FactPurchaseContractAmendment'


-- Gets table checksum and count of rows
SET @sql_statement = 'SELECT ''' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ''', ''CHECKSUM_AGG(CHECKSUM(*))'', CHKSUM = CHECKSUM_AGG(CHECKSUM(*)), CNT = COUNT(1) FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName)

PRINT(@sql_statement)
EXEC sp_executesql		
		@stmt = @sql_statement

-- GETS THE HASH KEYS FOR ALL ROWS AND SAME TO TEMP TABLE
CREATE TABLE ##TableHash (DataSetName SYSNAME, HashValue VARCHAR(40))

INSERT INTO ##TableHash(DataSetName,HashValue)
SELECT 
DataSetName = 'vw_FactPurchaseContractAmendment'
,HashValue = 
	UPPER(CONVERT(VARCHAR(40),HASHBYTES('SHA1',
	   [CreatedDateKey]
      + '|' + [CompanyKey]
      + '|' + [VendorKey]
      + '|' + [PurchaseOrganizationKey]
      + '|' + [PurchaseGroupKey]
      + '|' + [MaterialGroupKey]
      + '|' + [MaterialKey]
      + '|' + [PlantKey]
      + '|' + [ObjectID]
      + '|' + [PurchaseContractNumber]
      + '|' + [PurchaseContractItemNumber]
      + '|' + [ObjectClass]
      + '|' + [CreatedBy]
      + '|' + [ChangedBy]
      + '|' + [ChangedDate]
      + '|' + [TableName]
      + '|' + [FieldName]
      + '|' + [ValueOld]
      + '|' + [ValueNew]
      + '|' + [ValueDifference]
      + '|' + [TotalValueNew]
      + '|' + [TotalValueOld]
      + '|' + [ShortDescription]
      + '|' + [TargetValueLines]
      + '|' + [TotalTargetValue]
      + '|' + [ContractStatus]
      + '|' + [ContractOwner]
      + '|' + [SupplierIDAriba]
      + '|' + [SupplierNameAriba]
      + '|' + [RelatedID]
      + '|' + [ContractTitle]
      + '|' + [ContractDescription]
      + '|' + [AribaAmount]
      + '|' + [AmendmentReason]
      + '|' + [AmendmentReasonComment]
      + '|' + [ContractCreatedDateAriba]
      + '|' + [EffectiveDate]
      + '|' + [AgreementDate]
      + '|' + [ExpirationDate]
      + '|' + [MaxTransactionDate]
      + '|' + [LastLoadDT]
	  + '|'),2))
FROM
	infomart.vw_FactPurchaseContractAmendment
	