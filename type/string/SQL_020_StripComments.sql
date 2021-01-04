IF OBJECT_ID('[dbo].[StripComments]') IS NOT NULL 
DROP  FUNCTION  [dbo].[StripComments] 
GO
CREATE FUNCTION StripComments(@StringToStrip varchar(max))
RETURNS varchar(max)
AS
BEGIN
    -- This bit strips out block comments.  We need to strip them out BEFORE
    -- single line comments (like this one), because you could theoretically have
    -- a block comment like this:
    /* My Comment
    -- Is malformed */

    -- Variables to hold the first and last character's positions in the "next" block 
    -- comment in the string
    SET @StringToStrip = REPLACE(@StringToStrip,CHAR(13),'')
    DECLARE @CodeBlockStart int, @CodeBlockEnd int
    SET @CodeBlockStart = PATINDEX(CHAR(37) + CHAR(47) + CHAR(42)  + CHAR(37), @StringToStrip) --this is %/*%

    -- Loop as long as we still have comments to exorcise ;)
    WHILE @CodeBlockStart > 0
    BEGIN
        -- Grab the last character in the code block by searching for the first incidence
        -- of */ (close comment) in the string.
        SET @CodeBlockEnd = PATINDEX(CHAR(37) + CHAR(42)  + CHAR(47) +  CHAR(37) , @StringToStrip) --this is %*/%
       --is there a ghost slash asterisk without a match?
        IF @CodeBlockEnd = 0 
        BEGIN -- if we get here the SQL dosn't have a closing '*/' -- So we just delete it 
        SET @CodeBlockEnd = @CodeBlockStart + 2 
        END
        ELSE IF @CodeBlockEnd < @CodeBlockStart -- if we get a */ before /* we delete it
        BEGIN
        SET @CodeBlockStart = @CodeBlockEnd -2
        END
        -- "Cut" out the comment by concatenating everything the the "left" and "right"
        -- of the comment
        SET @StringToStrip = LEFT(@StringToStrip, @CodeBlockStart - 1)
                                + RIGHT(@StringToStrip, LEN(@StringToStrip) - (@CodeBlockEnd + 1))
    
        -- Fetch the first character's position in the next comment block, if there is one.
        SET @CodeBlockStart = PATINDEX(CHAR(37) + CHAR(47) + CHAR(42)  + CHAR(37), @StringToStrip)
    END

    -- Once code blocks are out, we can remove any lines commented by double dashes (like this one)
    -- Variables to hold the first and last character's position in the "next" code block.
    DECLARE @DoubleDashStart int, @DoubleDashLineEnd int

    -- Grab the first double-dash (if there is one)
    SET @DoubleDashStart = PATINDEX(CHAR(37) + CHAR(45) + CHAR(45) + CHAR(37), @StringToStrip)
    WHILE @DoubleDashStart > 0
    BEGIN
        -- Search for the first "new line" AFTER the first "double dash"
        -- We can use CHAR(13) and CHAR(10) to find the new line.
        -- Since PATINDEX doesn't have a "start" character, and we need to find
        -- the first new line AFTER the double dash, we will search all characters
        -- after the double dash for the new line.
        SET @DoubleDashLineEnd = PATINDEX('%' + CHAR(10) + '%',
                                        RIGHT(@StringToStrip, LEN(@StringToStrip) - (@DoubleDashStart)))
                                 + @DoubleDashStart
                                        
        -- "Cut" out the comment, as was done with the block comments.
        SET @StringToStrip =    LEFT(@StringToStrip, @DoubleDashStart - 1) +
                                RIGHT(@StringToStrip, LEN(@StringToStrip) - @DoubleDashLineEnd)
    
        -- Check for the next incidence of a double dash, if there is one.
        SET @DoubleDashStart = PATINDEX(CHAR(37) + CHAR(45) + CHAR(45) + CHAR(37), @StringToStrip)
    END

    -- Return the uncommented string    
    RETURN @StringToStrip
END

GO