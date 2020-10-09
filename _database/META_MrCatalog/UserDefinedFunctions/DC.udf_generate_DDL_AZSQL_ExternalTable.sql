SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:     Emile FRaser
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
--SELECT [DC].[udf_generate_DDL_AZSQL_ExternalTable](47064)
--SELECT [DC].[udf_generate_DDL_AZSQL_ExternalTable](47325)
CREATE FUNCTION [DC].[udf_generate_DDL_AZSQL_ExternalTable](
	@Source_DataEntityID AS INT
)

RETURNS VARCHAR(MAX) 
AS
BEGIN
    -- Declare the return variable here
    DECLARE @ExternalDataTableSQL AS VARCHAR(MAX) = ''
	
	 SELECT @ExternalDataTableSQL = @ExternalDataTableSQL + [DC].[udf_generate_DDL_AZSQL_ExternalTable_Drop](@Source_DataEntityID)
	 SELECT @ExternalDataTableSQL = @ExternalDataTableSQL + [DC].[udf_generate_DDL_AZSQL_ExternalTable_Create](@Source_DataEntityID)

    -- Return the result of the function
    RETURN @ExternalDataTableSQL
END

GO
