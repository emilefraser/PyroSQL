SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysmanagement_add_shared_registered_server]
    @name sysname,
    @server_group_id INT,
    @server_name sysname,
    @description NVARCHAR(2048) = N'',
    @server_type INT,
    @server_id INT OUTPUT
AS
BEGIN
    DECLARE @retval INT

    EXECUTE @retval = sp_sysmanagement_verify_shared_server_type @server_type

    IF (@retval <> 0)
        RETURN(1) -- Failure
    
    IF( (@server_group_id IS NULL) OR 
        (@server_group_id NOT IN (SELECT sg.server_group_id FROM msdb.dbo.sysmanagement_shared_server_groups_internal sg)))
    BEGIN
        RAISERROR (35001, -1, -1)
        RETURN (1)
    END

    IF EXISTS (SELECT * FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal]  sg 
                WHERE @server_group_id = sg.server_group_id AND @server_type <> sg.server_type)
    BEGIN
        RAISERROR (35002, -1, -1)
        RETURN (1)
    END    

    IF (@server_name IS NULL)
    BEGIN
        RAISERROR(14618, -1, 1, '@server_name')
        RETURN(1)   
    END

    set @server_name = LTRIM(@server_name)
    set @server_name = RTRIM(@server_name)

    -- Disallow relative names
    IF ('.' = @server_name) OR
        (1 = CHARINDEX(N'.\', @server_name)) OR
        (1 = CHARINDEX(N'LOCALHOST\', UPPER(@server_name collate SQL_Latin1_General_CP1_CS_AS))) OR
        (UPPER(@server_name collate SQL_Latin1_General_CP1_CS_AS) = 'LOCALHOST') OR
        (UPPER(@server_name collate SQL_Latin1_General_CP1_CS_AS) = '(LOCAL)')
    BEGIN
        RAISERROR (35011, -1, -1)
        RETURN (1)
    END

    IF (UPPER(@@SERVERNAME collate SQL_Latin1_General_CP1_CS_AS) = UPPER(@server_name collate SQL_Latin1_General_CP1_CS_AS))
    BEGIN
        RAISERROR (35012, -1, -1)
        RETURN (1)
    END

    INSERT INTO [msdb].[dbo].[sysmanagement_shared_registered_servers_internal]
        (server_group_id, name, server_name, description, server_type)
    VALUES
        (@server_group_id, @name, @server_name, @description, @server_type)
        
    SELECT @server_id = SCOPE_IDENTITY()
    RETURN (0)
END

GO
