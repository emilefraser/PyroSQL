SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE [dbo].[sp_validate_user]
    @send_request_user sysname,
    @user_sid varbinary(85) OUTPUT
  WITH EXECUTE AS 'dbo'
AS
BEGIN
    SET NOCOUNT ON
    -- And make sure ARITHABORT is on. This is the default for yukon DB's
    SET ARITHABORT ON

    declare @groupSid varbinary(85)
    declare @temp table
    ([account name] sysname, 
    [type] char(8),
    [privilege] char(9),
    [mapped login name] sysname,
    [permission path] sysname null)

    declare @sidlist table
    ([account name] sysname,
     [accountsid] varbinary(85) null,
     [permission path] sysname null)

    SET @user_sid = NULL
    SET @groupSid = NULL

    -- Lookup the Windows Group membership, if any, that grants this
    -- user access to SQL Server. xp_logininfo may fail if the sql
    -- server service account cannot talk to the domain controller to
    -- validate the windows username, or it may fail if the
    -- @send_request_user is not a valid windows user or group name.
    BEGIN TRY 
        insert @temp exec master.dbo.xp_logininfo @send_request_user, 'all'
        -- For a given account name, Get account name -> group accountsid mapping to a temp table variable
        insert @sidlist
            select [account name], suser_sid([permission path]),[permission path]
            from @temp
    END TRY
    BEGIN CATCH
        RETURN 2
    END CATCH

    -- for a given account name, there has to be atleast one account sid that is not null and
    -- there has to be atleast one mail profile for the list of account sids
    IF ((EXISTS(SELECT [account name] 
                FROM @sidlist
                WHERE accountsid is not NULL)
    AND (EXISTS(SELECT profile_id 
                FROM msdb.dbo.sysmail_principalprofile pp, @sidlist s
                WHERE s.accountsid = pp.principal_sid))))

    BEGIN
        -- Get the first account's sid that meets following criteria
        --  1) return first default profile (if available)
        --  2) if no default profile is  defined, then return the first non-default profile for this account
        SELECT TOP 1  @groupSid = accountsid 
        FROM @sidlist s, msdb.dbo.sysmail_principalprofile pp
        WHERE s.accountsid is not NULL
        AND s.accountsid = pp.principal_sid
        ORDER BY is_default DESC
    END

    -- Lookup a default profile for the Group. If there is one,
    -- then use the group's mail profile.
    IF (@groupSid IS NOT NULL)
    BEGIN
        SET @user_sid = @groupSid
        RETURN 0
    END
    RETURN 1
END

GO
