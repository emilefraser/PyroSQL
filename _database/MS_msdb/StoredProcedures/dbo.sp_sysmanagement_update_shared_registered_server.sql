SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysmanagement_update_shared_registered_server]
    @server_id INT,
    @server_name sysname = NULL,
    @description NVARCHAR(2048) = NULL
AS
BEGIN
    IF (@server_id IS NULL)
    BEGIN
        RAISERROR (35006, -1, -1)
        RETURN(1)
    END
    
    IF NOT EXISTS (SELECT * FROM [msdb].[dbo].[sysmanagement_shared_registered_servers_internal] WHERE server_id = @server_id)
    BEGIN
        RAISERROR (35007, -1, -1)
        RETURN(1)
    END

    IF (@server_name IS NULL)
    BEGIN
        SET @server_name = (select server_name FROM [msdb].[dbo].[sysmanagement_shared_registered_servers_internal] WHERE server_id = @server_id)
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

    UPDATE [msdb].[dbo].[sysmanagement_shared_registered_servers_internal]
        SET server_name = ISNULL(@server_name, server_name),
            description = ISNULL(@description, description)
    WHERE
        server_id = @server_id
    RETURN (0)
END

GO
