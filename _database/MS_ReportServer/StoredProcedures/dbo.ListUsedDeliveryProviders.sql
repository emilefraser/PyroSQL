SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[ListUsedDeliveryProviders]
AS
select distinct [DeliveryExtension] from Subscriptions where [DeliveryExtension] <> ''
GO
