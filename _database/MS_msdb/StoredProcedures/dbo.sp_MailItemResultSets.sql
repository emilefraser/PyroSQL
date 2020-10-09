SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
-- sp_MailItemResultSets : 
--  Sends back multiple rowsets with the mail items data
CREATE PROCEDURE sp_MailItemResultSets
    @mailitem_id            INT,
    @profile_id             INT,
    @conversation_handle    uniqueidentifier,
   @service_contract_name  NVARCHAR(256),
   @message_type_name      NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON
   --
   -- Send back multiple rowsets with the mail items data

   ----
   -- 1) MessageTypeName
   SELECT @message_type_name  as 'message_type_name',
      @service_contract_name as 'service_contract_name',
      @conversation_handle   as 'conversation_handle',
      @mailitem_id           as 'mailitem_id'

   -----
   -- 2) The mail item record from sysmail_mailitems.
   SELECT 
      mi.mailitem_id,
      mi.profile_id,
      (SELECT name FROM msdb.dbo.sysmail_profile p WHERE p.profile_id = mi.profile_id) as 'profile_name',
      mi.recipients,
      mi.copy_recipients,
      mi.blind_copy_recipients,
      mi.subject,
      mi.body, 
      mi.body_format, 
      mi.importance,
      mi.sensitivity,
      ISNULL(sr.send_attempts, 0) as retry_attempt,
      ISNULL(mi.from_address, '') as from_address,
      ISNULL(mi.reply_to, '')     as reply_to
   FROM sysmail_mailitems as mi
      LEFT JOIN sysmail_send_retries as sr
         ON sr.mailitem_id = mi.mailitem_id 
   WHERE mi.mailitem_id = @mailitem_id

   -----
   -- 3) Account information 
   SELECT a.account_id,
         a.name
   FROM msdb.dbo.sysmail_profileaccount as pa
   JOIN msdb.dbo.sysmail_account as a
      ON pa.account_id = a.account_id
   WHERE pa.profile_id = @profile_id
   ORDER BY pa.sequence_number 

   -----
   -- 4) Attachments if any
   SELECT attachment_id,
      mailitem_id,
      filename,
      filesize,
      attachment
   FROM sysmail_attachments
   WHERE mailitem_id = @mailitem_id
   

   RETURN 0
END

GO
