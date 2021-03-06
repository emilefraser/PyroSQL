USE [DataManager]
GO
/****** Object:  UserDefinedFunction [DC].[udf_generate_DDL_AZSQL_ExternalTable]    Script Date: 6/15/2020 01:21:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
