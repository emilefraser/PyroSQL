use master;
GO
IF OBJECT_ID('[dbo].[StripReplaceASCII_ITVF]') IS NOT NULL 
DROP  FUNCTION  [dbo].[StripReplaceASCII_ITVF] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--StripReplace_ASCII_ITVF removes specific characters from a string.
--usage for ITVF requires cross apply or cross join
--ie SELECT TOP 100 fn.CleanedText,MRNumber From EDLogDetail CROSS APPLY dbo.StripReplace_ASCII_ITVF(MRNumber) fn WHERE MRNumber IS NOT NULL
--#################################################################################################
CREATE FUNCTION dbo.StripReplaceASCII_ITVF(@OriginalText VARCHAR(8000))
RETURNS TABLE WITH SCHEMABINDING AS
RETURN

WITH
	E1(N) AS (select 1 from (values (1),(1),(1),(1),(1),(1),(1),(1),(1),(1))dt(n)),
	E2(N) AS (SELECT 1 FROM E1 a, E1 b), --10E+2 or 100 rows
	E4(N) AS (SELECT 1 FROM E2 a, E2 b), --10E+4 or 10,000 rows max
	Tally(N) AS 
	(
		SELECT  ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4
	),HighAsciiReplaced 
  AS
  (
	 
select STUFF(
(	 
	SELECT 
    CASE 
    --WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) IN (9,10,13)         THEN SUBSTRING(@OriginalText,Tally.N,1) --tab,lf,cr
    --WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 32 AND  127  THEN SUBSTRING(@OriginalText,Tally.N,1)
    --WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) <= 32  THEN ''
    --WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) >= 128 THEN '' 
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 192 AND 197 THEN 'A' -- ÀÁÂÃÄÅ -->A  192 to 197
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 198 THEN 'AE'              --Æ      -->AE 198
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 199 THEN 'C'               --Ç      -->C  199
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 200 AND 203 THEN 'E' --ÈÉÊË   -->E  200 to 203
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 204 AND 207 THEN 'I'               --ÌÍÎÏ   -->I  204 to 207
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 208 THEN 'D'               --Ð      -->D  208
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 209 THEN 'N'               --Ñ      -->N  209
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1))  BETWEEN 210 AND 214 THEN 'O' --ÒÓÔÕÖ  -->O  210 to 214
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 215 THEN '*'               --×      -->x or *  215 (multiplication operator)
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 216 THEN '0'               --Ø      -->0  216 zero or capital "o"?
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 217 AND 220 THEN 'U' --ÙÚÛÜ   -->U  217 to 220
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 221 THEN 'Y'               --Ý      -->Y  221
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 222 THEN ' '               --Þ      -->   222
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 223 THEN ' '               --ß      -->   223
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 224 AND 229 THEN 'a' --àáâãäå -->a  224 to 229
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 230 THEN 'ae'              --æ      -->ae 230
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 231 THEN 'c'               --ç      -->c  231
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 232 AND 235 THEN 'e' --èéêë   -->e  232 to 235
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 236 AND 239 THEN 'i' --ìíîï   -->i  236 to 239
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 240 THEN 'o'               --ð      -->   240
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 240 THEN 'n'               --ñ      -->n  241
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 242 AND 246 THEN 'o' --òóôõö  -->o  242 to 246
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 247 THEN '/'               --÷      -->/  247 (division operator)
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 248 THEN '0'               --ø      -->0  248 zero or capital "o"?
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) BETWEEN 249 AND 252 THEN 'u' --ùúûü   -->u  249 to 252
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 253 THEN 'y'               --ý      -->y  253
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 254 THEN ' '               --þ      -->   254
    WHEN ASCII(SUBSTRING(@OriginalText,Tally.N,1)) = 255 THEN 'y'               --ÿ      -->y  255
    ELSE SUBSTRING(@OriginalText,Tally.N,1)
  END
	FROM Tally
  WHERE Tally.N <= len(@OriginalText) -- added by ajb
	FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,1,'') as CleanedText 
)
SELECT CleanedText FROM HighAsciiReplaced
GO

SELECT * FROM [dbo].[StripReplaceASCII_ITVF]('ÀAlbèert ËEîinstêeiìn ÌInstìitúutëe')