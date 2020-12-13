SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 25/10/2014
-- Description: www.4sln.com
-- =============================================
CREATE FUNCTION dbo.fn_XmlToJson_Get
(
@XmlData XML
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
RETURN
 (SELECT STUFF(
  (SELECT
   *
   FROM
    (SELECT
      ',{'+
        STUFF(
          (SELECT
            ',"'+
             COALESCE(b.c.value('local-name(.)', 'NVARCHAR(MAX)'),'')+'":"'+ b.c.value('text()[1]','NVARCHAR(MAX)') +'"'
           FROM x.a.nodes('*') b(c) FOR XML PATH(''),TYPE).value('(./text())[1]','NVARCHAR(MAX)'),1,1,'')
       +'}'
     FROM @XmlData.nodes('/root/*') x(a)) JSON(theLine)
    FOR XML PATH(''),TYPE).value('.','NVARCHAR(MAX)' )
   ,1,1,''))
END
GO


SELECT (SELECT TOP 10 *
   FROM dbo.[DummyData]
   FOR XML path, root) AS MyRow into #t1
  
select dbo.fn_XmlToJson_Get(MyRow) from #t1