IF OBJECT_ID('[dbo].[StripProperHtmlTags]') IS NOT NULL 
DROP  FUNCTION  [dbo].[StripProperHtmlTags] 
GO
--#################################################################################################
-- 2017-05-04 10:44:28.315 SFCCN\lizaguirre SFCCN\lizaguirre
-- Context: HorizonSSEG | SUNPRDBI01 ODS
--#################################################################################################
CREATE FUNCTION dbo.StripProperHtmlTags
        (@HtmlText XML )
RETURNS NVARCHAR(MAX)
     AS 
  BEGIN 
 RETURN (
         SELECT contents.value('.', 'nvarchar(max)') 
           FROM ( 
                 SELECT contents = chunks.chunk.query('.') FROM @HtmlText.nodes('/') AS chunks(chunk) 
                ) doc 
        )
END
GO
grant execute on dbo.StripProperHtmlTags to public



