SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Karl Dinkelmann / Francois Senekal
-- Create Date: 11 Sep 2019
-- Description: Set IsActive = 0 for all LastSeenDT more than 7 days ago
-- =============================================
CREATE PROCEDURE [DC].[sp_update_DataCatalogDeactivate]
AS

--TODO - Convert the "7" days to a global parameter
--Don't run this with Offset days of 0 - it will mark everything as Inactive
DECLARE @OffsetDays INT = 7


UPDATE DC.[Database]
SET  IsActive = 0,
	 UpdatedDT = GETDATE()
WHERE DATEADD(DAY,@OffsetDays,ISNULL(LastSeenDT,'1990/01/01')) < GETDATE()

UPDATE DC.[Schema]
SET  IsActive = 0,
	 UpdatedDT = GETDATE()
WHERE DATEADD(DAY,@OffsetDays,ISNULL(LastSeenDT,'1990/01/01')) < GETDATE()

UPDATE DC.[DataEntity]
SET  IsActive = 0,
	 UpdatedDT = GETDATE()
WHERE DATEADD(DAY,@OffsetDays,ISNULL(LastSeenDT,'1990/01/01')) < GETDATE()

UPDATE DC.[Field]
SET  IsActive = 0,
	 UpdatedDT = GETDATE()
WHERE DATEADD(DAY,@OffsetDays,ISNULL(LastSeenDT,'1990/01/01')) < GETDATE()



GO
