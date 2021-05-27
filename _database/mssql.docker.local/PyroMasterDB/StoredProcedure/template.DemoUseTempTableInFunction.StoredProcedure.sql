SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[template].[DemoUseTempTableInFunction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [template].[DemoUseTempTableInFunction] AS' 
END
GO
ALTER PROCEDURE [template].[DemoUseTempTableInFunction]
AS
BEGIN

CREATE TABLE #temp (id INT)

INSERT INTO #temp VALUES (1),(2),(3)

CREATE SYNONYM temp_table_synonym FOR #temp

/*
CREATE FUNCTION fn_select_temp_table ()
RETURNS TABLE
AS
RETURN
(
 SELECT * FROM temp_table_synonym
)

SELECT * FROM fn_select_temp_table()
*/

END
GO
