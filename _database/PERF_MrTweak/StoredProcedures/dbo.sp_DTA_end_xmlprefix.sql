SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create procedure [dbo].[sp_DTA_end_xmlprefix]
as
begin
	declare @endTags nvarchar(128)
	set @endTags = N'</AnalysisReport></DTAOutput></DTAXML>'
	select @endTags
end

GO
