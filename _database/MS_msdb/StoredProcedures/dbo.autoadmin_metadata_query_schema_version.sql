SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE autoadmin_metadata_query_schema_version
        @current_schema_version			INT OUT,
        @min_schema_version_supported	INT OUT
AS
BEGIN
    SET NOCOUNT ON

    SET @current_schema_version = dbo.fn_autoadmin_schema_version()
    SET @min_schema_version_supported = dbo.fn_autoadmin_min_schema_version()
END

GO
