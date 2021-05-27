SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[log_error]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[log_error] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
2018-01-02 BvdB centralize error handling. Allow custom code to integrate external logging
exec dbo.log_error 0, 'Something went wrong', 11 , 0, 0, 'aap'
-----------------------------------------------------------------------------------------------
*/
ALTER   PROCEDURE [dbo].[log_error](
	    --@batch_id as int
		@transfer_id as int
		, @msg as varchar(255) 
		, @severity as int 
		, @number as int = null 
		, @line as int = null 
		, @procedure as varchar(255) = null
		)
AS
BEGIN
	SET NOCOUNT ON;
	declare @batch_id as int
		,@sp_name as varchar(255) = object_name(@@PROCID)
	select @batch_id = batch_id from dbo.Transfer where transfer_id = @transfer_id 
	
	set @msg = '-- Error: '+ convert(varchar(255), isnull(@msg,'')) 
	print @msg

	insert into dbo.Transfer_log(log_dt, msg, transfer_id,log_type_id)
	values( getdate(), @msg, @transfer_id, 50) 

--	exec dbo.log @transfer_id, 'header', '?(?) severity ? ?', @sp_name ,@transfer_id, @severity, @msg
    INSERT INTO [dbo].[Error]([error_code],[error_msg],[error_line],[error_procedure],[error_severity],[transfer_id]) 
    VALUES (
    [tool].Int2Char(@number)
    , isnull(@msg,'')
    , [tool].Int2Char(@line) 
    ,  isnull(@procedure,'')
    , [tool].Int2Char(@severity)
    , [tool].Int2Char(@transfer_id))
	declare @last_error_id as int = SCOPE_IDENTITY()
    update dbo.[Transfer] set transfer_end_dt = getdate(), status_id = 200
    , last_error_id = @last_error_id
    where transfer_id = @transfer_id
    update dbo.[Batch] set batch_end_dt = getdate(), status_id = 200
    , last_error_id = @last_error_id
    where batch_id = @batch_id
       
--	exec dbo.log @transfer_id, 'ERROR' , @msg
	
   footer:
END












GO
