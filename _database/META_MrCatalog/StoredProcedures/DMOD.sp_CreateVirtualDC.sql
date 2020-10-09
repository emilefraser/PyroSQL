SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



-- ====================================================================================================
-- Author:      Wium Swart
-- Create Date: 8 Sep 2019
-- Description: Creates the Virtual DC in the DMOD Schema
-- ====================================================================================================
-- Sample execution:
-- EXEC [DMOD].[sp_CreateVirtualDC] 7, 1001

--/*

CREATE PROCEDURE [DMOD].[sp_CreateVirtualDC]
AS



TRUNCATE TABLE [DataManager].dmod.[Schema_VirtualDC]
TRUNCATE TABLE [DataManager].dmod.[DataEntity_VirtualDC]
TRUNCATE TABLE [DataManager].dmod.[Field_VirtualDC]
TRUNCATE TABLE [DataManager].dmod.[FieldRelation_VirtualDC]


 DECLARE @HubidTable Table
    (
        RowNumber int IDENTITY(1,1),
        HubID int
    )
	insert into @HubidTable
	select hubid from dmod.Hub WHERE IsActive = 1

 DECLARE @hubid int
 DECLARE @RowCount int = 1
    DECLARE @MaxRows int  = (SELECT COUNT(*) FROM @HubidTable)

 

    WHILE @RowCount <= @MaxRows
        BEGIN
           
		   SET @hubid = (select hubid from @HubidTable where ROWNUMBER = @RowCount)
		   PRINT 'Processing Hub... ' + CONVERT(VARCHAR, @hubid)
           exec [DMOD].[sp_CreateStageTableInVirtualDC1] @hubid,1
		   PRINT 'Done [DMOD].[sp_CreateStageTableInVirtualDC1] ' + CONVERT(VARCHAR, @hubid)
		   exec [DMOD].[sp_CreateHubTableInVirtualDC1] @hubid,2
		   PRINT 'Done [DMOD].[sp_CreateHubTableInVirtualDC1] ' + CONVERT(VARCHAR, @hubid)
           exec [DMOD].[sp_CreatePKFKLinkTableInVirtualDC1] @hubid,2
		   PRINT 'Done [DMOD].[sp_CreatePKFKLinkTableInVirtualDC1] ' + CONVERT(VARCHAR, @hubid)
           exec [DMOD].[sp_CreateSatelliteTableInVirtualDC1] @hubid,2
		   PRINT 'Done [DMOD].[sp_CreateSatelliteTableInVirtualDC1] ' + CONVERT(VARCHAR, @hubid)

		  --select hubid from @HubidTable where ROWNUMBER = @RowCount

            SET @RowCount = @RowCount + 1
        END;


GO
