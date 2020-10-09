SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
create procedure dbo.sp_MScleanupmergepublisher
as
    exec sys.sp_MScleanupmergepublisher_internal

GO
