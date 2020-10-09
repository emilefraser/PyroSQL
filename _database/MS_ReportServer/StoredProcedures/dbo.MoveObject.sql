SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[MoveObject]
@OldPath nvarchar (425),
@OldPrefix nvarchar (850),
@NewName nvarchar (425),
@NewPath nvarchar (425),
@NewParentID uniqueidentifier,
@RenameOnly as bit,
@MaxPathLength as int
AS

DECLARE @LongPath nvarchar(425)
SET @LongPath =
  (SELECT TOP 1 Path
   FROM Catalog
   WHERE
      LEN(Path)-LEN(@OldPath)+LEN(@NewPath) > @MaxPathLength AND
      Path LIKE @OldPrefix ESCAPE '*')

IF @LongPath IS NOT NULL BEGIN
   SELECT @LongPath
   RETURN
END

IF @RenameOnly = 0 -- if this a full-blown move, not just a rename
BEGIN
    -- adjust policies on the top item that gets moved
    DECLARE @OldInheritedPolicyID as uniqueidentifier
    SELECT @OldInheritedPolicyID = (SELECT PolicyID FROM Catalog with (XLOCK) WHERE Path = @OldPath AND PolicyRoot = 0)
    IF (@OldInheritedPolicyID IS NOT NULL)
       BEGIN -- this was not a policy root, change it to inherit from target folder
         DECLARE @NewPolicyID as uniqueidentifier
         SELECT @NewPolicyID = (SELECT PolicyID FROM Catalog with (XLOCK) WHERE ItemID = @NewParentID)
         -- update item and children that shared the old policy
         UPDATE Catalog SET PolicyID = @NewPolicyID WHERE Path = @OldPath
         UPDATE Catalog SET PolicyID = @NewPolicyID
            WHERE Path LIKE @OldPrefix ESCAPE '*'
            AND Catalog.PolicyID = @OldInheritedPolicyID
     END
END

-- Update item that gets moved (Path, Name, and ParentId)
update Catalog
set Name = @NewName, Path = @NewPath, ParentID = @NewParentID
where Path = @OldPath
-- Update all its children (Path only, Names and ParentIds stay the same)
update Catalog
set Path = STUFF(Path, 1, LEN(@OldPath), @NewPath )
where Path like @OldPrefix escape '*'
GO
