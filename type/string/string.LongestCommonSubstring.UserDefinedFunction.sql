CREATE OR ALTER FUNCTION string.SeekLongestCommonSubstring
(
@FirstString  VARCHAR(MAX),
@SecondString VARCHAR(MAX)
)
/* returns a single row table
it is easy to change to return a string but I wanted the location of the match */
RETURNS @hit TABLE (
            MatchLength       INT,--the length of the match. Not necessarily the length of input
            FirstCharInMatch  INT,--first character of match in first string
            FirstCharInString INT,--first character of match in second string
            CommonString      VARCHAR(8000) --the part of the FirstString successfully matched
            )
AS
BEGIN
    DECLARE @order      INT;
    DECLARE @theGroup   INT;
    DECLARE @sequential INT;
    /* this table is used to do a quirky update to enable a grouping only on sequential characters */
    DECLARE @Scratch TABLE (TheRightOrder INT IDENTITY PRIMARY KEY,TheGroup smallint, Sequential INT,
            FirstOrder smallint, SecondOrder smallint, ch CHAR(1));

    --first we reduce the amount of data to those characters in the first string that have a match 
    --in the second, and where they were.       
    INSERT INTO @Scratch ( TheGroup , FirstOrder, SecondOrder, ch)
       SELECT TheFirst.number - TheSecond.number AS TheGroup
            , TheFirst.number
            , TheSecond.number
            , TheSecond.ch
       FROM /* divide up the first string into a table of characters/sequence */
        (SELECT number, SUBSTRING(@FirstString,number,1) AS ch
           FROM Numbers WHERE number <= LEN(@FirstString)) TheFirst
       INNER JOIN --divide up the second string into a table of characters/sequence
        (SELECT number, SUBSTRING(@SecondString,number,1) AS ch
           FROM Numbers WHERE number <= LEN(@SecondString))  TheSecond
       ON TheFirst.ch= TheSecond.ch --do all valid matches
       ORDER BY TheFirst.number-TheSecond.number, TheSecond.number
    --now @scratch has all matches in the correct order for checking unbroken sequence
    SELECT @order=-1, @theGroup=-1, @sequential=0 --initialise everything
    UPDATE @Scratch --now check by incrementing a value every time a sequence is broken
      SET @sequential = Sequential = 
             CASE --if it is not a sequence from the one before increment the variable
               WHEN SecondOrder = @order+1 AND TheGroup=@theGroup
               THEN @sequential ELSE @sequential + 1 END,
       @order=SecondOrder, 
       @theGroup=TheGroup
    --now we just aggregate it, and choose the first longest match. Easy   
    INSERT INTO @hit (MatchLength,FirstCharInMatch, FirstCharInString,CommonString)
    SELECT TOP(1) ---just the first. You may want more so feel free to change
        COUNT(*)         AS MatchLength,
        MIN(FirstOrder)  AS FirstCharInMatch,
        MIN(SecondOrder) AS FirstCharInString,
        SUBSTRING(@SecondString, MIN(SecondOrder), COUNT(*)) AS CommonString
      FROM @Scratch
      GROUP BY TheGroup, Sequential
      ORDER BY COUNT(*) DESC, MIN(FirstOrder) ASC, MIN(SecondOrder) ASC;
RETURN;
END
GO
