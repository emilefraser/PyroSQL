SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_configure_sp
   @parameter_name nvarchar(256),
   @parameter_value nvarchar(256),
   @description nvarchar(256) = NULL
AS
   SET NOCOUNT ON
   
   IF (@description IS NOT NULL)
      UPDATE msdb.dbo.sysmail_configuration
      SET paramvalue=@parameter_value, description=@description
      WHERE paramname=@parameter_name
   ELSE
      UPDATE msdb.dbo.sysmail_configuration
      SET paramvalue=@parameter_value
      WHERE paramname=@parameter_name

   RETURN(0)

GO
