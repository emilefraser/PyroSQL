SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE dbo.sp_call_WindowFunction
AS
BEGIN

	SELECT
		[object_id]
,		[name]
,		ROW_NUMBER() OVER (PARTITION BY [name] ORDER BY [object_id])	AS	[rownum]
,		SUM([object_id]) OVER (PARTITION BY [name])						AS	[object_totalid]
	FROM
		sys.tables;

END;
GO
