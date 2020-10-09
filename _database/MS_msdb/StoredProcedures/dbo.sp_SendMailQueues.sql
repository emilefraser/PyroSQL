SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
-- sp_SendMailQueues : Writes a send mail request to the queue.
--
CREATE  PROCEDURE sp_SendMailQueues
    @message_data      varchar(max) -- The request in XML
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @contract_name nvarchar(128)
    DECLARE @message_type nvarchar(128)
    DECLARE @retValue int

    SET @message_type = '{//www.microsoft.com/databasemail/messages}SendMail'
    SET @contract_name = '//www.microsoft.com/databasemail/contracts/SendMail/v1.0'

    --Writes the message to the queue
    EXEC @retValue = sp_SendMailMessage @contract_name, @message_type, @message_data

    RETURN @retValue
END

GO
