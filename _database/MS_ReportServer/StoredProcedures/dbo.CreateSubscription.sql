SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[CreateSubscription]
@id uniqueidentifier,
@Locale nvarchar (128),
@Report_Name nvarchar (425),
@ReportZone int,
@OwnerSid varbinary (85) = NULL,
@OwnerName nvarchar(260),
@OwnerAuthType int,
@DeliveryExtension nvarchar (260) = NULL,
@InactiveFlags int,
@ExtensionSettings ntext = NULL,
@ModifiedBySid varbinary (85) = NULL,
@ModifiedByName nvarchar(260),
@ModifiedByAuthType int,
@ModifiedDate datetime,
@Description nvarchar(512) = NULL,
@LastStatus nvarchar(260) = NULL,
@EventType nvarchar(260),
@MatchData ntext = NULL,
@Parameters ntext = NULL,
@DataSettings ntext = NULL,
@Version int

AS

-- Create a subscription with the given data.  The name must match a name in the
-- Catalog table and it must be a report type (2) or linked report (4)

DECLARE @Report_OID uniqueidentifier
DECLARE @OwnerID uniqueidentifier
DECLARE @ModifiedByID uniqueidentifier
DECLARE @TempDeliveryID uniqueidentifier

--Get the report id for this subscription
select @Report_OID = (select [ItemID] from [Catalog] where [Catalog].[Path] = @Report_Name and ([Catalog].[Type] = 2 or [Catalog].[Type] = 4 or [Catalog].[Type] = 8 or [Catalog].[Type] = 13))

EXEC GetUserID @OwnerSid, @OwnerName, @OwnerAuthType, @OwnerID OUTPUT
EXEC GetUserID @ModifiedBySid, @ModifiedByName, @ModifiedByAuthType, @ModifiedByID OUTPUT

if (@Report_OID is NULL)
begin
RAISERROR('Report Not Found', 16, 1)
return
end

Insert into Subscriptions
    (
        [SubscriptionID],
        [OwnerID],
        [Report_OID],
        [ReportZone],
        [Locale],
        [DeliveryExtension],
        [InactiveFlags],
        [ExtensionSettings],
        [ModifiedByID],
        [ModifiedDate],
        [Description],
        [LastStatus],
        [EventType],
        [MatchData],
        [LastRunTime],
        [Parameters],
        [DataSettings],
    [Version]
    )
values
    (@id, @OwnerID, @Report_OID, @ReportZone, @Locale, @DeliveryExtension, @InactiveFlags, @ExtensionSettings, @ModifiedByID, @ModifiedDate,
     @Description, @LastStatus, @EventType, @MatchData, NULL, @Parameters, @DataSettings, @Version)
GO
