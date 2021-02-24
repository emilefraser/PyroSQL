CREATE OR ALTER FUNCTION string.RemoveProperHtmlTags
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

