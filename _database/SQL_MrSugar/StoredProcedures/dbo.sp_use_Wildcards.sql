SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE dbo.sp_use_Wildcards
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
