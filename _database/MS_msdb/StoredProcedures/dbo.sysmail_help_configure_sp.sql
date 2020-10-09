SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_help_configure_sp
   @parameter_name nvarchar(256) = NULL
AS
   SET NOCOUNT ON

    SELECT paramname, paramvalue, description
    FROM msdb.dbo.sysmail_configuration
    WHERE paramname = ISNULL(@parameter_name, paramname)

    RETURN(0)

GO
