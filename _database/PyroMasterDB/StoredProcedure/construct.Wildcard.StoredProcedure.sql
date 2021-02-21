SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[Wildcard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[Wildcard] AS' 
END
GO

ALTER   PROCEDURE [construct].[Wildcard]
AS
BEGIN

	SELECT 
		name
	FROM  
		sys.objects
	WHERE
		object_id LIKE 'PG-42%' --PG-42445-01 PG-42600-02
	OR
		object_id LIKE '%G-42%'--  PG-42445-01 RG-42900-03
	OR 
		object_id LIKE 'RG-_____-__' -- RG-85000-01 RG-42900-03
	OR
		object_id LIKE 'RG-[8-9]____-__' --  RG-85000-01, RG-95000-01
	OR
		object_id LIKE '[O-Z]G%' -- RG, PG, but not AG, FG, etc. 

END;
GO
