
CREATE PROCEDURE dbo.TableHints
AS

SELECT name
FROM sys.objects
OPTION(FORCE ORDER,HASH JOIN )