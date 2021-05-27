SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dec_nesting]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[dec_nesting] AS' 
END
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB decreate nesting level (e.g. for logging). 
-- DEPRECATED. Use @@NESTLEVEL instead

log_level
10 ERROR
20 INFO : show progress in current proc
30 DEBUG: : show progress in current proc and invoked procs. 
*/
ALTER   PROCEDURE [dbo].[dec_nesting] 
as 
begin 
	declare @nesting as smallint 
	exec dbo.getp 'nesting', @nesting output
	set @nesting = isnull(@nesting-1, 0) 
	exec dbo.setp  'nesting', @nesting
end











GO
