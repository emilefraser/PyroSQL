SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

    CREATE procedure [dbo].[sp_sql_logins] AS
    select name, password_hash, is_disabled from sys.sql_logins
    

GO
