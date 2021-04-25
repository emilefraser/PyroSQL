SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[verbose]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[verbose] AS' 
END
GO

	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-12-17 BvdB wrapper proc for enabling debug info
exec debug
*/
ALTER   PROCEDURE [dbo].[verbose]
	@enable bit = 1 
AS
BEGIN
	SET NOCOUNT ON;
	
	exec betl.dbo.reset 

	if @enable =1
		exec betl.dbo.setp 'log_level', 'verbose'

    footer:
	exec my_info
END












GO
