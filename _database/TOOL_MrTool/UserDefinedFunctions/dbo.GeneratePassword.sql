SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   FUNCTION dbo.GeneratePassword ()
RETURNS varchar(10)
AS
BEGIN
  DECLARE @randInt int;
  DECLARE @NewCharacter varchar(1); 
  DECLARE @NewPassword varchar(10); 
  SET @NewPassword='';

  --6 random characters
  WHILE (LEN(@NewPassword) <6)
  BEGIN
    select @randInt=dbo.randbetween(48,122)
	--      0-9           < = > ? @ A-Z [ \ ]                   a-z      
    IF @randInt<=57 OR (@randInt>=60 AND @randInt<=93) OR (@randInt>=97 AND @randInt<=122)
    Begin
      select @NewCharacter=CHAR(@randInt)
      select @NewPassword=CONCAT(@NewPassword, @NewCharacter)
    END
  END

  --Ensure a lowercase
  select @NewCharacter=CHAR(dbo.randbetween(97,122))
  select @NewPassword=CONCAT(@NewPassword, @NewCharacter)
  
  --Ensure an upper case
  select @NewCharacter=CHAR(dbo.randbetween(65,90))
  select @NewPassword=CONCAT(@NewPassword, @NewCharacter)
  
  --Ensure a number
  select @NewCharacter=CHAR(dbo.randbetween(48,57))
  select @NewPassword=CONCAT(@NewPassword, @NewCharacter)
  
  --Ensure a symbol
  WHILE (LEN(@NewPassword) <10)
  BEGIN
    select @randInt=dbo.randbetween(33,64)
	--           !               # $ % &                            < = > ? @
    IF @randInt=33 OR (@randInt>=35 AND @randInt<=38) OR (@randInt>=60 AND @randInt<=64) 
    Begin
     select @NewCharacter=CHAR(@randInt)
     select @NewPassword=CONCAT(@NewPassword, @NewCharacter)
    END
  END

  RETURN(@NewPassword);
END;

GO
