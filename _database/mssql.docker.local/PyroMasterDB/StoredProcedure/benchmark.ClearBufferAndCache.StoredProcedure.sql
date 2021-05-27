SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[ClearBufferAndCache]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [benchmark].[ClearBufferAndCache] AS' 
END
GO
/* 
	Written By  : Emile Fraser
	Date		: 2021-05-20
	Description : Clears out all cache and buffers for fresh query run
*/
ALTER PROCEDURE [benchmark].[ClearBufferAndCache]
AS 
BEGIN

	-- Start off by running the CHECKPOINT command to clean out dirty pages from buffer cache
	CHECKPOINT;

	-- Clears out the clean buffer cache
	DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS;

	-- Remove execution plans from procedure cache
	DBCC FREEPROCCACHE WITH NO_INFOMSGS;

	-- Clears out system caches too
	DBCC FREESYSTEMCACHE ('ALL') WITH MARK_IN_USE_FOR_REMOVAL 


END
GO
