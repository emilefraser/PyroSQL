SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[orchastrate].[LoadQueueTable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [orchastrate].[LoadQueueTable] AS' 
END
GO
/*
	EXEC orchastrate.LoadQueueTable 
							@NumbersLoaded = 100
*/
ALTER   PROCEDURE [orchastrate].[LoadQueueTable]
									@NumbersLoaded INT = 0
								
AS 
BEGIN

	TRUNCATE TABLE  orchastrate.QueueTable2

	-- seed the queue table with 10 rows
	INSERT INTO orchastrate.QueueTable2 (SOMEACTION)
	SELECT 'some action ' + CAST(n AS VARCHAR)
	FROM dimension.Number
	WHERE n <= @NumbersLoaded
    
END
GO
