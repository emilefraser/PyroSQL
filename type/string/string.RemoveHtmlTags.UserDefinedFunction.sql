CREATE OR ALTER FUNCTION string.RemoveHtmlTags
        (@HtmlText NVARCHAR(MAX) )
RETURNS NVARCHAR(MAX)
     AS 
  BEGIN 
-- Cleaned Text
DECLARE @cleanText NVARCHAR(MAX)=RTRIM(LTRIM(@HtmlText));

-- HTML Tags
DECLARE @tagStart SMALLINT =PATINDEX('%<%>%', @cleanText);
DECLARE @tagEnd SMALLINT;
DECLARE @tagLength SMALLINT;

-- HTML Entities
DECLARE @entityStart SMALLINT =PATINDEX('%&%;%', @cleanText);
DECLARE @entityEnd SMALLINT;
DECLARE @entityLength SMALLINT;
WHILE @tagStart > 0
    OR 
    @entityStart > 0
BEGIN

-- Remove HTML Tag 
SET @tagStart=PATINDEX('%<%>%', @cleanText);
IF @tagStart > 0 
BEGIN
SET @tagEnd=CHARINDEX('>', @cleanText, @tagStart);
SET @tagLength=(@tagEnd - @tagStart) + 1;
SET @cleanText=STUFF(@cleanText, @tagStart, @tagLength, '');
END;

-- Remove HTML Entity
SET @entityStart=PATINDEX('%&%;%', @cleanText);
IF @entityStart > 0 
BEGIN
SET @entityEnd=CHARINDEX(';', @cleanText, @entityStart);
SET @entityLength=(@entityEnd - @entityStart) + 1;
SET @cleanText=STUFF(@cleanText, @entityStart, @entityLength, '');
END;
END;

SET @cleanText = RTRIM(LTRIM(@cleanText))
RETURN @cleanText;
END;


