SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019
-- Description: Generate a Field list for a select statement from the ODS area table with a standard alias prefix

--!~ StageArea BK Hash Column Calculation from ODS
				BKHash = CONVERT	(VARCHAR(40),
							HASHBYTES	('SHA1',
									CONVERT	(VARCHAR(MAX),
											COALESCE(UPPER(LTRIM(RTRIM(StandardAlias.EMP_EMPNO))),'')
											)
										)
								,2)
				-- End of StageArea BK Hash Column Calculation from ODS ~!

*/

CREATE FUNCTION [DMOD].[udf_GetFieldList_WithAlias_BK_ODS]
(
    @HubID INT
,   @SystemID INT   
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @FieldList VARCHAR(MAX) = ''

    -- Initial Value
    SELECT @FieldList = @FieldList + 'BKHash = '

    -- Count of DISTINCT and NON-DISTINCT Data Entitiy
    DECLARE @DataEntityCount_DISTINCT INT = 0
    DECLARE @DataEntityCount INT = 0
    
    SELECT 
	   @DataEntityCount =  COUNT(f.DataEntityID)
    FROM	
	   DMOD.[Hub] AS h
    INNER JOIN 
	   DMOD.[HubBusinessKey] AS hbk
		  ON hbk.[HubID] = h.[HubID]
    INNER JOIN 
	   DMOD.[HubBusinessKeyField] AS hbkf
		  ON hbkf.[HubBusinessKeyID] = hbk.[HubBusinessKeyID]
    INNER JOIN 
	   DC.[Field] AS f
		  ON hbkf.FieldID = f.FieldID
    INNER JOIN 
	   [DC].[vw_rpt_DatabaseFieldDetail] AS vrdfd
		  ON vrdfd.FieldID = f.FieldID
	WHERE 
	   h.[HubID] =  @HubID
	AND
	   vrdfd.[SystemID] = @SystemID

    SELECT 
	   @DataEntityCount_DISTINCT =  COUNT(DISTINCT f.DataEntityID)
    FROM	
	   DMOD.[Hub] AS h
    INNER JOIN 
	   DMOD.[HubBusinessKey] AS hbk
		  ON hbk.[HubID] = h.[HubID]
    INNER JOIN 
	   DMOD.[HubBusinessKeyField] AS hbkf
		  ON hbkf.[HubBusinessKeyID] = hbk.[HubBusinessKeyID]
    INNER JOIN 
	   DC.[Field] AS f
		  ON hbkf.FieldID = f.FieldID
    INNER JOIN 
	   [DC].[vw_rpt_DatabaseFieldDetail] AS vrdfd
		  ON vrdfd.FieldID = f.FieldID
	WHERE 
	   h.[HubID] =  @HubID
	AND
	   vrdfd.[SystemID] = @SystemID

-- COLUMNS FROM THE SAME TABLE
IF (@DataEntityCount_DISTINCT = 1) 
BEGIN
    IF (@DataEntityCount = 1) 
    BEGIN
	   
	   SELECT 
		  @FieldList = @FieldList + 	  
			 'CONVERT	(VARCHAR(40),' + CHAR(13)+CHAR(10) + 'HASHBYTES	(''SHA1'',
									    CONVERT	(VARCHAR(MAX),
											    COALESCE(UPPER(LTRIM(RTRIM([' + 'StandardAlias' + CONVERT(VARCHAR(4), '1') + '].[' + f.FieldName + ']))),'''')
											    )
										    )
								    ,2)'
	   FROM	
		  DMOD.[Hub] AS h
	   INNER JOIN 
		  DMOD.[HubBusinessKey] AS hbk
			 ON hbk.[HubID] = h.[HubID]
	   INNER JOIN 
		  DMOD.[HubBusinessKeyField] AS hbkf
			 ON hbkf.[HubBusinessKeyID] = hbk.[HubBusinessKeyID]
	   INNER JOIN 
		  DC.[Field] AS f
			 ON hbkf.FieldID = f.FieldID
	   INNER JOIN 
		  [DC].[vw_rpt_DatabaseFieldDetail] AS vrdfd
			 ON vrdfd.FieldID = f.FieldID
	   WHERE 
		  h.[HubID] =  @HubID
	   AND
		  vrdfd.[SystemID] = @SystemID
	   ORDER BY 
		  f.FieldSortOrder
    
    END
		  
    ELSE IF (@DataEntityCount > 1)
    BEGIN 
	    
	   SELECT @FieldList = @FieldList + 	  
			 'CONVERT	(VARCHAR(40),
							 HASHBYTES	(''SHA1'','
									    											
	   SELECT 
		  @FieldList = @FieldList + ' CONVERT	(VARCHAR(MAX), COALESCE(UPPER(LTRIM(RTRIM([' + 'StandardAlias' + CONVERT(VARCHAR(4), '1') + '].[' + f.FieldName + ']))),'''') + ''|'' +' +CHAR(10)+CHAR(13)
	   FROM	
		  DMOD.[Hub] AS h
	   INNER JOIN 
		  DMOD.[HubBusinessKey] AS hbk
			 ON hbk.[HubID] = h.[HubID]
	   INNER JOIN 
		  DMOD.[HubBusinessKeyField] AS hbkf
			 ON hbkf.[HubBusinessKeyID] = hbk.[HubBusinessKeyID]
	   INNER JOIN 
		  DC.[Field] AS f
			 ON hbkf.FieldID = f.FieldID
	   INNER JOIN 
		  [DC].[vw_rpt_DatabaseFieldDetail] AS vrdfd
			 ON vrdfd.FieldID = f.FieldID
	   WHERE 
		  h.[HubID] =  @HubID
	   AND
		  vrdfd.[SystemID] = @SystemID
	   ORDER BY 
		  f.FieldSortOrder


	   IF (@FieldList != '')
		  SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 7)

	   SELECT @FieldList = @FieldList + '  )
										    )
								    ,2)'

	   END	

END

ELSE IF (@DataEntityCount_DISTINCT > 1) 
BEGIN

   DECLARE @DataEntityID AS INT
   DECLARE @StandardAlias_Number AS INT 
  
    SELECT @FieldList = @FieldList + 	  
			   'CONVERT	(VARCHAR(40),
							    HASHBYTES	(''SHA1'','

        SELECT @FieldList = @FieldList + ' CONVERT	(VARCHAR(MAX), COALESCE(UPPER(LTRIM(RTRIM([' + 'StandardAlias' + CONVERT(VARCHAR(4), sar.StandardAlias_Number) + '].[' + f.FieldName + ']))),'''') + ''|'' +' +CHAR(10)+CHAR(13)
	   FROM	
		  DMOD.[Hub] AS h
	   INNER JOIN 
		  DMOD.[HubBusinessKey] AS hbk
			 ON hbk.[HubID] = h.[HubID]
	   INNER JOIN 
		  DMOD.[HubBusinessKeyField] AS hbkf
			 ON hbkf.[HubBusinessKeyID] = hbk.[HubBusinessKeyID]
	   INNER JOIN 
		  DC.[Field] AS f
			 ON hbkf.FieldID = f.FieldID
	   INNER JOIN 
		  [DC].[vw_rpt_DatabaseFieldDetail] AS vrdfd
			 ON vrdfd.FieldID = f.FieldID
	   INNER JOIN 
	   (   
		 SELECT 
			 ssq.DataEntityID
		  ,   ssq.UniqueID 
		  ,   ROW_NUMBER() OVER( ORDER BY ssq.FieldSortOrder ASC) AS StandardAlias_Number 
		 FROM
		 (
		 SELECT 
			 sq.*
		 ,	   ROW_NUMBER() OVER(PARTITION BY DataEntityID ORDER BY sq.FieldSortOrder ASC) AS UniqueID
		 FROM
		 (
			 SELECT DISTINCT 
				  f.DataEntityID
			 ,	  f.FieldID
			 ,	  f.FieldSortOrder
			 ,	  vrdfd.SystemID
			 FROM	
				DMOD.[Hub] AS h
				    INNER JOIN DMOD.[HubBusinessKey] AS hbk
					   on hbk.[HubID] = h.[HubID]
				    INNER JOIN DMOD.[HubBusinessKeyField] AS hbkf
					   on hbkf.[HubBusinessKeyID] = hbk.[HubBusinessKeyID]
				    INNER JOIN DC.[Field] AS f
					   ON hbkf.FieldID = f.FieldID
				   INNER JOIN [DC].[vw_rpt_DatabaseFieldDetail] AS vrdfd
					   ON vrdfd.FieldID = f.FieldID
			   WHERE 
				    h.[HubID] =  @HubID
			   AND
				    vrdfd.[SystemID] = SystemID
		 
		  ) AS sq
		  ) AS ssq
		  WHERE 
			 ssq.UniqueID = 1
	   ) AS sar
			ON sar.DataEntityID = vrdfd.DataEntityID
		WHERE 
			 h.[HubID] =  @HubID
	     AND
			 vrdfd.[SystemID] =  @SystemID
		ORDER BY 
			 f.FieldSortOrder
    
      IF @FieldList != ''
	       SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 7)

	   
		  SELECT @FieldList = @FieldList + '  )
										    )
								    ,2)'

END

ELSE 
BEGIN
    SELECT @FieldList = @FieldList + ''
END

RETURN @FieldList

END

GO
