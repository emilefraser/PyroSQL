SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- ==========================================================================================
-- Author:      Francois Senekal
-- Create date: 2019/01/09
-- Description: Stored proc that hashes the DDL and compares it to the hash created in Azure
-- ==========================================================================================
CREATE PROCEDURE [SECURITY].[sp_DDL_HashKeyComparison]
AS
DECLARE @DynamicKeyword varchar(1000)
SET @DynamicKeyword = 'ODS'
UPDATE  deq
SET [Result] = 'DDLHashError'
FROM [INTEGRATION].[ingress_DDLExecutionQueue] deq
WHERE [DDLHashCheck] !=   CONVERT   (VARCHAR(40),
                                        HASHBYTES   ('SHA1',
                                                     CONVERT(VARCHAR(MAX),
                                                             COALESCE(UPPER(LTRIM(RTRIM([DDLQueryText]))),'') + '|' + 
                                                             COALESCE(UPPER(LTRIM(RTRIM(@DynamicKeyword))),'')
                                                             )  
                                                    )
                                      ,2)

INSERT INTO [LOG].[DDLExecutionLog]
           ([DDLQueryText]
           ,[DDLExecutionQueueID]
           ,[Result]
           ,[ErrorID]
           ,[ErrorMessage]
           ,[CreatedDT])
SELECT      [DDLQueryText]
           ,[DDLExecutionQueueID]
           ,[Result]
           ,[ErrorID]
           ,[ErrorMessage]
           ,[CreatedDT]
FROM [INTEGRATION].[ingress_DDLExecutionQueue]
WHERE [Result] = 'DDLHashError';

GO
