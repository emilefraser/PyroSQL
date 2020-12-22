/*
Author:
Original link: https://www.red-gate.com/simple-talk/blogs/sql-naming-conventions/
*/

SELECT o.name
  FROM sys.objects AS o
    INNER JOIN
      (
      VALUES ('ADD'), ('EXTERNAL'), ('PROCEDURE'), ('ALL'), ('FETCH'),
        ('PUBLIC'), ('ALTER'), ('FILE'), ('RAISERROR'), ('AND'),
        ('FILLFACTOR'), ('READ'), ('ANY'), ('FOR'), ('READTEXT'), ('AS'),
        ('FOREIGN'), ('RECONFIGURE'), ('ASC'), ('FREETEXT'), ('REFERENCES'),
        ('AUTHORIZATION'), ('FREETEXTTABLE'), ('REPLICATION'), ('BACKUP'),
        ('FROM'), ('RESTORE'), ('BEGIN'), ('FULL'), ('RESTRICT'), ('BETWEEN'),
        ('FUNCTION'), ('RETURN'), ('BREAK'), ('GOTO'), ('REVERT'), ('BROWSE'),
        ('GRANT'), ('REVOKE'), ('BULK'), ('GROUP'), ('RIGHT'), ('BY'),
        ('HAVING'), ('ROLLBACK'), ('CASCADE'), ('HOLDLOCK'), ('ROWCOUNT'),
        ('CASE'), ('IDENTITY'), ('ROWGUIDCOL'), ('CHECK'), ('IDENTITY_INSERT'),
        ('RULE'), ('CHECKPOINT'), ('IDENTITYCOL'), ('SAVE'), ('CLOSE'), ('IF'),
        ('SCHEMA'), ('CLUSTERED'), ('IN'), ('SECURITYAUDIT'), ('COALESCE'),
        ('INDEX'), ('SELECT'), ('COLLATE'), ('INNER'),
        ('SEMANTICKEYPHRASETABLE'), ('COLUMN'), ('INSERT'),
        ('SEMANTICSIMILARITYDETAILSTABLE'), ('COMMIT'), ('INTERSECT'),
        ('SEMANTICSIMILARITYTABLE'), ('COMPUTE'), ('INTO'), ('SESSION_USER'),
        ('CONSTRAINT'), ('IS'), ('SET'), ('CONTAINS'), ('JOIN'), ('SETUSER'),
        ('CONTAINSTABLE'), ('KEY'), ('SHUTDOWN'), ('CONTINUE'), ('KILL'),
        ('SOME'), ('CONVERT'), ('LEFT'), ('STATISTICS'), ('CREATE'), ('LIKE'),
        ('SYSTEM_USER'), ('CROSS'), ('LINENO'), ('TABLE'), ('CURRENT'),
        ('LOAD'), ('TABLESAMPLE'), ('CURRENT_DATE'), ('MERGE'), ('TEXTSIZE'),
        ('CURRENT_TIME'), ('NATIONAL'), ('THEN'), ('CURRENT_TIMESTAMP'),
        ('NOCHECK'), ('TO'), ('CURRENT_USER'), ('NONCLUSTERED'), ('TOP'),
        ('CURSOR'), ('NOT'), ('TRAN'), ('DATABASE'), ('NULL'), ('TRANSACTION'),
        ('DBCC'), ('NULLIF'), ('TRIGGER'), ('DEALLOCATE'), ('OF'),
        ('TRUNCATE'), ('DECLARE'), ('OFF'), ('TRY_CONVERT'), ('DEFAULT'),
        ('OFFSETS'), ('TSEQUAL'), ('DELETE'), ('ON'), ('UNION'), ('DENY'),
        ('OPEN'), ('UNIQUE'), ('DESC'), ('OPENDATASOURCE'), ('UNPIVOT'),
        ('DISK'), ('OPENQUERY'), ('UPDATE'), ('DISTINCT'), ('OPENROWSET'),
        ('UPDATETEXT'), ('DISTRIBUTED'), ('OPENXML'), ('USE'), ('DOUBLE'),
        ('OPTION'), ('USER'), ('DROP'), ('OR'), ('VALUES'), ('DUMP'),
        ('ORDER'), ('VARYING'), ('ELSE'), ('OUTER'), ('VIEW'), ('END'),
        ('OVER'), ('WAITFOR'), ('ERRLVL'), ('PERCENT'), ('WHEN'), ('ESCAPE'),
        ('PIVOT'), ('WHERE'), ('EXCEPT'), ('PLAN'), ('WHILE'), ('EXEC'),
        ('PRECISION'), ('WITH'), ('EXECUTE'), ('PRIMARY'), ('WITHIN GROUP'),
        ('EXISTS'), ('PRINT'), ('WRITETEXT'), ('EXIT'), ('PROC')
      ) AS reserved (word)
      ON reserved.word = o.name;

