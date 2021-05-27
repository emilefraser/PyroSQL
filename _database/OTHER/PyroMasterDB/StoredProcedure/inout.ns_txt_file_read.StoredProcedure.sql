SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[ns_txt_file_read]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[ns_txt_file_read] AS' 
END
GO
/*
DECLARE @t VARCHAR(MAX) 
EXEC ns_txt_file_read 'c:\temp\SampleTextDoc.txt', @t output 
SELECT @t AS [SampleTextDoc.txt]  
*/
ALTER PROC [inout].[ns_txt_file_read]  
    @os_file_name NVARCHAR(256) 
   ,@text_file VARCHAR(MAX) OUTPUT  
/* Reads a text file into @text_file 
* 
* Transactions: may be in a transaction but is not affected 
* by the transaction. 
* 
* Error Handling: Errors are not trapped and are thrown to 
* the caller. 
* 
* Example: 
    declare @t varchar(max) 
    exec ns_txt_file_read 'c:\temp\SampleTextDoc.txt', @t output 
    select @t as [SampleTextDoc.txt] 
* 
* History: 
* WHEN       WHO        WHAT 
* ---------- ---------- --------------------------------------- 
* 2007-02-06 anovick    Initial coding 
**************************************************************/  
AS  
DECLARE @sql NVARCHAR(MAX) 
      , @parmsdeclare NVARCHAR(4000)  

SET NOCOUNT ON  

SET @sql = 'select @text_file=(select * from openrowset ( 
           bulk ''' + @os_file_name + ''' 
           ,SINGLE_CLOB) x 
           )' 

SET @parmsdeclare = '@text_file varchar(max) OUTPUT'  

EXEC sp_executesql @stmt = @sql 
                 , @params = @parmsdeclare 
                 , @text_file = @text_file OUTPUT 
GO
