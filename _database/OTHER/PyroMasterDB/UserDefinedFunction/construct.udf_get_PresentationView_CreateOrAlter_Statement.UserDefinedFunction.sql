SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[udf_get_PresentationView_CreateOrAlter_Statement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- =========================================================================
-- Author:      Emile Fraser
-- Create Date: 2019/11/13
-- Last Update: 2019/11/13
-- Description: Returns the code converting Dim/Facts into pres views
-- ==========================================================================
CREATE   FUNCTION [construct].[udf_get_PresentationView_CreateOrAlter_Statement](
	@schemaName AS SYSNAME
,	@viewName AS SYSNAME

)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @lf CHAR(1) = CHAR(13)
	DECLARE @tab CHAR(1) = CHAR(9)

	DECLARE @fullViewName SYSNAME =  QUOTENAME(@schemaName)  + ''.'' +  QUOTENAME(@viewName)
	DECLARE @fullPresentationViewName SYSNAME = (SELECT REPLACE(@fullViewName, ''vw_'', ''vw_pres_''))
	DECLARE @sqlCommand VARCHAR(MAX) = ''''
	DECLARE @sqlColumns VARCHAR(MAX) = ''''
	DECLARE @sqlFrom VARCHAR(MAX) = ''''
	DECLARE @sqlWhere VARCHAR(MAX) = ''''
	DECLARE @sqlStatement VARCHAR(MAX) = ''''


	/*************************
		  COMMAND BLOCK
	*************************/
	SET @sqlCommand = ''CREATE OR ALTER VIEW '' + @fullPresentationViewName + @lf
	SET @sqlCommand = @sqlCommand + ''AS'' + @lf
	SET @sqlCommand = @sqlCommand + ''SELECT'' + @lf

	/*************************
		  COLUMNS BLOCK
	*************************/
	SELECT @sqlColumns = 		
		@sqlColumns + @tab 
						+ QUOTENAME(c.name) + '' AS '' 
						+ QUOTENAME(REPLACE(IM.udf_get_FieldName_Propercase(dbo.CamelCaseFieldName_To_SpaceInclusiveNames(c.name)),''  '','' ''))
						+ @lf + IIF(vc.TotalColumns != c.column_id,  '','', '''')
	FROM 
		sys.views AS v
	INNER JOIN 
		sys.schemas AS s
	ON 
		s.schema_id = v.schema_id
	INNER JOIN 
		sys.columns as c
	ON 
		v.object_id = c.object_id
	INNER JOIN (	  
			SELECT 
				object_id
			,	COUNT(1) AS TotalColumns
			FROM 
				sys.columns 
			WHERE 
				object_id = object_id(@fullViewName)
			GROUP BY 
				object_id
	) AS vc
	ON
		vc.object_id = v.object_id

	/*************************
			FROM BLOCK
	*************************/
	SET @sqlFrom = ''FROM '' + @lf + @tab + @fullViewName + @lf

	SET @sqlStatement = @sqlCommand + @sqlColumns + @sqlFrom + @sqlWhere
		
	RETURN @sqlStatement

END

' 
END
GO
