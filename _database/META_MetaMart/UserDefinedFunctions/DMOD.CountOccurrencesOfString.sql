SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [DMOD].[CountOccurrencesOfString]
(
    @searchString varchar(max),
    @searchTerm varchar(max)
)
RETURNS INT
AS
BEGIN
    return (LEN(@searchString)-LEN(REPLACE(@searchString,@searchTerm,'')))/LEN(@searchTerm)
END

GO
