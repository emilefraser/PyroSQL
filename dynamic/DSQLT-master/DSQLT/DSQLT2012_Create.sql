/*
Bereitstellungsskript für DSQLT2012

Dieser Code wurde von einem Tool generiert.
Änderungen an dieser Datei führen möglicherweise zu falschem Verhalten und gehen verloren, falls
der Code neu generiert wird.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "DSQLT2012"
:setvar DefaultFilePrefix "DSQLT2012"
:setvar DefaultDataPath ""
:setvar DefaultLogPath ""

GO
:on error exit
GO
/*
Überprüfen Sie den SQLCMD-Modus, und deaktivieren Sie die Skriptausführung, wenn der SQLCMD-Modus nicht unterstützt wird.
Um das Skript nach dem Aktivieren des SQLCMD-Modus erneut zu aktivieren, führen Sie folgenden Befehl aus:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'Der SQLCMD-Modus muss aktiviert sein, damit dieses Skript erfolgreich ausgeführt werden kann.';
        SET NOEXEC ON;
    END


GO
USE [master];


GO

IF (DB_ID(N'$(DatabaseName)') IS NOT NULL) 
BEGIN
    ALTER DATABASE [$(DatabaseName)]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$(DatabaseName)];
END

GO
PRINT N'$(DatabaseName) wird erstellt....'
GO
CREATE DATABASE [$(DatabaseName)] COLLATE Latin1_General_CI_AS
GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS OFF,
                ANSI_PADDING OFF,
                ANSI_WARNINGS OFF,
                ARITHABORT OFF,
                CONCAT_NULL_YIELDS_NULL OFF,
                NUMERIC_ROUNDABORT OFF,
                QUOTED_IDENTIFIER OFF,
                ANSI_NULL_DEFAULT OFF,
                CURSOR_DEFAULT GLOBAL,
                RECOVERY SIMPLE,
                CURSOR_CLOSE_ON_COMMIT OFF,
                AUTO_CREATE_STATISTICS ON,
                AUTO_SHRINK OFF,
                AUTO_UPDATE_STATISTICS ON,
                RECURSIVE_TRIGGERS OFF 
            WITH ROLLBACK IMMEDIATE;
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CLOSE OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ALLOW_SNAPSHOT_ISOLATION OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET READ_COMMITTED_SNAPSHOT OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_UPDATE_STATISTICS_ASYNC OFF,
                PAGE_VERIFY CHECKSUM,
                DATE_CORRELATION_OPTIMIZATION OFF,
                DISABLE_BROKER,
                PARAMETERIZATION SIMPLE,
                SUPPLEMENTAL_LOGGING OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET TRUSTWORTHY OFF,
        DB_CHAINING OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'Die Datenbankeinstellungen können nicht geändert werden. Diese Einstellungen können nur von Systemadministratoren übernommen werden.';
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET HONOR_BROKER_PRIORITY OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'Die Datenbankeinstellungen können nicht geändert werden. Diese Einstellungen können nur von Systemadministratoren übernommen werden.';
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET FILESTREAM(NON_TRANSACTED_ACCESS = OFF),
                CONTAINMENT = NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
USE [$(DatabaseName)];


GO
IF fulltextserviceproperty(N'IsFulltextInstalled') = 1
    EXECUTE sp_fulltext_database 'disable';


GO
/*
 Vorlage für ein Skript vor der Bereitstellung							
--------------------------------------------------------------------------------------
 Diese Datei enthält SQL-Anweisungen, die vor dem Buildskript ausgeführt werden.	
 Schließen Sie mit der SQLCMD-Syntax eine Datei in das Skript vor der Bereitstellung ein.			
 Beispiel:   :r .\myfile.sql								
 Verweisen Sie mit der SQLCMD-Syntax auf eine Variable im Skript vor der Bereitstellung.		
 Beispiel:   :setvar TableName MyTable							
        SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
GO

GO
PRINT N'[@3] wird erstellt....';


GO
CREATE SCHEMA [@3]
    AUTHORIZATION [dbo];


GO
PRINT N'[@2] wird erstellt....';


GO
CREATE SCHEMA [@2]
    AUTHORIZATION [dbo];


GO
PRINT N'[@1] wird erstellt....';


GO
CREATE SCHEMA [@1]
    AUTHORIZATION [dbo];


GO
PRINT N'[TEST] wird erstellt....';


GO
CREATE SCHEMA [TEST]
    AUTHORIZATION [dbo];


GO
PRINT N'[stamm] wird erstellt....';


GO
CREATE SCHEMA [stamm]
    AUTHORIZATION [dbo];


GO
PRINT N'[Sample] wird erstellt....';


GO
CREATE SCHEMA [Sample]
    AUTHORIZATION [dbo];


GO
PRINT N'[DSQLT] wird erstellt....';


GO
CREATE SCHEMA [DSQLT]
    AUTHORIZATION [dbo];


GO
PRINT N'[@9] wird erstellt....';


GO
CREATE SCHEMA [@9]
    AUTHORIZATION [dbo];


GO
PRINT N'[@8] wird erstellt....';


GO
CREATE SCHEMA [@8]
    AUTHORIZATION [dbo];


GO
PRINT N'[@7] wird erstellt....';


GO
CREATE SCHEMA [@7]
    AUTHORIZATION [dbo];


GO
PRINT N'[@6] wird erstellt....';


GO
CREATE SCHEMA [@6]
    AUTHORIZATION [dbo];


GO
PRINT N'[@5] wird erstellt....';


GO
CREATE SCHEMA [@5]
    AUTHORIZATION [dbo];


GO
PRINT N'[@4] wird erstellt....';


GO
CREATE SCHEMA [@4]
    AUTHORIZATION [dbo];


GO
PRINT N'[dbo].[@5] wird erstellt....';


GO
CREATE TABLE [dbo].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@4] wird erstellt....';


GO
CREATE TABLE [dbo].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@3] wird erstellt....';


GO
CREATE TABLE [dbo].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@2] wird erstellt....';


GO
CREATE TABLE [dbo].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@1] wird erstellt....';


GO
CREATE TABLE [dbo].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@9] wird erstellt....';


GO
CREATE TABLE [dbo].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@8] wird erstellt....';


GO
CREATE TABLE [dbo].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@7] wird erstellt....';


GO
CREATE TABLE [dbo].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[dbo].[@6] wird erstellt....';


GO
CREATE TABLE [dbo].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@6] wird erstellt....';


GO
CREATE TABLE [@3].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@5] wird erstellt....';


GO
CREATE TABLE [@3].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@3] wird erstellt....';


GO
CREATE TABLE [@3].[@3] (
    [@1]                NVARCHAR (MAX) NOT NULL,
    [@2]                NVARCHAR (MAX) NOT NULL,
    [@3]                NVARCHAR (MAX) NOT NULL,
    [@4]                NVARCHAR (MAX) NOT NULL,
    [@5]                NVARCHAR (MAX) NOT NULL,
    [@6]                NVARCHAR (MAX) NULL,
    [@7]                NVARCHAR (MAX) NULL,
    [@8]                NVARCHAR (MAX) NULL,
    [@9]                NVARCHAR (MAX) NULL,
    [DSQLT_Source]      NVARCHAR (MAX) NOT NULL,
    [DSQLT_Target]      NVARCHAR (MAX) NOT NULL,
    [DSQLT_PrimaryKey]  NVARCHAR (MAX) NOT NULL,
    [DSQLT_ColumnName]  NVARCHAR (128) NOT NULL,
    [DSQLT_SourceValue] NVARCHAR (MAX) NULL,
    [DSQLT_TargetValue] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@4] wird erstellt....';


GO
CREATE TABLE [@3].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@1] wird erstellt....';


GO
CREATE TABLE [@3].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@2] wird erstellt....';


GO
CREATE TABLE [@3].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@9] wird erstellt....';


GO
CREATE TABLE [@3].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@8] wird erstellt....';


GO
CREATE TABLE [@3].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@3].[@7] wird erstellt....';


GO
CREATE TABLE [@3].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@6] wird erstellt....';


GO
CREATE TABLE [@2].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@5] wird erstellt....';


GO
CREATE TABLE [@2].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@2] wird erstellt....';


GO
CREATE TABLE [@2].[@2] (
    [@1]                     NVARCHAR (MAX) NOT NULL,
    [@2]                     NVARCHAR (MAX) NOT NULL,
    [@3]                     NVARCHAR (MAX) NOT NULL,
    [@4]                     NVARCHAR (MAX) NOT NULL,
    [@5]                     NVARCHAR (MAX) NOT NULL,
    [@6]                     NVARCHAR (MAX) NULL,
    [@7]                     NVARCHAR (MAX) NULL,
    [@8]                     NVARCHAR (MAX) NULL,
    [@9]                     NVARCHAR (MAX) NULL,
    [DSQLT_SyncRowCreated]   DATETIME       NOT NULL,
    [DSQLT_SyncRowModified]  DATETIME       NOT NULL,
    [DSQLT_SyncRowIsDeleted] BIT            NOT NULL,
    [DSQLT_SyncRowStatus]    TINYINT        NOT NULL
);


GO
PRINT N'[@2].[@4] wird erstellt....';


GO
CREATE TABLE [@2].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@3] wird erstellt....';


GO
CREATE TABLE [@2].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@1] wird erstellt....';


GO
CREATE TABLE [@2].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@9] wird erstellt....';


GO
CREATE TABLE [@2].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@8] wird erstellt....';


GO
CREATE TABLE [@2].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@2].[@7] wird erstellt....';


GO
CREATE TABLE [@2].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@1] wird erstellt....';


GO
CREATE TABLE [@1].[@1] (
    [@1]                     NVARCHAR (MAX) NOT NULL,
    [@2]                     NVARCHAR (MAX) NOT NULL,
    [@3]                     NVARCHAR (MAX) NOT NULL,
    [@4]                     NVARCHAR (MAX) NOT NULL,
    [@5]                     NVARCHAR (MAX) NOT NULL,
    [@6]                     NVARCHAR (MAX) NULL,
    [@7]                     NVARCHAR (MAX) NULL,
    [@8]                     NVARCHAR (MAX) NULL,
    [@9]                     NVARCHAR (MAX) NULL,
    [DSQLT_SyncRowCreated]   DATETIME       NOT NULL,
    [DSQLT_SyncRowModified]  DATETIME       NOT NULL,
    [DSQLT_SyncRowIsDeleted] BIT            NOT NULL,
    [DSQLT_SyncRowStatus]    TINYINT        NOT NULL
);


GO
PRINT N'[@1].[@6] wird erstellt....';


GO
CREATE TABLE [@1].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@5] wird erstellt....';


GO
CREATE TABLE [@1].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@4] wird erstellt....';


GO
CREATE TABLE [@1].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@3] wird erstellt....';


GO
CREATE TABLE [@1].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@2] wird erstellt....';


GO
CREATE TABLE [@1].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@9] wird erstellt....';


GO
CREATE TABLE [@1].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@8] wird erstellt....';


GO
CREATE TABLE [@1].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@1].[@7] wird erstellt....';


GO
CREATE TABLE [@1].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[stamm].[Artikel] wird erstellt....';


GO
CREATE TABLE [stamm].[Artikel] (
    [Transfer_ID]             INT              NULL,
    [Transfer_Version]        CHAR (5)         NULL,
    [Transfer_Row_PrimaryKey] UNIQUEIDENTIFIER NULL,
    [Transfer_Row_Deleted]    BIT              NULL,
    [Transfer_Row_Created]    SMALLDATETIME    NULL,
    [Transfer_Row_Changed]    SMALLDATETIME    NULL,
    [Transfer_Row_Deployed]   SMALLDATETIME    NULL,
    [Transfer_Row_Status]     TINYINT          NULL,
    [MANDT]                   VARCHAR (4)      NOT NULL,
    [Benutzer#]               VARCHAR (12)     NOT NULL,
    [Personal#]               CHAR (4)         NOT NULL,
    [Name]                    VARCHAR (35)     NOT NULL,
    [Email]                   VARCHAR (50)     NOT NULL,
    [Telefon]                 VARCHAR (25)     NOT NULL,
    [Abteilung]               VARCHAR (15)     NOT NULL,
    [Status]                  VARCHAR (50)     NOT NULL,
    [Mandant#]                CHAR (3)         NOT NULL,
    [Personal#_Vorgesetzter]  CHAR (4)         NOT NULL,
    [Benutzer#_Vorgesetzter]  CHAR (12)        NOT NULL,
    [Vorname]                 VARCHAR (35)     NULL,
    [Nachname]                VARCHAR (35)     NULL,
    [i5Profil]                CHAR (10)        NULL,
    [DCWBenutzer]             CHAR (15)        NULL,
    [DCWGruppe]               CHAR (15)        NULL,
    [Bestellnummernkreis]     CHAR (2)         NULL
);


GO
PRINT N'[stamm].[Kunden] wird erstellt....';


GO
CREATE TABLE [stamm].[Kunden] (
    [Kundennummer] CHAR (4)     NOT NULL,
    [Name]         VARCHAR (35) NOT NULL,
    [Email]        VARCHAR (50) NOT NULL,
    [Telefon]      VARCHAR (25) NOT NULL
);


GO
PRINT N'[stamm].[Preise] wird erstellt....';


GO
CREATE TABLE [stamm].[Preise] (
    [Transfer_ID]             INT              NULL,
    [Transfer_Version]        CHAR (5)         NULL,
    [Transfer_Row_PrimaryKey] UNIQUEIDENTIFIER NULL,
    [Transfer_Row_Deleted]    BIT              NULL,
    [Transfer_Row_Created]    SMALLDATETIME    NULL,
    [Transfer_Row_Changed]    SMALLDATETIME    NULL,
    [Transfer_Row_Deployed]   SMALLDATETIME    NULL,
    [Transfer_Row_Status]     TINYINT          NULL,
    [MANDT]                   VARCHAR (4)      NOT NULL,
    [Benutzer#]               VARCHAR (12)     NOT NULL,
    [Personal#]               CHAR (4)         NOT NULL,
    [Name]                    VARCHAR (35)     NOT NULL,
    [Email]                   VARCHAR (50)     NOT NULL,
    [Telefon]                 VARCHAR (25)     NOT NULL,
    [Abteilung]               VARCHAR (15)     NOT NULL,
    [Status]                  VARCHAR (50)     NOT NULL,
    [Mandant#]                CHAR (3)         NOT NULL,
    [Personal#_Vorgesetzter]  CHAR (4)         NOT NULL,
    [Benutzer#_Vorgesetzter]  CHAR (12)        NOT NULL,
    [Vorname]                 VARCHAR (35)     NULL,
    [Nachname]                VARCHAR (35)     NULL,
    [i5Profil]                CHAR (10)        NULL,
    [DCWBenutzer]             CHAR (15)        NULL,
    [DCWGruppe]               CHAR (15)        NULL,
    [Bestellnummernkreis]     CHAR (2)         NULL
);


GO
PRINT N'[Sample].[Source_Address] wird erstellt....';


GO
CREATE TABLE [Sample].[Source_Address] (
    [AddressID]       INT              IDENTITY (1, 1) NOT NULL,
    [AddressLine1]    NVARCHAR (60)    NOT NULL,
    [AddressLine2]    NVARCHAR (60)    NULL,
    [City]            NVARCHAR (30)    NOT NULL,
    [StateProvinceID] INT              NOT NULL,
    [PostalCode]      NVARCHAR (15)    NOT NULL,
    [rowguid]         UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate]    DATETIME         NOT NULL,
    CONSTRAINT [PK_Source_Address] PRIMARY KEY CLUSTERED ([AddressID] ASC)
);


GO
PRINT N'[Sample].[Source_Product] wird erstellt....';


GO
CREATE TABLE [Sample].[Source_Product] (
    [ProductID]      INT             NOT NULL,
    [ProductModelID] INT             NULL,
    [Name]           NVARCHAR (1000) NOT NULL,
    [Color]          NVARCHAR (15)   NULL,
    [ListPrice]      MONEY           NULL,
    [Created]        DATETIME        NULL
);


GO
PRINT N'[Sample].[Target_Address] wird erstellt....';


GO
CREATE TABLE [Sample].[Target_Address] (
    [AddressID]       INT              IDENTITY (1, 1) NOT NULL,
    [AddressLine1]    NVARCHAR (60)    NOT NULL,
    [AddressLine2]    NVARCHAR (60)    NULL,
    [City]            NVARCHAR (30)    NOT NULL,
    [StateProvinceID] INT              NOT NULL,
    [PostalCode]      NVARCHAR (15)    NOT NULL,
    [rowguid]         UNIQUEIDENTIFIER NOT NULL,
    [ModifiedDate]    DATETIME         NOT NULL
);


GO
PRINT N'[Sample].[Target_Product] wird erstellt....';


GO
CREATE TABLE [Sample].[Target_Product] (
    [ProductID]              INT            NOT NULL,
    [ProductModelID]         INT            NOT NULL,
    [Name]                   NVARCHAR (100) NOT NULL,
    [Description]            XML            NOT NULL,
    [Color]                  NVARCHAR (15)  NULL,
    [Created]                DATETIME       NOT NULL,
    [DSQLT_SyncRowCreated]   DATETIME       NULL,
    [DSQLT_SyncRowModified]  DATETIME       NULL,
    [DSQLT_SyncRowIsDeleted] BIT            NULL,
    CONSTRAINT [PK_Target_Product] PRIMARY KEY CLUSTERED ([ProductID] ASC, [ProductModelID] ASC)
);


GO
PRINT N'[DSQLT].[Types] wird erstellt....';


GO
CREATE TABLE [DSQLT].[Types] (
    [type_id]          INT           NOT NULL,
    [type_name]        VARCHAR (50)  NOT NULL,
    [type_pattern]     VARCHAR (50)  NOT NULL,
    [type_default]     VARCHAR (50)  NOT NULL,
    [type_comparison]  VARCHAR (MAX) NOT NULL,
    [type_concatvalue] VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Types] PRIMARY KEY CLUSTERED ([type_id] ASC)
);


GO
PRINT N'[DSQLT].[CompareResult] wird erstellt....';


GO
CREATE TABLE [DSQLT].[CompareResult] (
    [DSQLT_Source]      NVARCHAR (MAX) NOT NULL,
    [DSQLT_Target]      NVARCHAR (MAX) NOT NULL,
    [DSQLT_PrimaryKey]  NVARCHAR (MAX) NOT NULL,
    [DSQLT_ColumnName]  NVARCHAR (258) NOT NULL,
    [DSQLT_SourceValue] NVARCHAR (MAX) NULL,
    [DSQLT_TargetValue] NVARCHAR (MAX) NULL
);


GO
PRINT N'[DSQLT].[Sync_Template] wird erstellt....';


GO
CREATE TABLE [DSQLT].[Sync_Template] (
    [DSQLT_SyncRowCreated]   DATETIME NOT NULL,
    [DSQLT_SyncRowModified]  DATETIME NOT NULL,
    [DSQLT_SyncRowIsDeleted] BIT      NOT NULL,
    [DSQLT_SyncRowStatus]    INT      NOT NULL
);


GO
PRINT N'[DSQLT].[SourceSearch] wird erstellt....';


GO
CREATE TABLE [DSQLT].[SourceSearch] (
    [Server]     [sysname]      NULL,
    [Database]   [sysname]      NULL,
    [Schema]     [sysname]      NOT NULL,
    [Program]    [sysname]      NOT NULL,
    [type]       [sysname]      NOT NULL,
    [type_desc]  [sysname]      NULL,
    [definition] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@5] wird erstellt....';


GO
CREATE TABLE [@9].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@4] wird erstellt....';


GO
CREATE TABLE [@9].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@3] wird erstellt....';


GO
CREATE TABLE [@9].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@2] wird erstellt....';


GO
CREATE TABLE [@9].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@1] wird erstellt....';


GO
CREATE TABLE [@9].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@9] wird erstellt....';


GO
CREATE TABLE [@9].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@8] wird erstellt....';


GO
CREATE TABLE [@9].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@7] wird erstellt....';


GO
CREATE TABLE [@9].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@9].[@6] wird erstellt....';


GO
CREATE TABLE [@9].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@5] wird erstellt....';


GO
CREATE TABLE [@8].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@4] wird erstellt....';


GO
CREATE TABLE [@8].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@3] wird erstellt....';


GO
CREATE TABLE [@8].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@2] wird erstellt....';


GO
CREATE TABLE [@8].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@1] wird erstellt....';


GO
CREATE TABLE [@8].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@8] wird erstellt....';


GO
CREATE TABLE [@8].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@9] wird erstellt....';


GO
CREATE TABLE [@8].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@7] wird erstellt....';


GO
CREATE TABLE [@8].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@8].[@6] wird erstellt....';


GO
CREATE TABLE [@8].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@5] wird erstellt....';


GO
CREATE TABLE [@7].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@4] wird erstellt....';


GO
CREATE TABLE [@7].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@3] wird erstellt....';


GO
CREATE TABLE [@7].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@2] wird erstellt....';


GO
CREATE TABLE [@7].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@1] wird erstellt....';


GO
CREATE TABLE [@7].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@9] wird erstellt....';


GO
CREATE TABLE [@7].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@8] wird erstellt....';


GO
CREATE TABLE [@7].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@6] wird erstellt....';


GO
CREATE TABLE [@7].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@7].[@7] wird erstellt....';


GO
CREATE TABLE [@7].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@5] wird erstellt....';


GO
CREATE TABLE [@6].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@4] wird erstellt....';


GO
CREATE TABLE [@6].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@2] wird erstellt....';


GO
CREATE TABLE [@6].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@3] wird erstellt....';


GO
CREATE TABLE [@6].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@1] wird erstellt....';


GO
CREATE TABLE [@6].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@9] wird erstellt....';


GO
CREATE TABLE [@6].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@8] wird erstellt....';


GO
CREATE TABLE [@6].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@7] wird erstellt....';


GO
CREATE TABLE [@6].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@6].[@6] wird erstellt....';


GO
CREATE TABLE [@6].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@5] wird erstellt....';


GO
CREATE TABLE [@5].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@4] wird erstellt....';


GO
CREATE TABLE [@5].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@2] wird erstellt....';


GO
CREATE TABLE [@5].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@3] wird erstellt....';


GO
CREATE TABLE [@5].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@1] wird erstellt....';


GO
CREATE TABLE [@5].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@9] wird erstellt....';


GO
CREATE TABLE [@5].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@8] wird erstellt....';


GO
CREATE TABLE [@5].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@7] wird erstellt....';


GO
CREATE TABLE [@5].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@5].[@6] wird erstellt....';


GO
CREATE TABLE [@5].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@6] wird erstellt....';


GO
CREATE TABLE [@4].[@6] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@5] wird erstellt....';


GO
CREATE TABLE [@4].[@5] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@4] wird erstellt....';


GO
CREATE TABLE [@4].[@4] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@3] wird erstellt....';


GO
CREATE TABLE [@4].[@3] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@1] wird erstellt....';


GO
CREATE TABLE [@4].[@1] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@2] wird erstellt....';


GO
CREATE TABLE [@4].[@2] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@9] wird erstellt....';


GO
CREATE TABLE [@4].[@9] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@8] wird erstellt....';


GO
CREATE TABLE [@4].[@8] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'[@4].[@7] wird erstellt....';


GO
CREATE TABLE [@4].[@7] (
    [@1] NVARCHAR (MAX) NOT NULL,
    [@2] NVARCHAR (MAX) NOT NULL,
    [@3] NVARCHAR (MAX) NOT NULL,
    [@4] NVARCHAR (MAX) NOT NULL,
    [@5] NVARCHAR (MAX) NOT NULL,
    [@6] NVARCHAR (MAX) NULL,
    [@7] NVARCHAR (MAX) NULL,
    [@8] NVARCHAR (MAX) NULL,
    [@9] NVARCHAR (MAX) NULL
);


GO
PRINT N'DF_@2_DSQLT_SyncRowCreated wird erstellt....';


GO
ALTER TABLE [@2].[@2]
    ADD CONSTRAINT [DF_@2_DSQLT_SyncRowCreated] DEFAULT (getdate()) FOR [DSQLT_SyncRowCreated];


GO
PRINT N'DF_@2_DSQLT_SyncRowModified wird erstellt....';


GO
ALTER TABLE [@2].[@2]
    ADD CONSTRAINT [DF_@2_DSQLT_SyncRowModified] DEFAULT (getdate()) FOR [DSQLT_SyncRowModified];


GO
PRINT N'DF_@2_DSQLT_SyncRowIsDeleted wird erstellt....';


GO
ALTER TABLE [@2].[@2]
    ADD CONSTRAINT [DF_@2_DSQLT_SyncRowIsDeleted] DEFAULT ((0)) FOR [DSQLT_SyncRowIsDeleted];


GO
PRINT N'DF_@1_DSQLT_SyncRowCreated wird erstellt....';


GO
ALTER TABLE [@1].[@1]
    ADD CONSTRAINT [DF_@1_DSQLT_SyncRowCreated] DEFAULT (getdate()) FOR [DSQLT_SyncRowCreated];


GO
PRINT N'DF_@1_DSQLT_SyncRowModified wird erstellt....';


GO
ALTER TABLE [@1].[@1]
    ADD CONSTRAINT [DF_@1_DSQLT_SyncRowModified] DEFAULT (getdate()) FOR [DSQLT_SyncRowModified];


GO
PRINT N'DF_@1_DSQLT_SyncRowIsDeleted wird erstellt....';


GO
ALTER TABLE [@1].[@1]
    ADD CONSTRAINT [DF_@1_DSQLT_SyncRowIsDeleted] DEFAULT ((0)) FOR [DSQLT_SyncRowIsDeleted];


GO
PRINT N'DF_sample.Target_Product_DSQLT_SyncRowCreated wird erstellt....';


GO
ALTER TABLE [Sample].[Target_Product]
    ADD CONSTRAINT [DF_sample.Target_Product_DSQLT_SyncRowCreated] DEFAULT (getdate()) FOR [DSQLT_SyncRowCreated];


GO
PRINT N'DF_sample.Target_Product_DSQLT_SyncRowModified wird erstellt....';


GO
ALTER TABLE [Sample].[Target_Product]
    ADD CONSTRAINT [DF_sample.Target_Product_DSQLT_SyncRowModified] DEFAULT (getdate()) FOR [DSQLT_SyncRowModified];


GO
PRINT N'DF_sample.Target_Product_DSQLT_SyncRowIsDeleted wird erstellt....';


GO
ALTER TABLE [Sample].[Target_Product]
    ADD CONSTRAINT [DF_sample.Target_Product_DSQLT_SyncRowIsDeleted] DEFAULT ((0)) FOR [DSQLT_SyncRowIsDeleted];


GO
PRINT N'[DSQLT].[Concat] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[Concat]
(@Value NVARCHAR (MAX), @Delimiter NVARCHAR (MAX), @Result NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	RETURN @Result+case when LEN(@Result) = 0 then '' else @Delimiter end + @Value
END
GO
PRINT N'[DSQLT].[CRLF] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[CRLF]
( )
RETURNS CHAR (2)
AS
BEGIN
	RETURN CHAR(13)+CHAR(10)
END
GO
PRINT N'[DSQLT].[SQ] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[SQ]
( )
RETURNS CHAR (1)
AS
BEGIN
	RETURN ''''
END
GO
PRINT N'[DSQLT].[isQuoted] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[isQuoted]
(@Text NVARCHAR (MAX), @Quote NVARCHAR (MAX)='[')
RETURNS BIT
AS
BEGIN
	DECLARE @Prefix nchar(1) 
	DECLARE @Postfix nchar(1) 
	DECLARE @Replace nchar(2) 
	DECLARE @Pos int
	
	-- mindestens 2 Zeichen, sonst nicht gequoted
	IF LEN(@Text) < 2
		RETURN 0
		
	-- Klammerung richtig abarbeiten
	IF @Quote='['
		SET @Quote=']'
	-- Falls Bedarf für diese Klammern, dann aktivieren.
	--IF @Quote='('
	--	SET @Quote=')'
	--IF @Quote='<'
	--	SET @Quote='>'
	SET @Prefix=@Quote
	SET @Postfix=@Quote
	IF @Quote=']'
		SET @Prefix='['
	-- Falls Bedarf für diese Klammern, dann aktivieren.
	--IF @Quote=')'
	--	SET @Prefix='('
	--IF @Quote='>'
	--	SET @Prefix='<'

	-- Prüfen, ob links und rechts gequoted
	IF SUBSTRING(@Text,1,1) <> @Prefix or SUBSTRING(@Text,LEN(@Text),1) <> @Postfix
		RETURN 0
		
	SET @Text=SUBSTRING(@Text,2,LEN(@Text)-2)
	
	SET @Pos=-1
	WHILE @Pos < LEN(@Text) 
	BEGIN
		SET @Pos=Charindex(@Quote,@Text,@Pos+2)
		-- nix gequoted
		IF @Pos = 0 
			RETURN 1
		-- Quote ist einzeln!
		IF @Pos = LEN(@Text) 
			RETURN 0
		-- nächstes Zeichen nicht identisch??
		IF SUBSTRING(@Text,@Pos,1) <> SUBSTRING(@Text,@Pos+1,1)
			RETURN 0
	END
	-- alles regelgerecht. Der Text könnte gequoted sein.
	RETURN 1
END
GO
PRINT N'[DSQLT].[isProc] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[isProc]
(@sp NVARCHAR (MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@sp) AND type in (N'P', N'PC'))
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[isView] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[isView]
(@view VARCHAR (MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@view) AND type in (N'V'))
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[Bin2Hex] wird erstellt....';


GO
CREATE FUNCTION DSQLT.Bin2Hex
(
@binvalue varbinary(256)
)
RETURNS varchar(256)
AS
BEGIN
DECLARE @charvalue varchar(256)
DECLARE @i int
DECLARE @length int
DECLARE @hexstring char(16)
SELECT @charvalue = '0x'
SELECT @i = 1
SELECT @length = DATALENGTH (@binvalue)
SELECT @hexstring = '0123456789ABCDEF'
WHILE (@i <= @length)
	BEGIN
	DECLARE @tempint int
	DECLARE @firstint int
	DECLARE @secondint int
	SELECT @tempint = CONVERT(int, SUBSTRING(@binvalue,@i,1))
	SELECT @firstint = FLOOR(@tempint/16)
	SELECT @secondint = @tempint - (@firstint*16)
	SELECT @charvalue = @charvalue +
	SUBSTRING(@hexstring, @firstint+1, 1) +
	SUBSTRING(@hexstring, @secondint+1, 1)
	SELECT @i = @i + 1
	END
RETURN @charvalue
END
GO
PRINT N'[DSQLT].[Quote] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[Quote]
(@Text NVARCHAR (MAX), @Quote NVARCHAR (1)='[')
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Prefix nchar(1) 
	DECLARE @Postfix nchar(1) 
	
	-- Klammerung richtig abarbeiten
	IF @Quote='['
		SET @Quote=']'
	SET @Prefix=@Quote
	SET @Postfix=@Quote
	IF @Quote=']'
		SET @Prefix='['
		
	SET @Text=@Prefix+REPLACE(@Text,@Quote,@Quote+@Quote)+@Postfix
	
	RETURN @Text
END
GO
PRINT N'[DSQLT].[Version] wird erstellt....';


GO

CREATE FUNCTION [DSQLT].[Version]
( )
RETURNS CHAR (4)
AS
BEGIN
	RETURN '2.05'
END
GO
PRINT N'[DSQLT].[Escape] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[Escape]
(@Text NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	RETURN REPLACE(REPLACE(REPLACE(@Text,'[','[[]'),'%','[%]'),'_','[_]')
END
GO
PRINT N'[DSQLT].[isDatabase] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[isDatabase]
(@db [sysname])
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	-- check quoted name separatedly
	IF  EXISTS (SELECT * FROM sys.databases WHERE [name] = @db or QUOTENAME([name]) = @db)
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[isFunc] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[isFunc]
(@fn NVARCHAR (MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@fn) AND type in (N'AF',N'FN',N'FS',N'FT',N'IF',N'TF'))
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[isSynonym] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[isSynonym]
(@syn VARCHAR (MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@syn) AND type in (N'SN'))
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[isTable] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[isTable]
(@table VARCHAR (MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@table) AND type in (N'U'))
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[TypePattern] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[TypePattern]
(@Pattern NVARCHAR (MAX), @Value NVARCHAR (MAX), @Type [sysname], @Len INT, @Precision INT, @Scale INT)
RETURNS NVARCHAR (MAX)
AS
BEGIN
DECLARE @Result nvarchar(max)
SET @Result=
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(@Pattern
								,'%v',@Value)
							,'%t',@Type)
						,'%l',ltrim(case when @Len=-1 then 'max' else str(@Len) end))
					,'%h',ltrim(case when @Len=-1 then 'max' else str(@Len/2) end))
				,'%p',ltrim(str(@Precision)))
			,'%s',ltrim(@Scale)) 
RETURN @Result
END
GO
PRINT N'[DSQLT].[QuoteSQ] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[QuoteSQ]
(@Text NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	RETURN [DSQLT].[Quote] (@Text,DSQLT.SQ())
END
GO
PRINT N'[DSQLT].[QuoteSafe] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[QuoteSafe]
(@Text NVARCHAR (MAX), @Quote NVARCHAR (1)='[')
RETURNS NVARCHAR (MAX)
AS
BEGIN
	-- Wollen wir null oder einen Leerstring wirklich Quoten??
	IF len(isnull(@Text,''))=0
		RETURN ''  -- Nein, wir geben lieber Leeren String zurück.
		
	-- Nur, wenn nicht bereits gequoted
	IF DSQLT.isQuoted(@Text,@Quote)=0
		SET @Text=[DSQLT].[Quote](@Text,@Quote)
	
	RETURN @Text
END
GO
PRINT N'[DSQLT].[QuoteDQ] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[QuoteDQ]
(@Text NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	RETURN [DSQLT].[QuoteSafe] (@Text,'"')
END
GO
PRINT N'[DSQLT].[Int2Hex] wird erstellt....';


GO
CREATE FUNCTION DSQLT.Int2Hex
(
@intvalue int
)
RETURNS varchar(256)
as
BEGIN
declare @binvalue varbinary(256)
set @binvalue=convert(varbinary(8),@intvalue)
return DSQLT.Bin2Hex(@binvalue)
end
GO
PRINT N'[DSQLT].[QuoteName] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[QuoteName]
(@Text NVARCHAR (MAX), @Quote NVARCHAR (MAX)='[')
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Server sysname
	DECLARE @Database sysname
	DECLARE @Schema sysname
	DECLARE @Object sysname
	
	SET @Server=PARSENAME(@Text,4)
	IF @Server is not null
		SET @Server=DSQLT.QUOTE(@Server,@Quote)+'.'
	ELSE
		SET @Server=''
	
	SET @Database=PARSENAME(@Text,3)
	IF @Database is not null
		SET @Database=DSQLT.QUOTE(@Database,@Quote)+'.'
	ELSE
		IF LEN(@Server) = 0
			SET @Database=''
		ELSE
			SET @Database='.'
			
	SET @Schema=PARSENAME(@Text,2)
	IF @Schema is not null
		SET @Schema=DSQLT.QUOTE(@Schema,@Quote)+'.'
	ELSE
		IF LEN(@Database) = 0
			SET @Schema=''
		ELSE
			SET @Schema='.'
			
	SET @Object=PARSENAME(@Text,1)
	IF @Object is not null
		SET @Object=DSQLT.QUOTE(@Object,@Quote)
	ELSE	-- verrückter Name , hat mehr wie 4 Bestandteile. Quoten wir ihn einfach, falls nötig
		SET @Text=DSQLT.QUOTE(@Text,@Quote)
	
	-- Wenn es ein gültiger Name war, bauen wir ihn aus den Bestandteilen wieder zusammen		
	IF @Object is not null
		SET @Text=@Server+@Database+@Schema+@Object
	
	RETURN @Text
END
GO
PRINT N'[DSQLT].[QuoteSB] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[QuoteSB]
(@Text NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	RETURN [DSQLT].[QuoteSafe] (@Text,'[')
END
GO
PRINT N'[DSQLT].[isSchema] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[isSchema]
(@schema [sysname])
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	-- check quoted name separatedly
	IF  EXISTS (SELECT * FROM sys.schemas WHERE schema_id = SCHEMA_ID(@schema) or DSQLT.QuoteSB([name])= @schema)
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[QuoteNameSB] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[QuoteNameSB]
(@Text NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	RETURN [DSQLT].[QuoteName] (@Text,'[')
END
GO
PRINT N'[DSQLT].[isTableType] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[isTableType]
(@SchemaType [sysname])
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	SET @SchemaType=[DSQLT].[QuoteNameSB](@SchemaType)
	IF  EXISTS (
		SELECT * 
		FROM sys.types T
		join sys.schemas S on T.schema_id=S.schema_id
		WHERE T.is_table_type = 1 
		and [DSQLT].[QuoteSB](S.name)+'.'+[DSQLT].[QuoteSB](T.name)=@SchemaType
			)
		SET @Result=1
	RETURN @Result
END
GO
PRINT N'[DSQLT].[TableTypes] wird erstellt....';


GO


CREATE FUNCTION [DSQLT].[TableTypes]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.[Name]+'.'+O.[Name] as SchemaTableType
,QUOTENAME(S.[Name])+'.'+QUOTENAME(O.[Name]) as SchemaTableTypeQ
,S.[Name] as [Schema]
,QUOTENAME(S.[Name]) as [SchemaQ]
,O.[Name] as [TableType] 
,QUOTENAME(O.[Name]) as [TableTypeQ] 
from sys.types O
join sys.schemas S on O.schema_id=S.schema_id
WHERE O.is_table_type=1 and 
(	S.[Name]+'.'+O.[Name] LIKE @Pattern
	or  QUOTENAME(S.[Name])+'.'+QUOTENAME(O.[Name]) LIKE @Pattern)
)
GO
PRINT N'[DSQLT].[Synonyms] wird erstellt....';


GO

CREATE FUNCTION [DSQLT].[Synonyms]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name+'.'+O.name as SchemaSynonym
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaSynonymQ
,S.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,O.name as [Synonym] 
,QUOTENAME(O.name) as [SynonymQ] 
,O.base_object_name
,Parsename(O.base_object_name,4) as [Object_Server]
,Parsename(O.base_object_name,3) as [Object_Database]
,Parsename(O.base_object_name,2) as [Object_Schema]
,Parsename(O.base_object_name,1) as [Object_Name]
,QUOTENAME(Parsename(O.base_object_name,4)) as [Object_ServerQ]
,QUOTENAME(Parsename(O.base_object_name,3)) as [Object_DatabaseQ]
,QUOTENAME(Parsename(O.base_object_name,2)) as [Object_SchemaQ]
,QUOTENAME(Parsename(O.base_object_name,1)) as [Object_NameQ]
from sys.synonyms O
join sys.schemas S on O.schema_id=S.schema_id
WHERE type in (N'SN')
and (	S.name+'.'+O.name LIKE @Pattern
	or  QUOTENAME(S.name)+'.'+QUOTENAME(O.name) LIKE @Pattern)
)
GO
PRINT N'[DSQLT].[Databases] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[Databases]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name as [Database]
,QUOTENAME(S.name) as DatabaseQ
from sys.databases S 
where S.name LIKE @Pattern
or  QUOTENAME(S.name) LIKE @Pattern)
GO
PRINT N'[DSQLT].[AllSourceContains] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[AllSourceContains]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.[name]+'.'+O.name as SchemaProgram
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaProgramQ
,s.[name] as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,o.name as [Program] 
,QUOTENAME(O.name) as [ProgramQ] 
,o.[type] 
,o.type_desc 
,m.definition
from sys.all_sql_modules m
join sys.all_objects o on m.object_id=o.object_id
join sys.schemas s on o.schema_id=s.schema_id
where m.definition like @Pattern
)
GO
PRINT N'[DSQLT].[Procedures] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[Procedures]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name+'.'+O.name as SchemaProcedure
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaProcedureQ
,S.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,O.name as [Procedure] 
,QUOTENAME(O.name) as [ProcedureQ] 
from sys.objects O
join sys.schemas S on O.schema_id=S.schema_id
WHERE type in (N'P', N'PC')
and (	S.name+'.'+O.name LIKE @Pattern
	or  QUOTENAME(S.name)+'.'+QUOTENAME(O.name) LIKE @Pattern)
)
GO
PRINT N'[DSQLT].[Functions] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[Functions]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name+'.'+O.name as SchemaFunction
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaFunctionQ
,S.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,O.name as [Function] 
,QUOTENAME(O.name) as [FunctionQ] 
from sys.objects O
join sys.schemas S on O.schema_id=S.schema_id
WHERE type in (N'AF',N'FN',N'FS',N'FT',N'IF',N'TF')
and (	S.name+'.'+O.name LIKE @Pattern
	or  QUOTENAME(S.name)+'.'+QUOTENAME(O.name) LIKE @Pattern)
)
GO
PRINT N'[DSQLT].[Views] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[Views]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.[Name]+'.'+O.[Name] as SchemaView
,QUOTENAME(S.[Name])+'.'+QUOTENAME(O.[Name]) as SchemaViewQ
,S.[Name] as [Schema]
,QUOTENAME(S.[Name]) as [SchemaQ]
,O.[Name] as [View] 
,QUOTENAME(O.name) as [ViewQ] 
from sys.views O
join sys.schemas S on O.schema_id=S.schema_id
WHERE (	S.[Name]+'.'+O.[Name] LIKE @Pattern
	or  QUOTENAME(S.[Name])+'.'+QUOTENAME(O.[Name]) LIKE @Pattern)
)
GO
PRINT N'[DSQLT].[Schemas] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[Schemas]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name as [Schema]
,QUOTENAME(S.name) as SchemaQ
from sys.schemas S 
WHERE (	S.name LIKE @Pattern
	or  QUOTENAME(S.name) LIKE @Pattern)
)
GO
PRINT N'[DSQLT].[SourceContains] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[SourceContains]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name+'.'+O.name as SchemaProgram
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaProgramQ
,s.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,o.name as [Program] 
,QUOTENAME(O.name) as [ProgramQ] 
,o.[type] 
,o.type_desc 
,m.definition
from sys.sql_modules m
join sys.objects o on m.object_id=o.object_id
join sys.schemas s on o.schema_id=s.schema_id
where m.definition like @Pattern
)
GO
PRINT N'[DSQLT].[Tables] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[Tables]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.[Name]+'.'+O.[Name] as SchemaTable
,QUOTENAME(S.[Name])+'.'+QUOTENAME(O.[Name]) as SchemaTableQ
,S.[Name] as [Schema]
,QUOTENAME(S.[Name]) as [SchemaQ]
,O.[Name] as [Table] 
,QUOTENAME(O.[Name]) as [TableQ] 
from sys.tables O
join sys.schemas S on O.schema_id=S.schema_id
WHERE (	S.[Name]+'.'+O.[Name] LIKE @Pattern
	or  QUOTENAME(S.[Name])+'.'+QUOTENAME(O.[Name]) LIKE @Pattern)
)
GO
PRINT N'[DSQLT].[Digits] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[Digits]
(@from INT=0, @to INT=9)
RETURNS TABLE 
AS
RETURN 
    (
WITH Digits(Digit) as
(
select 0 as Digit
UNION ALL
select Digit+1 from Digits where Digit <9
)
select 
Digit
,cast(ltrim(str(Digit)) as nchar(1)) as DigitChar
,cast(Quotename(ltrim(str(Digit))) as nchar(3)) as DigitCharQ
,cast('@'+ltrim(str(Digit)) as nchar(2)) as Parameter
,cast(Quotename('@'+ltrim(str(Digit))) as nchar(4)) as ParameterQ 
from Digits
where Digit between @from and @to
)
GO
PRINT N'[DSQLT].[Objects] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[Objects]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name+'.'+O.name as SchemaObject
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaObjectQ
,S.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,O.name as [Object] 
,QUOTENAME(O.name) as [ObjectQ] 
,O.type as Object_Type
from sys.objects O
join sys.schemas S on O.schema_id=S.schema_id
and (	S.name+'.'+O.name LIKE @Pattern
	or  QUOTENAME(S.name)+'.'+QUOTENAME(O.name) LIKE @Pattern)
UNION 
SELECT *, 'TT' from [DSQLT].[TableTypes](@Pattern)
)
GO
PRINT N'[DSQLT].[aMillionNumbers] wird erstellt....';


GO

CREATE FUNCTION [DSQLT].[aMillionNumbers]
(@from INT=0, @to INT=999999)
RETURNS TABLE 
AS
RETURN 
WITH Digits as
(SELECT Digit from DSQLT.Digits(0,9))
,Numbers as
(
SELECT A.Digit+B.Digit*10+C.Digit*100+D.Digit*1000+E.Digit*10000+F.Digit*100000 as Number
from Digits A
cross join Digits B
cross join Digits C
cross join Digits D
cross join Digits E
cross join Digits F
)
select Number from Numbers 
where Number between @from and @to
GO
PRINT N'[DSQLT].[Columns] wird erstellt....';


GO

CREATE FUNCTION [DSQLT].[Columns]
(@Object NVARCHAR (MAX)='')
RETURNS @Result TABLE (
	[Name] [sysname] NOT NULL,
	[NameQ] [nvarchar](max) NOT NULL,
	[Column] [sysname] NOT NULL,
	[ColumnQ] [nvarchar](max) NOT NULL,
	[ObjectColumn] [nvarchar](max) NOT NULL,
	[ObjectColumnQ] [nvarchar](max) NOT NULL,
	[SchemaObjectColumn] [nvarchar](max) NOT NULL,
	[SchemaObjectColumnQ] [nvarchar](max) NOT NULL,
	[Type] [sysname] NOT NULL,
	[Type_Id] [tinyint] NOT NULL,
	[is_primary_key] [int] NOT NULL,
	[is_nullable] [bit] NOT NULL,
	[Length] [smallint] NOT NULL,
	[Precision] [tinyint] NOT NULL,
	[Scale] [tinyint] NOT NULL,
	[Order] [int] NOT NULL
)
AS
BEGIN
INSERT @Result
	select top 100 percent
	C.[Name] as [Name]
	,QUOTENAME(C.name) as NameQ
	,C.name as [Column]
	,QUOTENAME(C.name) as ColumnQ
	,O.name+'.'+C.name as ObjectColumn
	,QUOTENAME(O.name)+'.'+QUOTENAME(C.name) as ObjectColumnQ
	,S.name+'.'+O.name+'.'+C.name as SchemaObjectColumn
	,QUOTENAME(S.name)+'.'+QUOTENAME(O.name)+'.'+QUOTENAME(C.name) as SchemaObjectColumnQ
    ,TYPE_NAME(c.user_type_id) AS [Type] 
    ,c.user_type_id AS [Type_Id] 
	,case when Y.index_id is null then 0 else 1 end as is_primary_key
	,C.is_nullable
	,C.max_length as Length
	,C.precision as Precision
	,C.scale as Scale
	,C.column_id as [Order]
	from sys.objects O
	join sys.schemas S on S.schema_id=O.schema_id
	join sys.columns C on C.object_id=O.object_id 
	left outer join sys.indexes I on I.object_id=O.object_id and I.is_primary_key=1
	left outer join sys.index_columns Y ON Y.object_id = I.object_id AND Y.index_id = I.index_id AND Y.column_id = C.column_id
	where QUOTENAME(S.name)+'.'+QUOTENAME(O.name) = DSQLT.QuoteNameSB(@Object)
	order by C.column_id
RETURN
END
GO
PRINT N'[DSQLT].[Dates] wird erstellt....';


GO
create FUNCTION [DSQLT].[Dates]
(@from Datetime='01.01.2000', @to Datetime='31.12.2078')
RETURNS @Result TABLE (
	[Date] [datetime] NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[Day] [int] NULL,
	[DayOfYear] [int] NULL,
	[Weekday] [int] NULL
) 
AS
BEGIN
--declare @from Datetime
--declare @to Datetime
--set @from='01.01.2000'
--set @to ='31.12.2000'
declare @todays int
set @todays=datediff(day,@from,@to)
;WITH Numbers as
(SELECT Number from DSQLT.aMillionNumbers(0,@todays)
)
, Dates as
(SELECT DATEADD(day,Number,@from) as [Date] from Numbers
)
INSERT @Result
SELECT [Date], year([Date]) as [Year], month([Date]) as [Month], day([Date]) as [Day]
,Datepart(dayofyear,[Date]) as [DayOfYear]
,Datepart(weekday,[Date]) as [Weekday]
from Dates
RETURN
END
GO
PRINT N'[DSQLT].[AllColumns] wird erstellt....';


GO


CREATE FUNCTION [DSQLT].[AllColumns]
(@Pattern NVARCHAR (MAX)='')
RETURNS @Result TABLE (
	[Name] [sysname] NOT NULL,
	[NameQ] [nvarchar](max) NOT NULL,
	[Column] [sysname] NOT NULL,
	[ColumnQ] [nvarchar](max) NOT NULL,
	[ObjectColumn] [nvarchar](max) NOT NULL,
	[ObjectColumnQ] [nvarchar](max) NOT NULL,
	[SchemaObjectColumn] [nvarchar](max) NOT NULL,
	[SchemaObjectColumnQ] [nvarchar](max) NOT NULL,
	[SchemaObject] [nvarchar](max) NOT NULL,
	[SchemaObjectQ] [nvarchar](max) NOT NULL,
	[Object] [nvarchar](max) NOT NULL,
	[ObjectQ] [nvarchar](max) NOT NULL,
	[Schema] [nvarchar](max) NOT NULL,
	[SchemaQ] [nvarchar](max) NOT NULL,
	[Type] [sysname] NOT NULL,
	[Type_Id] [tinyint] NOT NULL,
	[is_primary_key] [int] NOT NULL,
	[is_nullable] [bit] NOT NULL,
	[Length] [smallint] NOT NULL,
	[Precision] [tinyint] NOT NULL,
	[Scale] [tinyint] NOT NULL,
	[Order] [int] NOT NULL
)
AS
BEGIN
with ColumnList as
(
select 
	C.[Name] as [Name]
	,QUOTENAME(C.name) as NameQ
	,O.name as [Object]
	,QUOTENAME(O.name) as [ObjectQ] 
	,S.name as [Schema]
	,QUOTENAME(S.name) as [SchemaQ] 
    ,TYPE_NAME(c.user_type_id) AS [Type] 
    ,c.user_type_id AS [Type_Id] 
	,case when Y.index_id is null then 0 else 1 end as is_primary_key
	,C.is_nullable
	,C.max_length as Length
	,C.precision as Precision
	,C.scale as Scale
	,C.column_id as [Order]
	from sys.objects O
	join sys.schemas S on S.schema_id=O.schema_id
	join sys.columns C on C.object_id=O.object_id 
	left outer join sys.indexes I on I.object_id=O.object_id and I.is_primary_key=1
	left outer join sys.index_columns Y ON Y.object_id = I.object_id AND Y.index_id = I.index_id AND Y.column_id = C.column_id
)
INSERT @Result
select top 100 percent
[Name]
,NameQ
,[Name] as [Column]
,NameQ as ColumnQ
,[Object]+'.'+[Name] as ObjectColumn
,[ObjectQ]+'.'+[NameQ] as ObjectColumnQ
,[Schema]+'.'+[Object]+'.'+[Name] as SchemaObjectColumn
,[SchemaQ]+'.'+[ObjectQ]+'.'+[NameQ] as SchemaObjectColumnQ
,[Schema]+'.'+[Object] as SchemaObject
,[SchemaQ]+'.'+[ObjectQ] as SchemaObjectQ
,[Object]
,[ObjectQ] 
,[Schema]
,[SchemaQ] 
,[Type] 
,[Type_Id] 
,is_primary_key
,is_nullable
,[Length]
,[Precision]
,[Scale]
,[Order]
from ColumnList
WHERE ([Schema]+'.'+[Object] LIKE @Pattern or [SchemaQ]+'.'+[ObjectQ] LIKE @Pattern)
order by [Schema],[Object],[Order]
RETURN
END
GO
PRINT N'[DSQLT].[ColumnListAlias] wird erstellt....';


GO


CREATE FUNCTION [DSQLT].[ColumnListAlias]
(@Table NVARCHAR (MAX)
,@Alias NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result=''
	select @Result=DSQLT.Concat(@Alias+'.'+ColumnQ,' , ',@Result)
	from DSQLT.Columns(@Table)
	order by [Order]
	RETURN @Result
END
GO
PRINT N'[DSQLT].[ColumnList] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[ColumnList]
(@Table NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result=''
	select @Result=DSQLT.Concat(ColumnQ,' , ',@Result)
	from DSQLT.Columns(@Table)
	order by [Order]
	RETURN @Result
END
GO
PRINT N'[DSQLT].[ColumnListCRLF] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[ColumnListCRLF]
(@Table NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result=''
	DECLARE @delim nvarchar(5)
	SET @delim=' , '+CHAR(13)+CHAR(10)
	-- mit Order by funktioniert das rekursive String-verketten nicht => 
	select @Result=DSQLT.Concat(ColumnQ,@delim,@Result)
	from (select Top 100 PERCENT * from DSQLT.Columns(@Table) order by [Order]) X

	RETURN @Result
END
GO
PRINT N'[DSQLT].[ColumnCompare] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[ColumnCompare]
(@Source NVARCHAR (MAX), @Target NVARCHAR (MAX), @SourceAlias NVARCHAR (MAX), @TargetAlias NVARCHAR (MAX))
RETURNS 
    @Result TABLE (
        [Column]                    NVARCHAR (MAX) NOT NULL,
        [ColumnQ]                   NVARCHAR (MAX) NOT NULL,
        [SourceColumnQ]             NVARCHAR (MAX) NOT NULL,
        [TargetColumnQ]             NVARCHAR (MAX) NULL,
        [Default_Value]             NVARCHAR (MAX) NULL,
        [Compare_Columns]           NVARCHAR (MAX) NULL,
        [Compare_Columns_With_Null] NVARCHAR (MAX) NULL,
        [Source_Value]              NVARCHAR (MAX) NULL,
        [Source_Value_With_Null]    NVARCHAR (MAX) NULL,
        [Target_Value]              NVARCHAR (MAX) NULL,
        [Target_Value_With_Null]    NVARCHAR (MAX) NULL,
		[Source_Concatvalue]		NVARCHAR (MAX) NULL,
		[Target_Concatvalue]		NVARCHAR (MAX) NULL,
		[is_primary_key]			bit NOT NULL,
		[is_Source_nullable]		bit NOT NULL,
		[is_Target_nullable]		bit NOT NULL,
		[is_Sync_Column]			bit NOT NULL,
		[in_both_Tables]			bit NOT NULL,
		[Order]						int NOT NULL,
		[Source_Type]				[sysname] NOT NULL,
		[Target_Type]				[sysname] NULL, 
		[Source_Type_Id]			[tinyint] NOT NULL,
		[Target_Type_Id]			[tinyint] NULL,
		[Source_Length]				[smallint] NOT NULL,
		[Target_Length]				[smallint] NULL,
		[Source_Precision]			[tinyint] NOT NULL,
		[Target_Precision]			[tinyint] NULL,
		[Source_Scale]				[tinyint] NOT NULL,
		[Target_Scale]				[tinyint] NULL
)
AS
BEGIN

--declare @Source NVARCHAR (MAX)
--declare @Target NVARCHAR (MAX)
--declare @SourceAlias NVARCHAR (MAX)
--declare @TargetAlias NVARCHAR (MAX)

--set @Source='Source.[Production.Product]'
--set @Target='Target.[Production.Product]'
--set @SourceAlias='S'
--set @TargetAlias='T'

--SELECT * FROM DSQLT.[ColumnCompare] (
--'Source.[Production.Product]'
--,'Target.[Production.Product]'
--,'S'
--,'T'
--)

SET @Source=DSQLT.QuoteNameSB(@Source)
SET @Target=DSQLT.QuoteNameSB(@Target)

IF LEN(@SourceAlias) > 0
	SET @SourceAlias=DSQLT.QuoteNameSB(@SourceAlias)+'.'
IF @SourceAlias is null
	SET @SourceAlias=@Source+'.'
IF LEN(@TargetAlias) > 0
	SET @TargetAlias=DSQLT.QuoteNameSB(@TargetAlias)+'.'
IF @TargetAlias is null
	SET @TargetAlias=@Target+'.'

INSERT @Result
select 
 S.[Column]
,S.[ColumnQ]
,@SourceAlias+S.ColumnQ
,@TargetAlias+T.ColumnQ
,ST.type_default as [Default_Value]

,'( ' 
	+ case 
		when S.[Type_Id]=T.[Type_Id] and S.[Type_Id] <>241  -- XML grundsätzlich in nvarchar umwandeln
												--, um Unverträglichkeiten von Collations zu vermeiden
			and S.Length=T.Length and S.Precision=T.Precision and S.Scale=T.Scale 
		then @SourceAlias+S.ColumnQ
		else
			DSQLT.TypePattern(
					ST.type_comparison
				,	@SourceAlias+S.ColumnQ
				,	ST.type_name
				,	case when S.Length < T.Length then S.Length else T.Length end 
				,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
				,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
			 ) 
		end
	+ ' <> '
	+ case 
		when S.[Type_Id]=T.[Type_Id] and S.[Type_Id] <>241  -- XML grundsätzlich in nvarchar umwandeln
												--, um Unverträglichkeiten von Collations zu vermeiden
			and S.Length=T.Length and S.Precision=T.Precision and S.Scale=T.Scale 
		then @TargetAlias+T.ColumnQ
		else
			DSQLT.TypePattern(
					TT.type_comparison
				,	@TargetAlias+T.ColumnQ
				,	TT.type_name
				,	case when S.Length < T.Length then S.Length else T.Length end 
				,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
				,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
			) 
		end
	+ ' or ('+@SourceAlias+S.ColumnQ+' is null and '+@TargetAlias+T.ColumnQ+' is not null)'
	+ ' or ('+@SourceAlias+S.ColumnQ+' is not null and '+@TargetAlias+T.ColumnQ+' is null)'
	+ ' )'
	as Compare_Columns
	
,	DSQLT.TypePattern(
			ST.type_comparison
		,	'isnull('+@SourceAlias+S.ColumnQ+','+ST.type_default+')' 
		,	ST.type_name
		,	case when S.Length < T.Length then S.Length else T.Length end 
		,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
		,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
	) 
	+ ' <> '
	+ DSQLT.TypePattern(
			TT.type_comparison
		,	'isnull('+@TargetAlias+T.ColumnQ+','+TT.type_default+')' 
		,	TT.type_name
		,	case when S.Length < T.Length then S.Length else T.Length end 
		,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
		,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
	) 
	as Compare_Columns_With_Null
	
,case 
	when S.[Type_Id]=T.[Type_Id]  and S.[Type_Id] <>241
		and S.Length=T.Length and S.Precision=T.Precision and S.Scale=T.Scale
	then @SourceAlias+S.ColumnQ
	else
		DSQLT.TypePattern(
			ST.type_comparison
		,	@SourceAlias+S.ColumnQ
		,	ST.type_name
		,	case when S.Length < T.Length then S.Length else T.Length end 
		,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
		,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
		) 
	end as Source_Value
	
,case 
	when S.[Type_Id]=T.[Type_Id] and S.[Type_Id] <>241
				and S.Length=T.Length and S.Precision=T.Precision and S.Scale=T.Scale 
	then 'isnull('+@SourceAlias+S.ColumnQ+','+ST.type_default+')' 
	else
		DSQLT.TypePattern(
			ST.type_comparison
		,	'isnull('+@SourceAlias+S.ColumnQ+','+ST.type_default+')' 
		,	ST.type_name
		,	case when S.Length < T.Length then S.Length else T.Length end 
		,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
		,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
		) 
	end as Source_Value_With_Null
	
,case 
	when S.[Type_Id]=T.[Type_Id]  and S.[Type_Id] <>241
		and S.Length=T.Length and S.Precision=T.Precision and S.Scale=T.Scale
	then @TargetAlias+T.ColumnQ
	else
		DSQLT.TypePattern(
			TT.type_comparison
		,	@TargetAlias+T.ColumnQ
		,	TT.type_name
		,	case when S.Length < T.Length then S.Length else T.Length end 
		,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
		,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
		) 
	end as Target_Value
	
,case 
	when S.[Type_Id]=T.[Type_Id] and S.[Type_Id] <>241
				and S.Length=T.Length and S.Precision=T.Precision and S.Scale=T.Scale 
	then 'isnull('+@TargetAlias+T.ColumnQ+','+TT.type_default+')' 
	else
		DSQLT.TypePattern(
			TT.type_comparison
		,	'isnull('+@TargetAlias+T.ColumnQ+','+TT.type_default+')' 
		,	TT.type_name
		,	case when S.Length < T.Length then S.Length else T.Length end 
		,	case when S.Precision < T.Precision then S.Precision else T.Precision end 
		,	case when S.Scale < T.Scale then S.Scale else T.Scale end 
		) 
	end as Target_Value_With_Null
	
,Replace(ST.type_concatvalue,'%v',@SourceAlias+S.ColumnQ) as Source_concatvalue
,Replace(TT.type_concatvalue,'%v',@TargetAlias+T.ColumnQ) as Target_concatvalue
,isnull(T.is_primary_key,S.is_primary_key) as is_primary_key
,S.is_nullable as is_Source_nullable
,isnull(T.is_nullable,1) as is_Target_nullable
,case when X.Name is null then 0 else 1 end as is_Sync_Column
,case when T.Name is null then 0 else 1 end as in_both_Tables
,S.[Order] as [Order]
,S.[Type]
,T.[Type]
,S.[Type_Id]
,T.[Type_Id]
,S.[Length]
,T.[Length]
,S.[Precision]
,T.[Precision]
,S.[Scale]
,T.[Scale]
from DSQLT.Columns(@Source) S 
left outer join DSQLT.Types ST on ST.type_id=S.[Type_Id]
left outer join DSQLT.Columns(@Target) T on S.Name=T.Name
left outer join DSQLT.Types TT on TT.type_id=T.[Type_Id]
left outer join DSQLT.Columns('DSQLT.Sync_Template') X on S.Name=X.Name

RETURN
END
GO
PRINT N'[DSQLT].[InsertColumnList] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[InsertColumnList]
(	@Target NVARCHAR (MAX)
,	@IgnoreColumnList NVARCHAR (MAX)
)
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''

	select @Result=DSQLT.Concat([TargetColumnQ],' , ',@Result)
	from DSQLT.ColumnCompare(@Target ,@Target , '',  ''  )
	where charindex(ColumnQ,@IgnoreColumnList) = 0 
		and is_Sync_Column=0  -- added, 9.6.2010
	order by [Order]

	RETURN @Result
END
GO
PRINT N'[DSQLT].[PrimaryKeyConcatExpression] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[PrimaryKeyConcatExpression]
(@Table NVARCHAR (MAX), @Alias NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''

	select @Result=DSQLT.Concat(Source_concatvalue,' + ',@Result)
	from DSQLT.ColumnCompare(@Table , @Table , @Alias , @Alias )
	where [is_primary_key]=1
	order by [Order]

	RETURN @Result
END
GO
PRINT N'[DSQLT].[PrimaryKeyCompareExpression] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[PrimaryKeyCompareExpression]
(@Table NVARCHAR (MAX), @SourceAlias NVARCHAR (MAX), @TargetAlias NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''
	
	select @Result=DSQLT.Concat(SourceColumnQ+'='+TargetColumnQ,' and ',@Result)
	from DSQLT.ColumnCompare(@Table ,@Table , @SourceAlias,  @TargetAlias  )
	where is_primary_key=1
	order by [Order]

	RETURN @Result
END
GO
PRINT N'[DSQLT].[PrimaryKeyConcatExpressionWithNull] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[PrimaryKeyConcatExpressionWithNull]
(@Table NVARCHAR (MAX), @Alias NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''

	select @Result=DSQLT.Concat('isnull('+Source_concatvalue+',''*NULL*'')',' + ',@Result)
	from DSQLT.ColumnCompare(@Table , @Table , @Alias , @Alias )
	where [is_primary_key]=1
	order by [Order]

	RETURN @Result
END
GO
PRINT N'[DSQLT].[UpdateColumnList] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[UpdateColumnList]
(	@Source NVARCHAR (MAX)
,	@Target NVARCHAR (MAX)
,	@SourceAlias NVARCHAR (MAX)
,	@IgnoreColumnList NVARCHAR (MAX)
)
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''

	select @Result=DSQLT.Concat([ColumnQ]+' = '+Source_Value,' , ',@Result)
	from DSQLT.ColumnCompare(@Source ,@Target , @SourceAlias,  ''  )
	where [in_both_Tables]=1 and is_primary_key=0 
		and is_Sync_Column=0  -- added, 9.6.2010
	and charindex(ColumnQ,@IgnoreColumnList) = 0 
	order by [Order]

	RETURN @Result
END
GO
PRINT N'[DSQLT].[RecordCompareExpression] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[RecordCompareExpression]
(@Source NVARCHAR (MAX)
, @Target NVARCHAR (MAX)
, @SourceAlias NVARCHAR (MAX)
, @TargetAlias NVARCHAR (MAX)
, @UseDefaultValues BIT
, @IgnoreColumnList NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''
	SET @UseDefaultValues=isnull(@UseDefaultValues,0)
	SET @IgnoreColumnList=isnull(@IgnoreColumnList,'')
	
	select @Result=DSQLT.Concat(
		case when @UseDefaultValues=1 then Compare_Columns_With_Null else Compare_Columns end
			,' or ',@Result)
	from DSQLT.ColumnCompare(@Source , @Target , @SourceAlias , @TargetAlias )
	where charindex(ColumnQ,@IgnoreColumnList) = 0 
		and [in_both_Tables]=1 and [is_primary_key]=0 and [is_Sync_Column]=0
	order by [Order]

	RETURN @Result
END
GO
PRINT N'[DSQLT].[SelectValueList] wird erstellt....';


GO
CREATE FUNCTION [DSQLT].[SelectValueList]
(	@Source NVARCHAR (MAX)
,	@Target NVARCHAR (MAX)
,	@SourceAlias NVARCHAR (MAX)
,	@IgnoreColumnList NVARCHAR (MAX)
)
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''
	-- Achtung : für den Aufruf von DSQLT.ColumnCompare werden @Source und @Target vertauscht.
	select @Result=
		DSQLT.Concat(
			case 
			when is_Source_nullable = 1 and in_both_Tables = 0 then ' null '
			when in_both_Tables = 0 then Default_Value
			when is_Source_nullable =0 and is_Target_nullable = 1 then Target_Value_With_Null
			else Target_Value
			end
		,' , ',@Result)
	from DSQLT.ColumnCompare(@Target ,@Source , @SourceAlias,  @SourceAlias  )
	where charindex(ColumnQ,@IgnoreColumnList) = 0 
			and is_Sync_Column=0  -- added, 9.6.2010
	order by [Order]
	
	RETURN @Result
END
GO
PRINT N'[DSQLT].[PrimaryKeyColumnList] wird erstellt....';


GO

CREATE FUNCTION [DSQLT].[PrimaryKeyColumnList]
(@Table NVARCHAR (MAX), @Alias NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''

	select @Result=DSQLT.Concat(SourceColumnQ,' , ',@Result)
	from DSQLT.ColumnCompare(@Table , @Table , @Alias , @Alias )
	where [is_primary_key]=1
	order by [Order]

	RETURN @Result
END
GO
PRINT N'[Sample].[Compare_Product] wird erstellt....';


GO
CREATE PROCEDURE [Sample].[Compare_Product]
AS
BEGIN
IF '#T'='#T'
BEGIN
SELECT TOP 0 * INTO #T FROM DSQLT.CompareResult
END
INSERT INTO [#T]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
'[Sample].[Source_Product]'
,'[Sample].[Target_Product]'
,cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,'*INSERT*'
,'EXISTS'
,null
FROM [Sample].[Source_Product] S
left outer join [Sample].[Target_Product] T
on [S].[ProductID]=[T].[ProductID] and [S].[ProductModelID]=[T].[ProductModelID]
where T.[ProductID] is null
INSERT INTO [#T]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
'[Sample].[Source_Product]'
,'[Sample].[Target_Product]'
,cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,'*DELETE*'
,null
,'EXISTS'
FROM [Sample].[Target_Product] S
left outer join [Sample].[Source_Product] T
on [S].[ProductID]=[T].[ProductID] and [S].[ProductModelID]=[T].[ProductModelID]
where T.[ProductID] is null
INSERT INTO [#T]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
'[Sample].[Source_Product]'
,'[Sample].[Target_Product]'
, cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,'[Name]'
,CAST(S.[Name] as nvarchar(max))
,CAST(T.[Name] as nvarchar(max))
FROM [Sample].[Source_Product] S
join [Sample].[Target_Product] T
on [S].[ProductID]=[T].[ProductID] and [S].[ProductModelID]=[T].[ProductModelID]
where ( cast([S].[Name] as nvarchar(100)) <> cast([T].[Name] as nvarchar(100)) or ([S].[Name] is null and [T].[Name] is not null) or ([S].[Name] is not null and [T].[Name] is null) )

INSERT INTO [#T]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
'[Sample].[Source_Product]'
,'[Sample].[Target_Product]'
, cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,'[Color]'
,CAST(S.[Color] as nvarchar(max))
,CAST(T.[Color] as nvarchar(max))
FROM [Sample].[Source_Product] S
join [Sample].[Target_Product] T
on [S].[ProductID]=[T].[ProductID] and [S].[ProductModelID]=[T].[ProductModelID]
where ( [S].[Color] <> [T].[Color] or ([S].[Color] is null and [T].[Color] is not null) or ([S].[Color] is not null and [T].[Color] is null) )

INSERT INTO [#T]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
'[Sample].[Source_Product]'
,'[Sample].[Target_Product]'
, cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,'[Created]'
,CAST(S.[Created] as nvarchar(max))
,CAST(T.[Created] as nvarchar(max))
FROM [Sample].[Source_Product] S
join [Sample].[Target_Product] T
on [S].[ProductID]=[T].[ProductID] and [S].[ProductModelID]=[T].[ProductModelID]
where ( [S].[Created] <> [T].[Created] or ([S].[Created] is null and [T].[Created] is not null) or ([S].[Created] is not null and [T].[Created] is null) )


IF '#T'='#T'
BEGIN
select * from #T
drop table #T
END

END
GO
PRINT N'[Sample].[@CopyTableFrom] wird erstellt....';


GO
CREATE PROCEDURE [Sample].[@CopyTableFrom] 
AS RETURN -- schützt Template vor versehentlichem Aufruf
BEGIN
TRUNCATE TABLE [@1].[@2]
INSERT INTO [@1].[@2]
("@3")
SELECT "@4" 
FROM [@5].[@1].[@2]
END
GO
PRINT N'[Sample].[@CopyTableTo] wird erstellt....';


GO
CREATE PROCEDURE [Sample].[@CopyTableTo]

AS
RETURN
BEGIN
truncate table [@1].[@2] 
insert into [@1].[@2]
select * from [@3].[@1].[@2]
END
GO
PRINT N'[Sample].[PrimaryKeyCheck_Product] wird erstellt....';


GO
CREATE PROCEDURE [Sample].[PrimaryKeyCheck_Product]
AS
BEGIN
IF '#T'='#T'
BEGIN
SELECT TOP 0 * INTO #T FROM DSQLT.CompareResult
END
INSERT INTO [#T]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
'[Sample].[Source_Product]'
,''
,isnull(cast([ProductID] as varchar(max)),'*NULL*') + isnull(cast([ProductModelID] as varchar(max)),'*NULL*')
,'*PK CONTAINS NULL*'
,cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,null
FROM [Sample].[Source_Product] S
where cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max)) is null
INSERT INTO [#T]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
'[Sample].[Source_Product]'
,''
,cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,'*PK NOT UNIQUE*'
,CAST(count(*) as varchar(max))
,null
FROM [Sample].[Source_Product] S
where cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max)) is not null
group by cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
having COUNT(*) > 1
IF '#T'='#T'
BEGIN
select * from #T
drop table #T
END

END
GO
PRINT N'[Sample].[@Test] wird erstellt....';


GO
CREATE PROCEDURE [Sample].[@Test]

AS
RETURN
BEGIN
select 
S.name+'.'+O.name as SchemaTable
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaTableQ
,S.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,O.name as [Table] 
,QUOTENAME(O.name) as [TableQ] 
from sys.tables O
join sys.schemas S on O.schema_id=S.schema_id
WHERE (	S.name+'.'+O.name LIKE '%@1%'
	or  QUOTENAME(S.name)+'.'+QUOTENAME(O.name) LIKE '%@1%')
END
GO
PRINT N'[Sample].[@ExecCopyTable] wird erstellt....';


GO
CREATE PROCEDURE [Sample].[@ExecCopyTable]

AS
RETURN
BEGIN
exec Copy_@1_@2_From_@3
END
GO
PRINT N'[DSQLT].[_error] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_error]
@Msg NVARCHAR (MAX)=''
AS
BEGIN
SET @Msg='DSQLT ERROR : '+@Msg
print @Msg
END
GO
PRINT N'[DSQLT].[_execSQL] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_execSQL]
@Database [sysname], @SQL NVARCHAR (MAX)=null, @Print BIT=0
AS
BEGIN
if @Database is null
	SET @Database=DB_NAME()
	
Set @SQL='exec '+DSQLT.QuoteSB(@Database)+'..sp_executesql N'+DSQLT.QuoteSQ(@SQL)

IF @Print=0
	exec (@SQL)
	
IF @Print=1 
	print (@SQL)

RETURN 0
END
GO
PRINT N'[DSQLT].[_replaceParameter] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_replaceParameter]
@Parameter NVARCHAR (MAX), @Template NVARCHAR (MAX) OUTPUT, @Value NVARCHAR (MAX), @Pos INT OUTPUT
AS
BEGIN
DECLARE @Pattern nvarchar(max)
DECLARE @From int
DECLARE @To int
set @From =0
set @To =0
if @Pos between 1 and LEN(@Template)-1
	BEGIN
	-- 2 zurück
	SET @From=@Pos-2
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='"'''+@Parameter+'''"'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteSQ(@Parameter)  -- Parameter bleibt erhalten Single Quoted
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='""'+@Parameter+'""'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=@Parameter  -- Parameter bleibt erhalten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='"['+@Parameter+']"'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteSB(@Parameter)  -- Parameter bleibt erhalten mit Klammern
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='"('+@Parameter+'"="'+@Parameter+'")'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='/*'+@Parameter+'*/'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	
	-- 1 zurück
	IF @To=0 --and @From>0
		SET @From=@Pos-1
		
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='['+@Parameter+'].['+@Parameter+']'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteNameSB(@Value) -- mit Zerlegung in Namensbestandteile, dann Quoten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='['+@Parameter+']'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteSB(@Value) --  Quoten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='('+@Parameter+'='+@Parameter+')'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern='"'+@Parameter+'"'
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern=''''+@Parameter+''''
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			SET @Value=DSQLT.QuoteSQ(@Value) --  Quoten mit '
		END
	END
	-- ab Position
	IF @To=0 --and @From>0
		SET @From=@Pos  
		
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern=@Parameter+'='+@Parameter
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
	
	IF @To=0 and @From>0
	BEGIN
		SET @Pattern=@Parameter
		IF SUBSTRING(@Template,@From,LEN(@Pattern)) = @Pattern
		BEGIN
			SET @To=@From+LEN(@Pattern)-1
			-- Value bleibt erhalten
		END
	END
END
if @Value is not null and (@From between 1 and LEN(@Template)) and (@To between 1 and LEN(@Template))
	BEGIN
		Set @Template=STUFF(@Template,@From,@To-@From+1,@Value)
		SET @Pos=@From+len(@Value)-1  -- 13.05.2010. _fillTemplate geht eine Position weiter!!
	END
ELSE
	SET @Pos=0
END
RETURN
GO
PRINT N'[DSQLT].[@TableComparisonSingleField] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@TableComparisonSingleField]
AS
DECLARE	@2 int
DECLARE	@6 int
DECLARE	@7 int
BEGIN
-- feststellen, ob die Spalte bei einem Datensatz geändert wurde
INSERT INTO [@3].[@3]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
 '@4'  -- @Source
,'@5'  -- @Target
, @6  -- @PrimaryKeyExpression
,'@1'  -- @ColumnName   
,CAST(S.[@1] as nvarchar(max))  -- Evaluate @ColumnName to SourceValue
,CAST(T.[@1] as nvarchar(max))  -- Evaluate @ColumnName to TargetValue
FROM [@4].[@4] S  -- @Source
join [@5].[@5] T  -- @Target
	on (@7=@7)  -- @PrimaryKeyCompareExpression
where (@2=@2) -- @ColumnCompareExpression

END
GO
PRINT N'[DSQLT].[@_UseTransaction] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@_UseTransaction]
AS
RETURN
BEGIN
-- Vorspann
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	BEGIN TRANSACTION
	/*@1*/
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC DSQLT._Error
END CATCH
END
GO
PRINT N'[DSQLT].[_fillTypes] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_fillTypes]
AS
BEGIN
BEGIN TRANSACTION
truncate table [DSQLT].[Types]
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (34, 'image', '%t', 'null', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (35, 'text', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (36, 'uniqueidentifier', '%t', 'newid()', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (40, 'date', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (41, 'time', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (42, 'datetime2', '%t', '''''', '%v', 'CONVERT(varchar(max),%v,126)')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (43, 'datetimeoffset', '%t', '''''', '%v', 'CONVERT(varchar(max),%v,126)')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (48, 'tinyint', '%t', '0', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (52, 'smallint', '%t', '0', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (56, 'int', '%t', '0', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (58, 'smalldatetime', '%t', '''''', 'CONVERT(varchar(8),%v,112)', 'CONVERT(varchar(max),%v,126)')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (59, 'real', '%t', '0', 'round(%v,5)', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (60, 'money', '%t', '0', 'round(%v,2)', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (61, 'datetime', '%t', '''''', 'CONVERT(varchar(8),%v,112)', 'CONVERT(varchar(max),%v,126)')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (62, 'float', '%t', '0', 'round(%v,5)', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (98, 'sql_variant', '%t', '0', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (99, 'ntext', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (104, 'bit', '%t', '0', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (106, 'decimal', '%t(%p,%s)', '0', 'round(%v,%s)', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (108, 'numeric', '%t(%p,%s)', '0', 'round(%v,%s)', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (122, 'smallmoney', '%t', '0', 'round(%v,2)', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (127, 'bigint', '%t', '0', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (128, 'hierarchyid', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (129, 'geometry', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (130, 'geography', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (165, 'varbinary', '%t(%l)', 'null', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (167, 'varchar', '%t(%l)', '''''', 'cast(%v as %t(%l))', '%v')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (173, 'binary', '%t(%l)', 'null', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (175, 'char', '%t(%l)', '''''', 'cast(%v as %t(%l))', '%v')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (189, 'timestamp', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (231, 'nvarchar', '%t(%h)', '''''', 'cast(%v as %t(%h))', '%v')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (239, 'nchar', '%t(%h)', '''''', 'cast(%v as %t(%h))', '%v')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (241, 'xml', '%t', 'null', 'cast(%v as varchar(max))', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (256, 'sysname', '%t', '''''', '%v', '%v')
COMMIT TRANSACTION
END
GO
PRINT N'[DSQLT].[License] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[License]

AS
BEGIN
print
'
The DSQLT-framework is developed by Henrik Bauer and published under Ms-PL at CodePlex  http://dsqlt.codeplex.com.

'
print
'
Microsoft Public License (Ms-PL)

This license governs use of the accompanying software. If you use the software, you accept this license. If you do not accept the license, do not use the software.

1. Definitions

The terms "reproduce," "reproduction," "derivative works," and "distribution" have the same meaning here as under U.S. copyright law.

A "contribution" is the original software, or any additions or changes to the software.

A "contributor" is any person that distributes its contribution under this license.

"Licensed patents" are a contributor''s patent claims that read directly on its contribution.

2. Grant of Rights

(A) Copyright Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free copyright license to reproduce its contribution, prepare derivative works of its contribution, and distribute its contribution or any derivative works that you create.

(B) Patent Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free license under its licensed patents to make, have made, use, sell, offer for sale, import, and/or otherwise dispose of its contribution in the software or derivative works of the contribution in the software.

3. Conditions and Limitations

(A) No Trademark License- This license does not grant you rights to use any contributors'' name, logo, or trademarks.

(B) If you bring a patent claim against any contributor over patents that you claim are infringed by the software, your patent license from such contributor to the software ends automatically.

(C) If you distribute any portion of the software, you must retain all copyright, patent, trademark, and attribution notices that are present in the software.

(D) If you distribute any portion of the software in source code form, you may do so only under this license by including a complete copy of this license with your distribution. If you distribute any portion of the software in compiled or object code form, you may only do so under a license that complies with this license.

(E) The software is licensed "as-is." You bear the risk of using it. The contributors give no express warranties, guarantees or conditions. You may have additional consumer rights under your local laws which this license cannot change. To the extent permitted under your local laws, the contributors exclude the implied warranties of merchantability, fitness for a particular purpose and non-infringement.   
 
'
END
GO
PRINT N'[DSQLT].[@CreateTableFrom] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@CreateTableFrom]
AS
RETURN
BEGIN
IF DSQLT.isTable('[@1].[@2]')=0
	BEGIN
	select top 0 * 
	into [@1].[@2]
	from [@3].[@4]
	END
END
GO
PRINT N'[DSQLT].[_generateLinkedserver] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_generateLinkedserver]
@Server [sysname]
AS
BEGIN
DECLARE @datasrc varchar(max)
SET @datasrc= @@Servername
EXEC master.dbo.sp_addlinkedserver @server = @Server, @srvproduct=@Server, @provider=N'SQLNCLI', @datasrc=@datasrc
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=@Server,@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'collation compatible', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'data access', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'dist', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'pub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'rpc', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'rpc out', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'sub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'connect timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'collation name', @optvalue=null
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'lazy schema validation', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'query timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'use remote collation', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'remote proc transaction promotion', @optvalue=N'true'
END
GO
PRINT N'[DSQLT].[_getTemplate] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_getTemplate]
@DSQLTProc NVARCHAR (MAX), @Template NVARCHAR (MAX) OUTPUT
AS
BEGIN
declare @sql nvarchar(max)
declare @schema sysname
declare @begin int
declare @end int
declare @textzeilen nvarchar(max)
set @textzeilen='' 
-- zerlege Name in Schema und Objektname
SET @schema=PARSENAME(@DSQLTProc,2)
SET @DSQLTProc=PARSENAME(@DSQLTProc,1)
-- Beginnt per Konvention mit @ 
IF left(@DSQLTProc,1) <> '@' 
	SET @DSQLTProc = '@'+@DSQLTProc
-- Ist im Schema DSQLT, falls keines angegeben
IF @schema is null
	SET @schema = 'DSQLT'
-- Namen wieder zusammenbasteln
--SET @DSQLTProc = @schema+'.'+@DSQLTProc
SET @DSQLTProc = [DSQLT].[QuoteSB](@schema)+'.'+[DSQLT].[QuoteSB](@DSQLTProc)
--print @DSQLTProc
IF DSQLT.isProc(@DSQLTProc)=1
	BEGIN
	-- temporäre Tabelle, je Zeile Quelltext eine Tabellenzeile
	create table #t1 (z int identity(1,1), txt varchar(1000))
	-- Quelltext der prozedur in Tabelle einfügen
	insert into #t1 exec sp_helptext @DSQLTProc
	-- Kommentare strippen
	update #t1 set txt = left(txt,case when Charindex('--',txt)=0 then len(txt) else Charindex('--',txt)-1 end)
	-- Blanks links, rechts sowie Tabs und CR LF entfernen
	update #t1 set txt = ltrim(rtrim(replace(replace(replace(txt,CHAR(9),''),CHAR(10),''),CHAR(13),'')))
	-- leere zeilen löschen
	delete from #t1 where LEN(txt)=0 or txt is null
	-- erstes BEGIN
	select top 1 @begin=z from #t1 where txt = 'BEGIN' order by z
	-- und letztes END ermitteln
	select top 1 @end=z from #t1 where txt = 'END' order by z desc
	-- dazwischen ist unser Quelletext. Aufsammeln und Zeileumbruch ergänzen
	select @textzeilen=@textzeilen+txt+char(13)+char(10) from #t1 where z between @begin+1 and @end-1
	-- aufräumen
	drop table #t1
	-- Output Parameter setzen
	Set @Template= @textzeilen
	END
ELSE
	BEGIN
	-- Wenn noch in der Datenbank DSQLT gesucht wurde
	-- aber das Template im Schema DSQLT sein soll, dann nochmals in der Datenbank DSQLT suchen
		IF DB_NAME() <> 'DSQLT' and @schema = 'DSQLT'  	
			BEGIN
			exec [DSQLT].[DSQLT].[_getTemplate] @DSQLTProc, @Template OUTPUT
			END
		ELSE
			BEGIN
			exec DSQLT._error 'Template nicht gefunden'
			END
	END
RETURN
END
GO
PRINT N'[DSQLT].[_doTemplate] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_doTemplate]
@Database [sysname]=null, @Template NVARCHAR (MAX), @Print BIT=0
AS
BEGIN
if @Database is null
	SET @Database=DB_NAME()
	
if @Database=DB_NAME() -- kein Datenbankwechsel nötig
	BEGIN
	IF @Print=0 
			exec (@Template)  
	IF @Print=1 
			print (@Template)
	END
ELSE
		exec DSQLT._execSQL @Database,@Template,@Print   -- ausführen in der Zieldatenbank
RETURN 0
END
GO
PRINT N'[DSQLT].[_fillTemplate] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_fillTemplate]
@p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database NVARCHAR (MAX)=null, @Template NVARCHAR (MAX) OUTPUT
AS
BEGIN
if @Database is null
	SET @Database=DB_NAME()

declare @pos int 
declare @c char(1)
set @pos=0
while @pos >= 0 -- wird innerhalb der Schleife abgebrochen
begin
	set @pos=Charindex('@',@Template,@pos+1) 
	if @pos<=0 or @pos>=LEN(@Template)
		break
	
	set @c=SUBSTRING(@Template,@pos+1,1)
	if @c ='0' 	exec DSQLT._replaceParameter '@0',@Template OUTPUT,@Database,@pos OUTPUT
	if @c ='1' 	exec DSQLT._replaceParameter '@1',@Template OUTPUT,@p1,@pos OUTPUT
	if @c ='2' 	exec DSQLT._replaceParameter '@2',@Template OUTPUT,@p2,@pos OUTPUT
	if @c ='3' 	exec DSQLT._replaceParameter '@3',@Template OUTPUT,@p3,@pos OUTPUT
	if @c ='4' 	exec DSQLT._replaceParameter '@4',@Template OUTPUT,@p4,@pos OUTPUT
	if @c ='5' 	exec DSQLT._replaceParameter '@5',@Template OUTPUT,@p5,@pos OUTPUT
	if @c ='6' 	exec DSQLT._replaceParameter '@6',@Template OUTPUT,@p6,@pos OUTPUT
	if @c ='7' 	exec DSQLT._replaceParameter '@7',@Template OUTPUT,@p7,@pos OUTPUT
	if @c ='8' 	exec DSQLT._replaceParameter '@8',@Template OUTPUT,@p8,@pos OUTPUT
	if @c ='9' 	exec DSQLT._replaceParameter '@9',@Template OUTPUT,@p9,@pos OUTPUT
		
	if @pos<=0 or @pos>=LEN(@Template)
		break
end

RETURN
END
GO
PRINT N'[DSQLT].[ExecuteSQL] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[ExecuteSQL]
@SQL NVARCHAR (MAX)
, @Database [sysname]=null
, @Print BIT=0
AS
BEGIN
SET NOCOUNT ON
exec DSQLT._doTemplate @Database,@SQL,@Print
RETURN 0
END
GO
PRINT N'[DSQLT].[_fillDatabaseTemplate] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_fillDatabaseTemplate]
@p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database NVARCHAR (MAX) OUTPUT
AS
BEGIN
if @Database is null
	SET @Database=DB_NAME()

if LEN(@Database)=2 and LEFT(@Database,1)='@' and ISNUMERIC(right(@Database,1))=1  -- einfache Parameter
	exec DSQLT._fillTemplate @p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=null,@Template=@Database OUTPUT

RETURN
END
GO
PRINT N'[DSQLT].[_addTransaction] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_addTransaction]
	@Template NVARCHAR (MAX) OUTPUT
,	@Database NVARCHAR (MAX)
,	@UseTransaction bit = 0
AS
BEGIN
IF @UseTransaction=1
BEGIN
declare	@TransactionTemplate NVARCHAR (max)
exec DSQLT._getTemplate 'DSQLT.[@_UseTransaction]', @TransactionTemplate OUTPUT
exec DSQLT._fillTemplate @p1=@Template,@Database=@Database,@Template=@TransactionTemplate OUTPUT
SET @Template=@TransactionTemplate
END

RETURN
END
GO
PRINT N'[@1].[@@2] wird erstellt....';


GO
CREATE PROCEDURE [@1].[@@2]
@p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database [sysname]=null, @Print BIT=0
AS
exec DSQLT.[Execute] '@1.@@2' ,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=@Database,@Print=@Print
RETURN 0
BEGIN
print 0
END
GO
PRINT N'[@1].[@@@2] wird erstellt....';


GO
CREATE PROCEDURE [@1].[@@@2]
@Cursor CURSOR VARYING OUTPUT, @p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database [sysname]=null, @Print BIT=0
AS
exec DSQLT.iterate '@1.@@2' ,@Cursor,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[TEST].[DSQLT.@TableComparisonSingleField] wird erstellt....';


GO
CREATE PROCEDURE [TEST].[DSQLT.@TableComparisonSingleField]
	 @SourceSchema sysname = null
	,@SourceTable sysname= null
	,@TargetSchema sysname= null
	,@TargetTable sysname= null
	,@PrimaryKeySchema sysname=null
	,@PrimaryKeyTable sysname=null
	,@ResultSchema sysname= null
	,@ResultTable sysname= null
	,@IgnoreColumnList varchar(max)=''
	,@UseDefaultValues bit=0
	,@Create varchar(max)=null
	,@Print bit = 0
AS
DECLARE	@Source NVARCHAR (MAX)
DECLARE	@Target NVARCHAR (MAX)
DECLARE	@Result NVARCHAR (MAX)
DECLARE @PKTable NVARCHAR (MAX)   -- Tabelle mit Primärkeydefinition
DECLARE	@PrimaryKeyExpression NVARCHAR (MAX)
DECLARE	@PrimaryKeyCompareExpression NVARCHAR (MAX)
DECLARE	@TargetPrimaryKeyExpression NVARCHAR (MAX)
DECLARE	@Template NVARCHAR (MAX)

SET		@Template =''
SET		@SourceSchema = 'Sample'
SET		@SourceTable = 'Source_Product'
SET		@TargetSchema = 'Sample'
SET		@TargetTable = 'Target_Product'
SET		@PrimaryKeySchema = 'Sample'
SET		@PrimaryKeyTable = 'Target_Product'

SET @Source=DSQLT.QuoteNameSB(@SourceSchema+'.'+@SourceTable)
set @Target = DSQLT.QuoteNameSB(@TargetSchema+'.'+@TargetTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeySchema+'.'+@PrimaryKeyTable)
if @PKTable is null SET @PKTable=@Source
set @Result = DSQLT.QuoteNameSB(@ResultSchema+'.'+@ResultTable)
if @Result is null SET @Result='#T'  -- Kennzeichen für temporäre Tabelle.
set @PrimaryKeyCompareExpression = DSQLT.PrimaryKeyCompareExpression(@PKTable,'S','T')
set @PrimaryKeyExpression = DSQLT.PrimaryKeyConcatExpression(@PKTable,'S')
set @TargetPrimaryKeyExpression = DSQLT.PrimaryKeyConcatExpression(@PKTable,'T')

declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select ColumnQ as [@4]
		,case when @UseDefaultValues=1 then Compare_Columns_With_Null else Compare_Columns end as [@5]
	from DSQLT.ColumnCompare(@Source,@Target,'S','T')
	where in_both_Tables=1 and is_primary_key=0 and [is_Sync_Column]=0
			and charindex(ColumnQ,@IgnoreColumnList) = 0 

exec DSQLT.Iterate 'DSQLT.@TableComparisonSingleField',@Cursor
	,@Result
	,@Source
	,@Target 
	,@PrimaryKeyExpression -- @6
	,@PrimaryKeyCompareExpression -- @7
	,@Template=@Template OUTPUT
	,@Print=null

print @Template
GO
PRINT N'[TEST].[DSQLT.@PrimaryKeyCheck] wird erstellt....';


GO
CREATE Proc [TEST].[DSQLT.@PrimaryKeyCheck]
as
DECLARE	@return_value int

EXEC	@return_value = [DSQLT].[@PrimaryKeyCheck]
		@SourceSchema = Sample,
		@SourceTable = Source_Product,
		@PrimaryKeySchema = Sample,
		@PrimaryKeyTable = Target_Product,
		@Create = N'Sample.PrimaryKeyCheck_Product',
		@Print = 0

SELECT	'Return Value' = @return_value
GO
PRINT N'[TEST].[DSQLT.@SyncTable] wird erstellt....';


GO
CREATE proc [TEST].[DSQLT.@SyncTable] as
DECLARE	@return_value int

EXEC	@return_value = [DSQLT].[@SyncTable]
		@SourceSchema = sample,
		@SourceTable = source_product,
		@TargetSchema = sample,
		@TargetTable = target_product,
		@PrimaryKeySchema = NULL,
		@PrimaryKeyTable = NULL,
		@IgnoreColumnList = '',
		@UseDefaultValues = NULL,
		@Create = NULL,
		@Print = 1

SELECT	'Return Value' = @return_value
GO
PRINT N'[TEST].[DSQLT.@TableComparison] wird erstellt....';


GO
CREATE Proc [TEST].[DSQLT.@TableComparison]
as
DECLARE	@return_value int

EXEC	@return_value = [DSQLT].[@TableComparison]
		@SourceSchema = Sample,
		@SourceTable = Source_Product,
		@TargetSchema = Sample,
		@TargetTable = Target_Product,
		@PrimaryKeySchema = Sample,
		@PrimaryKeyTable = Target_Product,
		@Create = N'Sample.Compare_Product',
		@Print = 0

SELECT	'Return Value' = @return_value
GO
PRINT N'[Sample].[@@CopyTableContentFrom] wird erstellt....';


GO
CREATE PROCEDURE [Sample].[@@CopyTableContentFrom]
@Cursor CURSOR VARYING OUTPUT, @Database [sysname]=null, @Print BIT=0
AS
if @Database is null SET @Database=DB_NAME()
	exec DSQLT.iterate '[Sample].[@CopyTableContentFrom]',@Cursor,@Database,@Print=@Print
RETURN 0
GO
PRINT N'[Sample].[@@CopyTableContentTo] wird erstellt....';


GO
CREATE PROCEDURE [Sample].[@@CopyTableContentTo]
@Cursor CURSOR VARYING OUTPUT, @Database [sysname]=null, @Print BIT=0
AS
Declare @Source nvarchar(max)
	set @Source = DB_NAME()
	exec DSQLT.iterate '[Sample].[@CopyTableContentTo]',@Cursor,@Source,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[Sample].[@ForEachTable] wird erstellt....';


GO
CREATE proc [Sample].[@ForEachTable] as
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select * from dsqlt.tables('%')
exec DSQLT.iterate 'Sample.[@ForEachTable]',@Cursor=@Cursor
RETURN 
BEGIN
print '@1'
END
GO
PRINT N'[Sample].[@CopyTableContentFrom] wird erstellt....';


GO
CREATE PROCEDURE [Sample].[@CopyTableContentFrom]
@Schema [sysname], @Table [sysname], @Database [sysname]=null, @Print INT=0
AS
if @Database is null SET @Database=DB_NAME()
	Declare @3 nvarchar(max)
	set @3= DSQLT.ColumnList(@Schema+'.'+@Table)
	exec DSQLT.[Execute] '[Sample].[@CopyTableContentFrom]',@Schema,@Table,@3,@Database,@Print=@Print
RETURN
BEGIN
-- @0 = Zieldatenbank ist die aktuelle 
-- @1 = Schema
-- @2 = Tabelle 
-- @3 = Feldliste der Tabelle
-- @4 = Quelldatenbank
-- prüfen, ob Tabelle Identity Feld hat, falls ja, dann Insert erlauben
IF IDENT_SEED('[@1].[@2]') is not null
	SET IDENTITY_INSERT [@1].[@2] ON

-- Tabelle löschen (Truncate geht nur, wenn sicher keine Foreign Keys auf die Tabelle verweisen)
BEGIN TRY
	truncate table [@1].[@2] 
END TRY
BEGIN CATCH 
	delete from [@1].[@2]  
END CATCH

-- Aus Quelldatenbank einfügen
insert into [@1].[@2] ("@3")
	select "@3" from [@4].[@1].[@2]
	
-- prüfen, ob Tabelle Identity Feld hat, falls ja, dann Insert abschalten
IF IDENT_SEED('[@1].[@2]') is not null
	SET IDENTITY_INSERT [@1].[@2] OFF

END
GO
PRINT N'[Sample].[@CopyTableContentTo] wird erstellt....';


GO
CREATE PROCEDURE [Sample].[@CopyTableContentTo]
@Database [sysname], @Schema [sysname], @Table [sysname], @Print INT=0
AS
Declare @3 nvarchar(max)
	Declare @4 nvarchar(max)
	set @3 = DSQLT.ColumnList(@Schema+'.'+@Table)
	set @4 = DB_NAME()
	exec DSQLT.[Execute] '[Sample].@CopyTableContent',@Schema,@Table,@3,@4,@Database=@Database,@Print=@Print
RETURN
BEGIN
-- @0 = Zieldatenbank ist die aktuelle 
-- @1 = Schema
-- @2 = Tabelle 
-- @3 = Feldliste der Tabelle
-- @4 = Quelldatenbank
-- prüfen, ob Tabelle Identity Feld hat, falls ja, dann Insert erlauben
IF IDENT_SEED('[@1].[@2]') is not null
	SET IDENTITY_INSERT [@1].[@2] ON

-- Tabelle löschen (Truncate geht nur, wenn sicher keine Foreign Keys auf die Tabelle verweisen)
BEGIN TRY
	truncate table [@1].[@2] 
END TRY
BEGIN CATCH 
	delete from [@1].[@2]  
END CATCH

-- Aus Quelldatenbank einfügen
insert into [@1].[@2] ("@3")
	select "@3" from [@4].[@1].[@2]
	
-- prüfen, ob Tabelle Identity Feld hat, falls ja, dann Insert abschalten
IF IDENT_SEED('[@1].[@2]') is not null
	SET IDENTITY_INSERT [@1].[@2] OFF

END
GO
PRINT N'[Sample].[@ForEachDatabase] wird erstellt....';


GO

CREATE proc [Sample].[@ForEachDatabase] as
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select * from dsqlt.databases('%')
exec DSQLT.iterate 'Sample.[@ForEachDatabase]',@Cursor=@Cursor,@Database='@1'
RETURN 
BEGIN
declare @ok int
exec @ok=DSQLT.DSQLT.[@isSchema] '@0','DSQLT'
if @ok=1
	print '@0'

END
GO
PRINT N'[Sample].[@ForEachDatabaseCheckDSQLTVersion] wird erstellt....';


GO


CREATE proc [Sample].[@ForEachDatabaseCheckDSQLTVersion] 
@Print bit=0
AS
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select * from dsqlt.databases('%')
exec DSQLT.iterate 'Sample.[@ForEachDatabaseCheckDSQLTVersion]',@Cursor=@Cursor,@Print=@Print,@Database='@1'
RETURN 
BEGIN
declare @rc int
declare @ok int
declare @Info varchar(max)
exec @ok=DSQLT.DSQLT.[@isSchema] '@0','DSQLT'
if @ok=1
	BEGIN
	set @Info='1.0'
	exec @rc=DSQLT.DSQLT.[@isFunc] '@0','DSQLT','Version'
	if @rc=1
		select @Info=DSQLT.Version()
	set @Info='Datenbank '+'@0'+', Version '+@Info
	print @Info
	END
END
GO
PRINT N'[DSQLT].[@DropSynonym] wird erstellt....';


GO



CREATE PROCEDURE [DSQLT].[@DropSynonym]
@Database [sysname], @Schema [sysname], @Table [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropSynonym',@Schema,@Table,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP SYNONYM [@1].[@2]
END
GO
PRINT N'[DSQLT].[_addCreateStub] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_addCreateStub]
	@Template NVARCHAR (MAX) OUTPUT
,	@Database NVARCHAR (MAX)
,	@Create NVARCHAR (MAX)
,	@CreateParam NVARCHAR (MAX)=''
AS
BEGIN
declare	@Command NVARCHAR (max)
declare	@Schema NVARCHAR (max) 
declare	@Object NVARCHAR (max)
declare @rc int
-- Namen in Schema und Objekt zerlegen
set @Schema=isnull(PARSENAME(@Create,2),'dbo')
set @Object=PARSENAME(@Create,1)

set	@Command ='CREATE'
-- Prüfen, ob Zielobjekt existiert
exec @rc=DSQLT.[@isProc] @Database,@Schema,@Object
if @rc=1  
	SET @Command='ALTER'

-- DDL Vorspann + Name
SET @Command=@Command+' PROCEDURE ' + @Create+[DSQLT].[CRLF]()
-- Parameterbereich
IF LEN(@CreateParam) > 0
	SET @Command=@Command+@CreateParam+[DSQLT].[CRLF]()
-- Body
SET @Template=@Command+
 + 'AS'+[DSQLT].[CRLF]()
 + 'BEGIN'+[DSQLT].[CRLF]()
 + @Template+[DSQLT].[CRLF]()
 + 'END'+[DSQLT].[CRLF]()
RETURN
END
GO
PRINT N'[DSQLT].[@DropTableType] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@DropTableType]
@Database [sysname], @Schema [sysname], @TableType [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropTableType',@Schema,@TableType,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP TYPE [@1].[@2]
END
GO
PRINT N'[DSQLT].[@TableComparisonWithPrimaryKeyCheck] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@TableComparisonWithPrimaryKeyCheck]
	 @SourceSchema sysname = null
	,@SourceTable sysname= null
	,@TargetSchema sysname= null
	,@TargetTable sysname= null
	,@PrimaryKeySchema sysname=null
	,@PrimaryKeyTable sysname=null
	,@ResultSchema sysname= null
	,@ResultTable sysname= null
	,@IgnoreColumnList varchar(max)=''
	,@UseDefaultValues bit=0
	,@Create varchar(max)=null
	,@Print bit = 0
AS
DECLARE	@Source NVARCHAR (MAX)
DECLARE	@Target NVARCHAR (MAX)
DECLARE	@Result NVARCHAR (MAX)
DECLARE @PKTable NVARCHAR (MAX)   -- Tabelle mit Primärkeydefinition
DECLARE	@PrimaryKeyExpression NVARCHAR (MAX)
DECLARE	@PrimaryKeyCompareExpression NVARCHAR (MAX)
DECLARE	@PrimaryKeyExpressionWithNull NVARCHAR (MAX)
DECLARE	@PrimaryKeyField NVARCHAR (MAX)
DECLARE	@TemplateFields NVARCHAR (MAX)
DECLARE	@TemplatePKCheck NVARCHAR (MAX)
DECLARE	@TemplatePKError NVARCHAR (MAX)

SET	@TemplateFields =''
SET	@TemplatePKCheck =''
SET	@TemplatePKError =''
SET @Source=DSQLT.QuoteNameSB(@SourceSchema+'.'+@SourceTable)
set @Target = DSQLT.QuoteNameSB(@TargetSchema+'.'+@TargetTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeySchema+'.'+@PrimaryKeyTable)
if @PKTable is null SET @PKTable=@Source
set @Result = DSQLT.QuoteNameSB(@ResultSchema+'.'+@ResultTable)
if @Result is null SET @Result='#T'  -- Kennzeichen für temporäre Tabelle.
set @PrimaryKeyCompareExpression = DSQLT.PrimaryKeyCompareExpression(@PKTable,'S','T')
set @PrimaryKeyExpression = DSQLT.PrimaryKeyConcatExpression(@PKTable,'S')
select top 1 @PrimaryKeyField = [ColumnQ] from DSQLT.Columns(@PKTable)
set @PrimaryKeyExpressionWithNull = DSQLT.PrimaryKeyConcatExpressionWithNull(@PKTable,'S')

declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select ColumnQ as [@1]
		,case when @UseDefaultValues=1 then Compare_Columns_With_Null else Compare_Columns end as [@2]
	from DSQLT.ColumnCompare(@Source,@Target,'S','T')
	where in_both_Tables=1 and is_primary_key=0 and [is_Sync_Column]=0
			and charindex(ColumnQ,@IgnoreColumnList) = 0 

exec DSQLT.Iterate 'DSQLT.@TableComparisonSingleField',@Cursor
	,@Result
	,@Source
	,@Target 
	,@PrimaryKeyExpression -- @6
	,@PrimaryKeyCompareExpression -- @7
	,@Template=@TemplateFields OUTPUT
	,@Print=null

exec DSQLT.[Execute] 'DSQLT.@PrimaryKeyCheck'
	,@Source -- @1
	,@PrimaryKeyExpression
	,@Result
	,@PrimaryKeyExpressionWithNull
	,@Template=@TemplatePKCheck OUTPUT
	,@Print=null

exec DSQLT.[Execute] 'DSQLT.@PrimaryKeyCleanUp'
	,@Source -- @1
	,@PrimaryKeyExpression
	,@Template=@TemplatePKError OUTPUT
	,@Print=null

exec DSQLT.[Execute] 'DSQLT.@TableComparisonWithPrimaryKeyCheck' 
	,@Source -- @1
	,@Target -- @2
	,@Result -- @3
	,@PrimaryKeyExpression -- (Source) @4
	,@PrimaryKeyCompareExpression -- @5
	,@PrimaryKeyField -- @6
	,@TemplateFields -- @7
	,@TemplatePKCheck -- @8
	,@TemplatePKError -- @9
	,@Create=@Create
	,@Print=@Print

RETURN 
DECLARE @4 as int  -- to avoid Syntax error
DECLARE @5 as int  -- to avoid Syntax error
DECLARE @6 as int  -- to avoid Syntax error
BEGIN
IF '@3'='#T' 
	BEGIN
		SELECT TOP 0 * INTO #T FROM DSQLT.CompareResult
	END
	
-- hier wird das template für PrimaryKeyCheck eingefügt
/*@8*/
-- bis hierher
-- hier wird das template für PrimaryKeyErrorCleanUp eingefügt
/*@9*/
-- bis hierher

-- feststellen, ob es neue Datensätze gibt.
INSERT INTO [@3].[@3]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
 '@1'  -- @Source
,'@2'  -- @Target
,@4 -- @PrimaryKeyExpression"
,'*INSERT*'  -- @ColumnName   leer, da nicht Feldspezifisch
,'EXISTS'
,null  -- Evaluate @ColumnName to TargetValue
FROM [@1].[@1] S  -- @Source
left outer join [@2].[@2] T  -- @Target
	on (@5=@5)  -- @PrimaryKeyCompareExpression
where T.[@6] is null   -- @ColumnCompareExpression]


-- feststellen, ob Datensätze gelöscht wurden.
INSERT INTO [@3].[@3]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
 '@1'  -- @Source
,'@2'  -- @Target
,@4 -- @PrimaryKeyExpression"
,'*DELETE*'  -- @ColumnName   nicht Feldspezifisch
,null  
,'EXISTS'
FROM [@2].[@2] S  -- @Source
left outer join [@1].[@1] T  -- @Target
	on (@5=@5)  -- @PrimaryKeyCompareExpression
where T.[@6] is null   -- @ColumnCompareExpression]

-- hier wird das template für Feldvergleich eingefügt
/*@7*/
-- bis hierher

IF '@3'='#T' 
	BEGIN
	select * from #T
	drop table #T
	END
END
GO
PRINT N'[DSQLT].[@PrimaryKeyCleanUp] wird erstellt....';


GO
create PROCEDURE [DSQLT].[@PrimaryKeyCleanUp]
	 @SourceSchema sysname = null
	,@SourceTable sysname= null
	,@PrimaryKeySchema sysname=null
	,@PrimaryKeyTable sysname=null
	,@Create varchar(max)=null
	,@Print bit = 0
AS
DECLARE	@Source NVARCHAR (MAX)
DECLARE @PKTable NVARCHAR (MAX)   -- Tabelle mit Primärkeydefinition
DECLARE	@PrimaryKeyExpression NVARCHAR (MAX)
DECLARE	@Template NVARCHAR (MAX)

SET	@Template =''
SET @Source=DSQLT.QuoteNameSB(@SourceSchema+'.'+@SourceTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeySchema+'.'+@PrimaryKeyTable)
if @PKTable is null SET @PKTable=@Source
set @PrimaryKeyExpression = DSQLT.PrimaryKeyConcatExpression(@PKTable,'')

exec DSQLT.[Execute] 'DSQLT.@PrimaryKeyCleanUp' 
	,@Source -- @1
	,@PrimaryKeyExpression -- @2
	,@Create=@Create
	,@Print=@Print

RETURN 
DECLARE @2 as int  -- to avoid Syntax error
BEGIN
-- wenn NULL vorkommt
	DELETE FROM [@1].[@1] 
	where @2 is null   
-- mehrfache Datensätze
	DELETE FROM [@1].[@1] 
	where @2 in (
		select @2 FROM [@1].[@1]  
		where @2 is not null  
		group by "@2"
		having COUNT(*) > 1
		)
END
GO
PRINT N'[DSQLT].[@isTable] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@isTable]
@Database [sysname], @Schema [sysname], @Table [sysname], @Print BIT=0
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
DECLARE @Template varchar(max)
exec DSQLT.[Execute] '@isTable',@Schema,@Table,@Template=@Template OUTPUT, @Print=null
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[@1].[@2]') AND type in (N'U'))
		SELECT 1
	ELSE
		SELECT 0
END
GO
PRINT N'[DSQLT].[@Print1Parameter] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@Print1Parameter]
@p1 NVARCHAR (MAX)=null, @Print BIT=0
AS
exec DSQLT.[Execute] '@Print1Parameter' ,@p1,@Print=@Print
RETURN 0
BEGIN
	if '@1' = '"@1"' 	print '@1'
END
GO
PRINT N'[DSQLT].[@PrintParameter] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@PrintParameter]
@p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database [sysname]=null, @Print BIT=0
AS
exec DSQLT.[Execute] '@PrintParameter' ,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=@Database,@Print=@Print
RETURN 0
BEGIN
	if '@0' = '"@0"' 	print '@0'
	if '@1' = '"@1"' 	print '@1'
	if '@2' = '"@2"'	print '@2'
	if '@3' = '"@3"'	print '@3'
	if '@4' = '"@4"'	print '@4'
	if '@5' = '"@5"'	print '@5'
	if '@6' = '"@6"'	print '@6'
	if '@7' = '"@7"'	print '@7'
	if '@8' = '"@8"'	print '@8'
	if '@9' = '"@9"'	print '@9'
END
GO
PRINT N'[DSQLT].[@DropSchema] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@DropSchema]
@Database [sysname], @Schema [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropSchema',@Schema,@Database=@Database,@Print=@Print
RETURN
BEGIN
DECLARE @Result int
exec @Result=DSQLT.DSQLT.[@isSchema] '[@0]','[@1]'
IF @Result=1
	BEGIN
	declare @Template nvarchar(max)
	SET @Template ='DROP SCHEMA [@1]'
	exec (@Template)
	END
END
GO
PRINT N'[DSQLT].[@CompareTable] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@CompareTable] 
 @SourceSchema sysname = null
,@SourceTable sysname= null
,@TargetSchema sysname= null
,@TargetTable sysname= null
,@PrimaryKeySchema sysname=null
,@PrimaryKeyTable sysname=null
,@IgnoreColumnList varchar(max)=''
,@UseDefaultValues bit=0
,@Create varchar(max)=null
,@UseTransaction bit = 0
,@Print bit = 0
as
declare @1 varchar(max) -- Target
declare @2 varchar(max) -- Source
declare @3 varchar(max) -- InsertColumnList
declare @4 varchar(max) -- SelectValueList
declare @5 varchar(max) -- PrimaryKeyCompareExpression
declare @6 varchar(max) -- RecordCompareExpression
declare @7 varchar(max) -- UpdateColumnList
declare @8 varchar(max) -- Primärkeyfeld für Existenzprüfung
declare @PKTable varchar(max)   -- Tabelle mit Primärkeydefinition

IF @SourceSchema is not null
	set @SourceTable=@SourceSchema+'.'+@SourceTable
	
IF @TargetSchema is not null
	set @TargetTable=@TargetSchema+'.'+@TargetTable
	
IF @PrimaryKeySchema is not null
	set @PrimaryKeyTable=@PrimaryKeySchema+'.'+@PrimaryKeyTable
	
set @1 = DSQLT.QuoteNameSB(@TargetTable)
set @2 = DSQLT.QuoteNameSB(@SourceTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeyTable)

-- Prüfen, wer einen PK definiert hat
if @PKTable is null 
	SET @PKTable=@1  -- vielleicht Target??

DECLARE @c int
SELECT @c=count(*) from [DSQLT].[Columns] (@PKTable) where is_primary_key=1
IF @c=0
	SET @PKTable=@2  -- vielleicht Source??
	
SELECT @c=count(*) from [DSQLT].[Columns] (@PKTable) where is_primary_key=1
IF @c=0
	RETURN -1 -- FEhler

set @3 = DSQLT.InsertColumnList(@1,'')
set @4 = DSQLT.SelectValueList(@2,@1,'S','')
set @5 = DSQLT.PrimaryKeyCompareExpression(@PKTable,'S','T')
set @6 = DSQLT.RecordCompareExpression(@2,@1,'S','T',@UseDefaultValues,@IgnoreColumnList)
set @7 = DSQLT.UpdateColumnList(@2,@1,'S',@IgnoreColumnList)
set @8 = (Select TOP 1 ColumnQ from [DSQLT].[Columns] (@PKTable) where is_primary_key=1 order by [Order])

exec DSQLT.[Execute] 'DSQLT.@CompareTable',@1,@2,@3,@4,@5,@6,@7,@8, @Create=@Create, @UseTransaction=@UseTransaction, @Print=@Print

RETURN -- Ab hier beginnt das eigentliche Template
BEGIN
-- nicht mehr vorhandene Datensätze 
select 'D' as CompareStatus, T.*
from [@1].[@1] T
left outer join [@2].[@2] S 
	on (@5=@5)
where S.[@8] is null

UNION

-- veränderte Datensätze updaten
select 'U' as CompareStatus, T.*
from [@1].[@1] T
join [@2].[@2] S 
	on (@5=@5)
where (@6=@6) 

UNION

-- neue Datensätze 
select 'I' as CompareStatus, S.*
from [@1].[@1] T
right outer join [@2].[@2] S 
	on (@5=@5)
where T.[@8] is null

END
GO
PRINT N'[DSQLT].[Execute] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[Execute]
@DSQLTProc NVARCHAR (MAX)
, @p1 NVARCHAR (MAX)=null
, @p2 NVARCHAR (MAX)=null
, @p3 NVARCHAR (MAX)=null
, @p4 NVARCHAR (MAX)=null
, @p5 NVARCHAR (MAX)=null
, @p6 NVARCHAR (MAX)=null
, @p7 NVARCHAR (MAX)=null
, @p8 NVARCHAR (MAX)=null
, @p9 NVARCHAR (MAX)=null
, @Database [sysname]=null
, @Template NVARCHAR (MAX)=null OUTPUT
, @Create NVARCHAR (MAX)=null
, @CreateParam NVARCHAR (MAX)=''
, @UseTransaction bit = 0
, @Print BIT=0
AS
BEGIN
SET NOCOUNT ON
--if @Database is null
--	SET @Database=DB_NAME()
exec DSQLT._fillDatabaseTemplate @p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=@Database OUTPUT

-- Template holen	
if @DSQLTProc is not null  -- es kann auch ein Template direkt übergeben werden
	exec DSQLT._getTemplate @DSQLTProc, @Template OUTPUT

exec [DSQLT].[_addTransaction] 	@Template OUTPUT,@Database,@UseTransaction

if @Create is not null 
	BEGIN
	exec DSQLT._fillTemplate @p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database,@Template=@Create OUTPUT
	exec DSQLT._addCreateStub @Template OUTPUT,@Database,@Create,@CreateParam
	END

-- Parameter ersetzen
exec DSQLT._fillTemplate @p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database,@Template=@Template OUTPUT

-- ausführen/drucken
exec DSQLT._doTemplate @Database,@Template,@Print
RETURN 0
END
GO
PRINT N'[DSQLT].[Iterate] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[Iterate]
@DSQLTProc NVARCHAR (MAX)=null
, @Cursor CURSOR VARYING OUTPUT
, @p1 NVARCHAR (MAX)=null
, @p2 NVARCHAR (MAX)=null
, @p3 NVARCHAR (MAX)=null
, @p4 NVARCHAR (MAX)=null
, @p5 NVARCHAR (MAX)=null
, @p6 NVARCHAR (MAX)=null
, @p7 NVARCHAR (MAX)=null
, @p8 NVARCHAR (MAX)=null
, @p9 NVARCHAR (MAX)=null
, @Database [sysname]=null
, @Template NVARCHAR (MAX)=null OUTPUT
, @Create NVARCHAR (MAX)=null
, @CreateParam NVARCHAR (MAX)=''
, @UseTransaction bit = 0
, @Once BIT=0
, @Deallocate BIT = 1
, @Print BIT=0
AS
Begin
SET NOCOUNT ON
if @Database is null
	SET @Database=DB_NAME()

-- Template holen
if @DSQLTProc is not null  -- es kann auch ein Template direkt übergeben werden
	exec DSQLT._getTemplate @DSQLTProc, @Template OUTPUT
	
-- Template iterieren 
exec DSQLT._iterateTemplate @Cursor,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database,@Template OUTPUT
	,@Create=@Create,@CreateParam=@CreateParam,@UseTransaction=@UseTransaction,@Once=@Once,@Print=@Print

if @Deallocate = 1
	deallocate @Cursor

end
GO
PRINT N'[DSQLT].[_iterateTemplate] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[_iterateTemplate]
@Cursor CURSOR VARYING OUTPUT
, @p1 NVARCHAR (MAX)=null
, @p2 NVARCHAR (MAX)=null
, @p3 NVARCHAR (MAX)=null
, @p4 NVARCHAR (MAX)=null
, @p5 NVARCHAR (MAX)=null
, @p6 NVARCHAR (MAX)=null
, @p7 NVARCHAR (MAX)=null
, @p8 NVARCHAR (MAX)=null
, @p9 NVARCHAR (MAX)=null
, @Database NVARCHAR (MAX)=null
, @Template NVARCHAR (MAX)=null OUTPUT
, @Create NVARCHAR (MAX)=null
, @CreateParam NVARCHAR (MAX)=''
, @UseTransaction bit = 0
, @Once BIT=0
, @Print BIT=0
AS
Begin
DECLARE @TemplateConcat nvarchar(max)
DECLARE @Temp nvarchar(max)
DECLARE @TempCreate nvarchar(max)
DECLARE @TempDatabase nvarchar(max)
DECLARE @OrgDatabase nvarchar(max)
DECLARE @c1 nvarchar(max)
DECLARE @c2 nvarchar(max)
DECLARE @c3 nvarchar(max) 
DECLARE @c4 nvarchar(max)
DECLARE @c5 nvarchar(max)
DECLARE @c6 nvarchar(max)
DECLARE @c7 nvarchar(max)
DECLARE @c8 nvarchar(max)
DECLARE @c9 nvarchar(max)
DECLARE	@Count int

set @TemplateConcat ='' 
set @Temp  ='' 
set @TempCreate  ='' 
set	@Count = 0
set @OrgDatabase=@Database

open @Cursor
while (1=1)
begin
	if @count=0
	BEGIN  -- feststellen der Anzahl Spalten, die vom Cursor zurückgeliefert werden
		begin try 
			set @count=1
			fetch first from @Cursor into @c1
			SET @c2=@p1
			SET @c3=@p2
			SET @c4=@p3
			SET @c5=@p4
			SET @c6=@p5
			SET @c7=@p6
			SET @c8=@p7
			SET @c9=@p8
			continue
		end try 
		begin catch
			set @count=2
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2
			SET @c3=@p1
			SET @c4=@p2
			SET @c5=@p3
			SET @c6=@p4
			SET @c7=@p5
			SET @c8=@p6
			SET @c9=@p7
			continue
		end try 
		begin catch
			set @count=3
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3
			SET @c4=@p1
			SET @c5=@p2
			SET @c6=@p3
			SET @c7=@p4
			SET @c8=@p5
			SET @c9=@p6
			continue
		end try 
		begin catch
			set @count=4
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4
			SET @c5=@p1
			SET @c6=@p2
			SET @c7=@p3
			SET @c8=@p4
			SET @c9=@p5
			continue
		end try 
		begin catch
			set @count=5
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5
			SET @c6=@p1
			SET @c7=@p2
			SET @c8=@p3
			SET @c9=@p4
			continue
		end try 
		begin catch
			set @count=6
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6
			SET @c7=@p1
			SET @c8=@p2
			SET @c9=@p3
			continue
		end try 
		begin catch
			set @count=7
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7
			SET @c8=@p1
			SET @c9=@p2
			continue
		end try 
		begin catch
			set @count=8
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8
			SET @c9=@p1
			continue
		end try 
		begin catch
			set @count=9
		end catch
		begin try 
			fetch first from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9
			continue
		end try 
		begin catch
		print @count
			-- Spaltenanzahl nicht zwischen 1 und 9
		end catch
		Break  -- erfolglos
	END
	IF (@@FETCH_STATUS <> 0) break  -- alle Datensätze geholt
	
	set @Database=@OrgDatabase
		-- Parameterersetzung für Datenbanknamen
	exec DSQLT._fillDatabaseTemplate  @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9 ,@Database=@Database OUTPUT

	SET @Temp=@Template 
	IF @Once=0  -- jedesmal mit Transaktion umfassen
		exec [DSQLT].[_addTransaction] 	@Temp OUTPUT,@Database,@UseTransaction

	-- Prozedurrumpf mit DDL umfassen, falls Create 
	-- wichtig: generell Parameterersetzung wie bei Template
	if @Create is not null and (@Once=0 or @TempCreate='')  -- bei once=0 ODER beim ersten Mal
		BEGIN
		SET @TempDatabase=@Database
		SET @TempCreate=@Create 
		exec DSQLT._fillTemplate @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9 ,@Database,@Template=@TempCreate OUTPUT
		if @Once=0	-- dann wird je Iteration eine Stored Proc generiert
			exec DSQLT._addCreateStub @Temp OUTPUT,@Database,@TempCreate
		END
		
	exec DSQLT._fillTemplate @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9 ,@Database,@Template=@Temp OUTPUT

	-- ausführen oder verketten
	IF @Once=0  -- ausführen / drucken
		exec DSQLT._doTemplate @Database,@Temp,@Print
		
	-- immer verketten, stört nicht
	SET @TemplateConcat=@TemplateConcat+@Temp+DSQLT.CRLF()

	IF @Count = 1 fetch next from @Cursor into @c1
	IF @Count = 2 fetch next from @Cursor into @c1,@c2
	IF @Count = 3 fetch next from @Cursor into @c1,@c2,@c3
	IF @Count = 4 fetch next from @Cursor into @c1,@c2,@c3,@c4
	IF @Count = 5 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5
	IF @Count = 6 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6
	IF @Count = 7 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7
	IF @Count = 8 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8
	IF @Count = 9 fetch next from @Cursor into @c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9
end
close @Cursor
--deallocate @Cursor

--  ausführen, falls einmalig
if @Once=1
	BEGIN
	exec [DSQLT].[_addTransaction] 	@TemplateConcat OUTPUT,@Database,@UseTransaction
	IF @Create is not null  -- einmalig Prozedurrumpf
		exec DSQLT._addCreateStub @TemplateConcat OUTPUT,@TempDatabase,@TempCreate
	exec DSQLT._doTemplate @TempDatabase,@TemplateConcat,@Print
	END

-- Rückgabe der Verkettung
SET @Template =@TemplateConcat
	
end
GO
PRINT N'[DSQLT].[@isProc] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@isProc]
@Database [sysname], @Schema [sysname], @Table [sysname], @Print BIT=0
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
DECLARE @Template varchar(max)
exec DSQLT.[Execute] '@isProc',@Schema,@Table,@Template=@Template OUTPUT, @Print=null
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[@1].[@2]') AND type in (N'P', N'PC'))
		SELECT 1
	ELSE
		SELECT 0
END
GO
PRINT N'[DSQLT].[@getObjectDefinition] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@getObjectDefinition]
@Database [sysname], @Schema [sysname], @Object [sysname], @Template NVARCHAR (MAX) OUTPUT, @Print BIT=0
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result nvarchar(max))
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
exec DSQLT.[Execute] '@getObjectDefinition',@Schema,@Object,@Template=@Template OUTPUT, @Print=null  -- unterdrückt die Ausführung, gibt nur an Template zurück!!
-- Template ausführen, Ergebnis über tem. Tabelle holen
INSERT INTO @ResultTable 
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Template=result from @ResultTable
RETURN 
BEGIN
	Select OBJECT_DEFINITION(OBJECT_ID('[@1].[@2]'))
END
GO
PRINT N'[DSQLT].[@CreateSchema] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@CreateSchema]
@Database [sysname], @Schema [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@CreateSchema',@Schema,@Database=@Database,@Print=@Print
RETURN
BEGIN
DECLARE @Result int
exec @Result=DSQLT.DSQLT.[@isSchema] '[@0]','[@1]'
IF @Result=0
	BEGIN
	declare @Template nvarchar(max)
	SET @Template ='CREATE SCHEMA [@1]'
	exec (@Template)
	END
END
GO
PRINT N'[DSQLT].[@isSchema] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@isSchema]
@Database [sysname], @Schema [sysname], @Print BIT=0
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
DECLARE @Template varchar(max)
exec DSQLT.[Execute] '@isSchema',@Schema,@Template=@Template OUTPUT, @Print=null
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result
BEGIN
	IF  EXISTS (SELECT * FROM sys.schemas WHERE schema_id = SCHEMA_ID('@1') or QUOTENAME([name])= '[@1]')
		SELECT 1
	ELSE
		SELECT 0
END
GO
PRINT N'[DSQLT].[@DropDatabase] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@DropDatabase]
@Database [sysname]=null, @Print BIT=0
AS
exec DSQLT.[Execute] '@DropDatabase' ,@p1=@Database,@Print=@Print
RETURN 0
BEGIN
DROP DATABASE [@1]
END
GO
PRINT N'[DSQLT].[@DropFunction] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@DropFunction]
@Database [sysname], @Schema [sysname], @Function [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropFunction',@Schema,@Function,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP FUNCTION [@1].[@2]
END
GO
PRINT N'[DSQLT].[@DropProcedure] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@DropProcedure]
@Database [sysname], @Schema [sysname], @Procedure [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropProcedure',@Schema,@Procedure,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP PROCEDURE [@1].[@2]
END
GO
PRINT N'[DSQLT].[@CopyTable] wird erstellt....';


GO


CREATE PROCEDURE [DSQLT].[@CopyTable]
@TargetDB [sysname], @Schema [sysname], @Table [sysname], @Print INT=0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Execute] '@CopyTable',@Schema,@Table,@SourceDB,@Print=@Print,@Database=@TargetDB
RETURN
BEGIN
declare @Template varchar(max)
set @Template =''
declare @rc int
-- Prüfen, ob Quellobjekt existiert
exec @rc=DSQLT.DSQLT.[@isTable] '@3','@1','@2'
if @rc=1  -- ja
	BEGIN
	-- Prüfen, ob Zielobjekt gelöscht werden muss
	exec @rc=DSQLT.DSQLT.[@isTable] '@0','@1','@2'
	if @rc=1
		exec DSQLT.DSQLT.[@DropTable] '@0','@1','@2'
	-- dann Objekt erzeugen
	Select * 
	INTO [@0].[@1].[@2]
	from [@3].[@1].[@2]
	END
	print '@2'
END
GO
PRINT N'[DSQLT].[@GenerateDatabase] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@GenerateDatabase]
@Database [sysname]=null, @Print BIT=0
AS
declare @path varchar(max)
select top 1 @path=physical_name from sys.database_files
declare @pos int
set @pos = CHARINDEX('\',REVERSE(@path))
SET @path=LEFT(@path,len(@path)-@pos+1)

exec DSQLT.[Execute] '@GenerateDatabase' ,@Database,@Path,@Print=@Print
RETURN 0
BEGIN
CREATE DATABASE [@1] ON  PRIMARY 
( NAME = N'@1', FILENAME = N'@2@1.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'@1_log', FILENAME = N'@2@1.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
ALTER DATABASE [@1] SET  READ_WRITE 
ALTER DATABASE [@1] SET RECOVERY FULL 
ALTER DATABASE [@1] SET  MULTI_USER 
ALTER DATABASE [@1] SET PAGE_VERIFY CHECKSUM  
ALTER DATABASE [@1] SET DB_CHAINING OFF 
END
GO
PRINT N'[DSQLT].[@GenerateTable] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@GenerateTable]
@Database [sysname], @Schema [sysname], @Table [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@GenerateTable',@Schema,@Table,@Print=@Print,@Database=@Database
RETURN
BEGIN
	DECLARE @Result int
	exec @Result=DSQLT.DSQLT.[@isTable] '[@0]','[@1]','[@2]'
	IF @Result=1
			exec DSQLT.DSQLT.[@DropTable] '[@0]','[@1]','[@2]'

	CREATE TABLE [@1].[@2](
		"[@1]" [nvarchar](max) NOT NULL,
		"[@2]" [nvarchar](max) NOT NULL,
		"[@3]" [nvarchar](max) NOT NULL,
		"[@4]" [nvarchar](max) NOT NULL,
		"[@5]" [nvarchar](max) NOT NULL,
		"[@6]" [nvarchar](max) NULL,
		"[@7]" [nvarchar](max) NULL,
		"[@8]" [nvarchar](max) NULL,
		"[@9]" [nvarchar](max) NULL
	) ON [PRIMARY]
END
GO
PRINT N'[DSQLT].[@DropTable] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@DropTable]
@Database [sysname], @Schema [sysname], @Table [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropTable',@Schema,@Table,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP TABLE [@1].[@2]
END
GO
PRINT N'[DSQLT].[@@GenerateTable] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@@GenerateTable]
@Cursor CURSOR VARYING OUTPUT, @Database [sysname], @Print BIT=0
AS
exec DSQLT.iterate '@GenerateTable',@Cursor,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[@addSyncFields] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@addSyncFields]
@p1 NVARCHAR (MAX)=null, @Database [sysname]=null, @Print BIT=0
AS
exec DSQLT.[Execute] 'DSQLT.@addSyncFields' ,@p1,@Database=@Database,@Print=@Print
RETURN 0
BEGIN
alter TABLE [@1].[@1]
add
	[DSQLT_SyncRowCreated] [datetime] NULL,
	[DSQLT_SyncRowModified] [datetime] NULL,
	[DSQLT_SyncRowIsDeleted] [bit] NULL

ALTER TABLE [@1].[@1] ADD  CONSTRAINT [DF_@1_DSQLT_SyncRowCreated]  DEFAULT (getdate()) FOR [DSQLT_SyncRowCreated]
ALTER TABLE [@1].[@1] ADD  CONSTRAINT [DF_@1_DSQLT_SyncRowModified]  DEFAULT (getdate()) FOR [DSQLT_SyncRowModified]
ALTER TABLE [@1].[@1] ADD  CONSTRAINT [DF_@1_DSQLT_SyncRowIsDeleted]  DEFAULT ((0)) FOR [DSQLT_SyncRowIsDeleted]
END
GO
PRINT N'[DSQLT].[@CopyFunction] wird erstellt....';


GO


CREATE PROCEDURE [DSQLT].[@CopyFunction]
@TargetDB [sysname], @Schema [sysname], @Function [sysname], @Print INT=0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Execute] '@CopyFunction',@Schema,@Function,@SourceDB,@Print=@Print,@Database=@TargetDB
RETURN
BEGIN
declare @Template varchar(max)
set @Template =''
declare @rc int
-- Prüfen, ob Quellobjekt existiert
exec @rc=DSQLT.DSQLT.[@isFunc] '@3','@1','@2'
if @rc=1  -- ja,dann Definition holen
	exec DSQLT.DSQLT.[@getObjectDefinition] '@3','@1','@2',@Template output
-- falls geklappt
if @Template is not null
	BEGIN
	-- Prüfen, ob Zielobjekt gelöscht werden muss
	exec @rc=DSQLT.DSQLT.[@isFunc] '@0','@1','@2'
	if @rc=1
		exec DSQLT.DSQLT.[@DropFunction] '@0','@1','@2'
	-- dann Objekt erzeugen
	exec (@Template)
	print '@2'
	END
END
GO
PRINT N'[DSQLT].[@isFunc] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@isFunc]
@Database [sysname], @Schema [sysname], @Table [sysname], @Print BIT=0
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
DECLARE @Template varchar(max)
-- Template (unten zwischen BEGIN und END) holen
exec DSQLT.[Execute] '@isFunc',@Schema,@Table,@Template=@Template OUTPUT, @Print=null  -- unterdrückt die Ausführung, gibt nur an Template zurück!!
-- Template ausführen, Ergebnis über tem. Tabelle holen
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result 
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[@1].[@2]') AND type in (N'AF',N'FN',N'FS',N'FT',N'IF',N'TF'))
		SELECT 1
	ELSE
		SELECT 0
END
GO
PRINT N'[DSQLT].[@CopyProcedure] wird erstellt....';


GO


CREATE PROCEDURE [DSQLT].[@CopyProcedure]
@TargetDB [sysname], @Schema [sysname], @Procedure [sysname], @Print INT=0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Execute] '@CopyProcedure',@Schema,@Procedure,@SourceDB,@Print=@Print,@Database=@TargetDB
RETURN
BEGIN
declare @Template varchar(max)
set @Template =''
declare @rc int
-- Prüfen, ob Quellobjekt existiert
exec @rc=DSQLT.DSQLT.[@isProc] '@3','@1','@2'
if @rc=1  -- ja,dann Definition holen
	exec DSQLT.DSQLT.[@getObjectDefinition] '@3','@1','@2',@Template output
-- falls geklappt
if @Template is not null
	BEGIN
	-- Prüfen, ob Zielobjekt gelöscht werden muss
	exec @rc=DSQLT.DSQLT.[@isProc] '@0','@1','@2'
	if @rc=1
		exec DSQLT.DSQLT.[@DropProcedure] '@0','@1','@2'
	-- dann Objekt erzeugen
	exec (@Template)
	print '@2'
	END
END
GO
PRINT N'[DSQLT].[@@CopyTable] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@@CopyTable]
@Cursor CURSOR VARYING OUTPUT, @Database [sysname], @Print BIT=0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.iterate '@CopyTable',@Cursor,@SourceDB,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[@isView] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@isView]
@Database [sysname], @Schema [sysname], @View [sysname], @Print BIT=0
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
DECLARE @Template varchar(max)
exec DSQLT.[Execute] '@isView',@Schema,@View,@Template=@Template OUTPUT, @Print=null
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[@1].[@2]')  AND type in (N'V'))
		SELECT 1
	ELSE
		SELECT 0
END
GO
PRINT N'[DSQLT].[@@GenerateSchema] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@@GenerateSchema]
@Cursor CURSOR VARYING OUTPUT, @Database [sysname], @Print BIT=0
AS
exec DSQLT.iterate '@GenerateSchema',@Cursor,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[_generateDatabase] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_generateDatabase]
@Database [sysname], @Print INT=0
AS
BEGIN
-- nur bei den "eigenen" Parameter-Datenbanken ggf. löschen
if DSQLT.QuoteNameSB(@Database) in (select ParameterQ from [DSQLT].[Digits](0,9))  
	IF DSQLT.isDatabase(@Database)=1  -- wenn schon existiert, dann löschen
		exec DSQLT.[@DropDatabase] @Database,@Print=@Print
		
-- wenn noch nicht existiert, dann erzeugen		
IF DSQLT.isDatabase(@Database)=0  
	exec DSQLT.[@GenerateDatabase] @Database,@Print=@Print

-- die nach Parameter benannten Tabellen im Schema dbo erzeugen	
exec DSQLT.[@GenerateSchema] @Database,'dbo',@Print=@Print

-- die nach Parameter benannten Schemas und Tabellen erzeugen	
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select ParameterQ from [DSQLT].[Digits] (1,9)
exec DSQLT.[@@GenerateSchema] @Cursor,@Database=@Database,@Print=@Print

-- die speziell geänderten Tabellen übertragen
exec [DSQLT].[@CopyTable] @TargetDB=@Database , @Schema='@1' ,@Table ='@1' , @Print=@Print
exec [DSQLT].[@CopyTable] @TargetDB=@Database , @Schema='@3' ,@Table ='@3' , @Print=@Print

---- das Schema DSQLT mit Functions und Procedures erzeugen
exec DSQLT._generateDSQLT @Database,@Print=@Print

END
GO
PRINT N'[DSQLT].[@@PrintParameter] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@@PrintParameter]
@Cursor CURSOR VARYING OUTPUT, @p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database [sysname]=null, @Print BIT=0
AS
exec DSQLT.iterate '@PrintParameter',@Cursor,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[@GenerateSchema] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@GenerateSchema]
@Database [sysname], @Schema [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@GenerateSchema',@Schema,@Database=@Database,@Print=@Print
RETURN
BEGIN
exec DSQLT.DSQLT._generateSchema '[@0]','[@1]'
END
GO
PRINT N'[DSQLT].[_generateSchema] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_generateSchema]
@Database [sysname], @Schema [sysname], @Print BIT=0
AS
BEGIN
-- Schema erzeugen, falls noch nicht existiert
DECLARE @Result int
exec @Result=DSQLT.[@isSchema] @Database,@Schema
IF @Result=0
	exec DSQLT.[@CreateSchema] @Database,@Schema,@Print
-- alle Tabellen erzeugen
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select @Schema,ParameterQ from [DSQLT].[Digits] (1,9)
exec DSQLT.[@@GenerateTable] @Cursor,@Database=@Database,@Print=@Print
	
END
GO
PRINT N'[DSQLT].[@PrimaryKeyErrorCleanUp] wird erstellt....';


GO
create PROCEDURE [DSQLT].[@PrimaryKeyErrorCleanUp]
	 @SourceSchema sysname = null
	,@SourceTable sysname= null
	,@PrimaryKeySchema sysname=null
	,@PrimaryKeyTable sysname=null
	,@Create varchar(max)=null
	,@Print bit = 0
AS
DECLARE	@Source NVARCHAR (MAX)
DECLARE @PKTable NVARCHAR (MAX)   -- Tabelle mit Primärkeydefinition
DECLARE	@PrimaryKeyExpression NVARCHAR (MAX)
DECLARE	@Template NVARCHAR (MAX)

SET	@Template =''
SET @Source=DSQLT.QuoteNameSB(@SourceSchema+'.'+@SourceTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeySchema+'.'+@PrimaryKeyTable)
if @PKTable is null SET @PKTable=@Source
set @PrimaryKeyExpression = DSQLT.PrimaryKeyConcatExpression(@PKTable,'')

exec DSQLT.[Execute] 'DSQLT.@PrimaryKeyErrorCleanUp' 
	,@Source -- @1
	,@PrimaryKeyExpression -- @2
	,@Create=@Create
	,@Print=@Print

RETURN 
DECLARE @2 as int  -- to avoid Syntax error
BEGIN
-- wenn NULL vorkommt
	DELETE FROM [@1].[@1] 
	where @2 is null   
-- mehrfache Datensätze
	DELETE FROM [@1].[@1] 
	where @2 in (
		select @2 FROM [@1].[@1]  
		where @2 is not null  
		group by "@2"
		having COUNT(*) > 1
		)
END
GO
PRINT N'[DSQLT].[_generateDSQLT] wird erstellt....';


GO



CREATE PROCEDURE [DSQLT].[_generateDSQLT]
@Database [sysname], @Print INT=0
AS
BEGIN
DECLARE @SourceDB sysname
DECLARE @Schema sysname
DECLARE @WildCard sysname

SET @SourceDB =DB_NAME()
SET @Schema ='DSQLT'
SET @WildCard =@Schema+'.%'

-- Schema erzeugen, falls noch nicht existiert
exec DSQLT.[@CreateSchema] @Database,@Schema,@Print
-- über alle Func iterieren
print 'Functions'
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Function],@SourceDB as [Database] from [DSQLT].Functions(@WildCard) 
exec [DSQLT].[@@CopyFunction] @Cursor,@Database=@Database,@Print=@Print
-- über alle Prozeduren iterieren
print 'Procedures'
SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Procedure],@SourceDB as [Database] from [DSQLT].[Procedures](@WildCard) 
exec [DSQLT].[@@CopyProcedure] @Cursor,@Database=@Database,@Print=@Print
print 'Tables'
-- über alle Tabellen iterieren
SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Table],@SourceDB as [Database] from [DSQLT].Tables(@WildCard) 
exec [DSQLT].[@@CopyTable] @Cursor,@Database=@Database,@Print=@Print
	
print 'Schema @1'
set @Schema ='@1'
-- Schema erzeugen, falls noch nicht existiert
exec DSQLT.[@CreateSchema] @Database,@Schema,@Print
-- über alle Prozeduren iterieren
SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Procedure],@SourceDB as [Database] from [DSQLT].[Procedures](@WildCard) 
exec [DSQLT].[@@CopyProcedure] @Cursor,@Database=@Database,@Print=@Print

END
GO
PRINT N'[DSQLT].[@@CopyFunction] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@@CopyFunction]
@Cursor CURSOR VARYING OUTPUT, @Database [sysname], @Print BIT=0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.iterate '@CopyFunction',@Cursor,@SourceDB,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[@@CopyProcedure] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@@CopyProcedure]
@Cursor CURSOR VARYING OUTPUT, @Database [sysname], @Print BIT=0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.iterate '@CopyProcedure',@Cursor,@SourceDB,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[@isSynonym] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@isSynonym]
@Database [sysname], @Schema [sysname], @Synonym [sysname], @Print BIT=0
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
DECLARE @Template varchar(max)
exec DSQLT.[Execute] '@isSynonym',@Schema,@Synonym,@Template=@Template OUTPUT, @Print=null
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[@1].[@2]') AND type in (N'SN'))
		SELECT 1
	ELSE
		SELECT 0
END
GO
PRINT N'[DSQLT].[@DropView] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[@DropView]
@Database [sysname], @Schema [sysname], @View [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropView',@Schema,@View,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP VIEW [@1].[@2]
END
GO
PRINT N'[DSQLT].[_generateDSQLTStub] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[_generateDSQLTStub]
@Schema [sysname], @Procedure [sysname], @Database [sysname], @Print BIT=0, @Iterate BIT=0
AS
BEGIN
declare @Stub varchar(max)
declare @Template varchar(max)
declare @ErrorMsg varchar(max)
SET @Stub='@@2'
SET @Template=''
if @Iterate=1 set @Stub='@'+@Stub
SET @ErrorMsg ='Template @1.'+@Stub+' nicht gefunden'

declare @rc int
-- Prüfen, ob Zielobjekt existiert
exec @rc=DSQLT.[@isProc] @Database,@Schema,@Procedure
if @rc=0  -- nein,dann Definition für Stub holen
	exec [DSQLT].[@getObjectDefinition] null,'@1',@Stub,@Template output
else 
	exec DSQLT._error 'Ziel existiert bereits'
-- falls geklappt,dann Objekt erzeugen
if @Template is not null
	exec DSQLT.[Execute] null,@Schema,@Procedure, @Database=@Database,@Template=@Template,@Print=@Print
else 
	exec DSQLT._error @ErrorMsg
END
GO
PRINT N'[DSQLT].[@CopyView] wird erstellt....';


GO




CREATE PROCEDURE [DSQLT].[@CopyView]
@TargetDB [sysname], @Schema [sysname], @View [sysname], @Print INT=0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Execute] '@CopyView',@Schema,@View,@SourceDB,@Print=@Print,@Database=@TargetDB
RETURN
BEGIN
declare @Template varchar(max)
set @Template =''
declare @rc int
-- Prüfen, ob Quellobjekt existiert
exec @rc=DSQLT.DSQLT.[@isView] '@3','@1','@2'
if @rc=1  -- ja,dann Definition holen
	exec DSQLT.DSQLT.[@getObjectDefinition] '@3','@1','@2',@Template output
-- falls geklappt
if @Template is not null
	BEGIN
	-- Prüfen, ob Zielobjekt gelöscht werden muss
	exec @rc=DSQLT.DSQLT.[@isView] '@0','@1','@2'
	if @rc=1
		exec DSQLT.DSQLT.[@DropView] '@0','@1','@2'
	-- dann Objekt erzeugen
	exec (@Template)
	print '@2'
	END
END
GO
PRINT N'[DSQLT].[@CopyTableContent] wird erstellt....';


GO


CREATE PROCEDURE DSQLT.[@CopyTableContent]
@Database [sysname], @Schema [sysname], @Table [sysname], @Print INT=0
AS
Declare @3 nvarchar(max)
	Declare @4 nvarchar(max)
	set @3 = DSQLT.ColumnList(@Schema+'.'+@Table)
	set @4 = DB_NAME()
	exec DSQLT.[Execute] '[DSQLT].@CopyTableContent',@Schema,@Table,@3,@4,@Database=@Database,@Print=@Print
RETURN
BEGIN
-- @0 = Zieldatenbank ist die aktuelle 
-- @1 = Schema
-- @2 = Tabelle 
-- @3 = Feldliste der Tabelle
-- @4 = Quelldatenbank
-- prüfen, ob Tabelle Identity Feld hat, falls ja, dann Insert erlauben
IF IDENT_SEED('[@1].[@2]') is not null
	SET IDENTITY_INSERT [@1].[@2] ON

-- Tabelle löschen (Truncate geht nur, wenn sicher keine Foreign Keys auf die Tabelle verweisen)
BEGIN TRY
	truncate table [@1].[@2] 
END TRY
BEGIN CATCH 
	delete from [@1].[@2]  
END CATCH

-- Aus Quelldatenbank einfügen
insert into [@1].[@2] ("@3")
	select "@3" from [@4].[@1].[@2]
	
-- prüfen, ob Tabelle Identity Feld hat, falls ja, dann Insert abschalten
IF IDENT_SEED('[@1].[@2]') is not null
	SET IDENTITY_INSERT [@1].[@2] OFF

END
GO
PRINT N'[DSQLT].[@@CopyView] wird erstellt....';


GO


create PROCEDURE [DSQLT].[@@CopyView]
@Cursor CURSOR VARYING OUTPUT, @Database [sysname], @Print BIT=0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Iterate] '@CopyView',@Cursor,@SourceDB,@Database=@Database,@Print=@Print
RETURN 0
GO
PRINT N'[DSQLT].[@MergeTable] wird erstellt....';


GO


CREATE PROCEDURE [DSQLT].[@MergeTable] 
 @SourceSchema sysname = null
,@SourceTable sysname= null
,@TargetSchema sysname= null
,@TargetTable sysname= null
,@PrimaryKeySchema sysname=null
,@PrimaryKeyTable sysname=null
,@IgnoreColumnList varchar(max)=''
,@UseDefaultValues bit=0
,@Create varchar(max)=null
,@UseTransaction bit = 0
,@Print bit = 0
as
declare @1 varchar(max) -- Target
declare @2 varchar(max) -- Source
declare @3 varchar(max) -- InsertColumnList
declare @4 varchar(max) -- SelectValueList
declare @5 varchar(max) -- PrimaryKeyCompareExpression
declare @6 varchar(max) -- RecordCompareExpression
declare @7 varchar(max) -- UpdateColumnList
declare @8 varchar(max) -- Primärkeyfeld für Existenzprüfung
declare @PKTable varchar(max)   -- Tabelle mit Primärkeydefinition

IF @SourceSchema is not null
	set @SourceTable=@SourceSchema+'.'+@SourceTable
	
IF @TargetSchema is not null
	set @TargetTable=@TargetSchema+'.'+@TargetTable
	
IF @PrimaryKeySchema is not null
	set @PrimaryKeyTable=@PrimaryKeySchema+'.'+@PrimaryKeyTable
	
set @1 = DSQLT.QuoteNameSB(@TargetTable)
set @2 = DSQLT.QuoteNameSB(@SourceTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeyTable)

-- Prüfen, wer einen PK definiert hat
if @PKTable is null 
	SET @PKTable=@1  -- vielleicht Target??

DECLARE @c int
SELECT @c=count(*) from [DSQLT].[Columns] (@PKTable) where is_primary_key=1
IF @c=0
	SET @PKTable=@2  -- vielleicht Source??
	
SELECT @c=count(*) from [DSQLT].[Columns] (@PKTable) where is_primary_key=1
IF @c=0
	RETURN -1 -- FEhler

set @3 = DSQLT.InsertColumnList(@1,'')
set @4 = DSQLT.SelectValueList(@2,@1,'S','')
set @5 = DSQLT.PrimaryKeyCompareExpression(@PKTable,'S','T')
set @6 = DSQLT.RecordCompareExpression(@2,@1,'S','T',@UseDefaultValues,@IgnoreColumnList)
set @7 = DSQLT.UpdateColumnList(@2,@1,'S',@IgnoreColumnList)
set @8 = (Select TOP 1 ColumnQ from [DSQLT].[Columns] (@PKTable) where is_primary_key=1 order by [Order])

exec DSQLT.[Execute] 'DSQLT.@MergeTable',@1,@2,@3,@4,@5,@6,@7,@8, @Create=@Create, @UseTransaction=@UseTransaction, @Print=@Print

RETURN -- Ab hier beginnt das eigentliche Template
BEGIN
-- für SQL 2008
--MERGE [@1].[@1] T
--USING [@2].[@2] S 
--	on (@5=@5)
--WHEN MATCHED and (@6=@6) THEN 
--    UPDATE SET @7=@7  
--WHEN NOT MATCHED BY TARGET THEN
--    INSERT ("@3")
--    VALUES ("@4")
--WHEN NOT MATCHED BY SOURCE THEN
--    DELETE
--;

-- nicht mehr vorhandene Datensätze löschen
delete [@1].[@1] 
from [@1].[@1] T
left outer join [@2].[@2] S 
	on (@5=@5)
where S.[@8] is null

-- veränderte Datensätze updaten
update [@1].[@1] 
set @7=@7 
from [@1].[@1] T
join [@2].[@2] S 
	on (@5=@5)
where (@6=@6) 

-- neue Datensätze einfügen
insert into [@1].[@1]
("@3")
select @4 
from [@1].[@1] T
right outer join [@2].[@2] S 
	on (@5=@5)
where T.[@8] is null

END
GO
PRINT N'[DSQLT].[@MergeTableWithStatus] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[@MergeTableWithStatus] 
 @SourceSchema sysname = null
,@SourceTable sysname= null
,@TargetSchema sysname= null
,@TargetTable sysname= null
,@PrimaryKeySchema sysname=null
,@PrimaryKeyTable sysname=null
,@IgnoreColumnList varchar(max)=''
,@UseDefaultValues bit=0
,@Create varchar(max)=null
,@UseTransaction bit = 0
,@Print bit = 0
as
declare @1 varchar(max) -- Target
declare @2 varchar(max) -- Source
declare @3 varchar(max) -- InsertColumnList
declare @4 varchar(max) -- SelectValueList
declare @5 varchar(max) -- PrimaryKeyCompareExpression
declare @6 varchar(max) -- RecordCompareExpression
declare @7 varchar(max) -- UpdateColumnList
declare @8 varchar(max) -- Primärkeyfeld für Existenzprüfung
declare @PKTable varchar(max)   -- Tabelle mit Primärkeydefinition

IF @SourceSchema is not null
	set @SourceTable=@SourceSchema+'.'+@SourceTable
	
IF @TargetSchema is not null
	set @TargetTable=@TargetSchema+'.'+@TargetTable
	
IF @PrimaryKeySchema is not null
	set @PrimaryKeyTable=@PrimaryKeySchema+'.'+@PrimaryKeyTable
	
set @1 = DSQLT.QuoteNameSB(@TargetTable)
set @2 = DSQLT.QuoteNameSB(@SourceTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeyTable)

-- Prüfen, wer einen PK definiert hat
if @PKTable is null 
	SET @PKTable=@1  -- vielleicht Target??

DECLARE @c int
SELECT @c=count(*) from [DSQLT].[Columns] (@PKTable) where is_primary_key=1
IF @c=0
	SET @PKTable=@2  -- vielleicht Source??
	
SELECT @c=count(*) from [DSQLT].[Columns] (@PKTable) where is_primary_key=1
IF @c=0
	RETURN -1 -- FEhler

set @3 = DSQLT.InsertColumnList(@1,'')
set @4 = DSQLT.SelectValueList(@2,@1,'S','')
set @5 = DSQLT.PrimaryKeyCompareExpression(@PKTable,'S','T')
set @6 = DSQLT.RecordCompareExpression(@2,@1,'S','T',@UseDefaultValues,@IgnoreColumnList)
set @7 = DSQLT.UpdateColumnList(@2,@1,'S',@IgnoreColumnList)
set @8 = (Select TOP 1 ColumnQ from [DSQLT].[Columns] (@PKTable) where is_primary_key=1 order by [Order])

exec DSQLT.[Execute] 'DSQLT.@MergeTableWithStatus',@1,@2,@3,@4,@5,@6,@7,@8, @Create=@Create, @UseTransaction=@UseTransaction, @Print=@Print

RETURN -- Ab hier beginnt das eigentliche Template
BEGIN
-- für SQL 2008
--MERGE [@1].[@1] T
--USING [@2].[@2] S 
--	on (@5=@5)
--WHEN MATCHED THEN 
--    UPDATE SET DSQLT_SyncRowStatus=case when (@6=@6) then 2 else 0 end
--WHEN NOT MATCHED BY TARGET THEN
--    INSERT ("@3",DSQLT_SyncRowStatus)
--    VALUES ("@4",4)
--WHEN NOT MATCHED BY SOURCE THEN
--    UPDATE SET DSQLT_SyncRowStatus=1
--;

-- nicht mehr vorhandene Datensätze wieder einfügen
insert into [@1].[@1]
("@3",DSQLT_SyncRowStatus)
select @4 ,4  -- Status für "Gelöscht"
from [@1].[@1] T
right outer join [@2].[@2] S 
	on (@5=@5)
where T.[@8] is null

-- veränderte Datensätze : Status generell setzen
update [@1].[@1] 
SET DSQLT_SyncRowStatus=case when (@6=@6) then 2 else 0 end
from [@1].[@1] T
join [@2].[@2] S 
	on (@5=@5)

-- neue Datensätze markieren
UPDATE [@1].[@1]
SET DSQLT_SyncRowStatus=1
from [@1].[@1] T
left outer join [@2].[@2] S 
	on (@5=@5)
where S.[@8] is null

END
GO
PRINT N'[DSQLT].[@PrimaryKeyCheck] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@PrimaryKeyCheck]
	 @SourceSchema sysname = null
	,@SourceTable sysname= null
	,@PrimaryKeySchema sysname=null
	,@PrimaryKeyTable sysname=null
	,@ResultSchema sysname= null
	,@ResultTable sysname= null
	,@Create varchar(max)=null
	,@Print bit = 0
AS
DECLARE	@Source NVARCHAR (MAX)
DECLARE	@Result NVARCHAR (MAX)
DECLARE @PKTable NVARCHAR (MAX)   -- Tabelle mit Primärkeydefinition
DECLARE	@PrimaryKeyExpression NVARCHAR (MAX)
DECLARE	@Template NVARCHAR (MAX)

SET	@Template =''
SET @Source=DSQLT.QuoteNameSB(@SourceSchema+'.'+@SourceTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeySchema+'.'+@PrimaryKeyTable)
if @PKTable is null SET @PKTable=@Source
set @Result = DSQLT.QuoteNameSB(@ResultSchema+'.'+@ResultTable)
if @Result is null SET @Result='#T'  -- Kennzeichen für temporäre Tabelle.
set @PrimaryKeyExpression = DSQLT.PrimaryKeyConcatExpression(@PKTable,'S')


DECLARE @PrimaryKeyExpressionWithNull nvarchar(max)
SET @PrimaryKeyExpressionWithNull =''
select @PrimaryKeyExpressionWithNull=
	DSQLT.Concat('isnull('+Source_concatvalue+',''*NULL*'')',' + ',@PrimaryKeyExpressionWithNull)
from DSQLT.ColumnCompare(@PKTable , @PKTable , '' , '' )
where [is_primary_key]=1
order by [Order]

exec DSQLT.[Execute] 'DSQLT.@PrimaryKeyCheck' 
	,@Source -- @1
	,@PrimaryKeyExpression -- @2
	,@Result -- @3
	,@PrimaryKeyExpressionWithNull -- @4
	,@Create=@Create
	,@Print=@Print

RETURN 
DECLARE @2 as int  -- to avoid Syntax error
DECLARE @4 as int  -- to avoid Syntax error
BEGIN
IF '@3'='#T' 
	BEGIN
		SELECT TOP 0 * INTO #T FROM DSQLT.CompareResult
	END
	
-- feststellen, ob PrimaryKeyExpression NULL zurückgibt.
INSERT INTO [@3].[@3]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
 '@1'  -- @Source
,''  -- @Target
,@4 -- @PrimaryKeyExpressionWithNull,
,'*PK CONTAINS NULL*'  -- @ColumnName   leer, da nicht Feldspezifisch
,@2
,null  --
FROM [@1].[@1] S  -- @Source
where @2 is null   -- @ColumnCompareExpression]


-- feststellen, ob es mehrere Datensätze mit gleicher PrimaryKeyExpression gibt.
INSERT INTO [@3].[@3]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
 '@1'  -- @Source
,''  -- @Target
,@2 -- @PrimaryKeyExpressionWithNull,
,'*PK NOT UNIQUE*'  -- @ColumnName   leer, da nicht Feldspezifisch
,CAST(count(*) as varchar(max))  -- anzahl
,null  --
FROM [@1].[@1] S  -- @Source
where @2 is not null  
group by "@2"
having COUNT(*) > 1

IF '@3'='#T' 
	BEGIN
	select * from #T
	drop table #T
	END
END
GO
PRINT N'[DSQLT].[@SyncTable] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[@SyncTable] 
 @SourceSchema sysname = null
,@SourceTable sysname= null
,@TargetSchema sysname= null
,@TargetTable sysname= null
,@PrimaryKeySchema sysname=null
,@PrimaryKeyTable sysname=null
,@IgnoreColumnList varchar(max)=''
,@UseDefaultValues bit=0
,@Create varchar(max)=null
,@UseTransaction bit = 0
,@Print bit = 0
as
declare @1 varchar(max) -- Target
declare @2 varchar(max) -- Source
declare @3 varchar(max) -- InsertColumnList
declare @4 varchar(max) -- SelectValueList
declare @5 varchar(max) -- PrimaryKeyCompareExpression
declare @6 varchar(max) -- RecordCompareExpression
declare @7 varchar(max) -- UpdateColumnList
declare @8 varchar(max) -- Primärkeyfeld für Existenzprüfung
declare @PKTable varchar(max)   -- Tabelle mit Primärkeydefinition

IF @SourceSchema is not null
	set @SourceTable=@SourceSchema+'.'+@SourceTable
	
IF @TargetSchema is not null
	set @TargetTable=@TargetSchema+'.'+@TargetTable
	
IF @PrimaryKeySchema is not null
	set @PrimaryKeyTable=@PrimaryKeySchema+'.'+@PrimaryKeyTable
	
set @1 = DSQLT.QuoteNameSB(@TargetTable)
set @2 = DSQLT.QuoteNameSB(@SourceTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeyTable)

-- Prüfen, wer einen PK definiert hat
if @PKTable is null 
	SET @PKTable=@1  -- vielleicht Target??

DECLARE @c int
SELECT @c=count(*) from [DSQLT].[Columns] (@PKTable) where is_primary_key=1
IF @c=0
	SET @PKTable=@2  -- vielleicht Source??
	
SELECT @c=count(*) from [DSQLT].[Columns] (@PKTable) where is_primary_key=1
IF @c=0
	RETURN -1 -- FEhler

set @3 = DSQLT.InsertColumnList(@1,'')
set @4 = DSQLT.SelectValueList(@2,@1,'S','')
set @5 = DSQLT.PrimaryKeyCompareExpression(@PKTable,'S','T')
set @6 = DSQLT.RecordCompareExpression(@2,@1,'S','T',@UseDefaultValues,@IgnoreColumnList)
set @7 = DSQLT.UpdateColumnList(@2,@1,'S',@IgnoreColumnList)
set @8 = (Select TOP 1 ColumnQ from [DSQLT].[Columns] (@PKTable) where is_primary_key=1 order by [Order])

exec DSQLT.[Execute] 'DSQLT.@SyncTable',@1,@2,@3,@4,@5,@6,@7,@8, @Create=@Create, @UseTransaction=@UseTransaction, @Print=@Print

RETURN -- Ab hier beginnt das eigentliche Template
BEGIN
DECLARE @TimeStamp datetime
SELECT @TimeStamp=GETDATE()

--MERGE [@1].[@1] T
--USING [@2].[@2] S 
--	on (@5=@5)
--WHEN MATCHED and (@6=@6 or T.DSQLT_SyncRowIsDeleted=1) THEN 
--    UPDATE SET @7=@7, DSQLT_SyncRowModified=@TimeStamp,DSQLT_SyncRowIsDeleted=0
--WHEN NOT MATCHED BY TARGET THEN
--    INSERT ("@3",DSQLT_SyncRowCreated,DSQLT_SyncRowModified,DSQLT_SyncRowIsDeleted)
--    VALUES ("@4",@TimeStamp,@TimeStamp,0)
--WHEN NOT MATCHED BY SOURCE THEN
--    UPDATE SET DSQLT_SyncRowModified=@TimeStamp,DSQLT_SyncRowIsDeleted=1
;

-- Löschungen
-- nicht mehr vorhandene Datensätze markieren
update [@1].[@1] 
set DSQLT_SyncRowModified=@TimeStamp
,	DSQLT_SyncRowIsDeleted = 1
from [@1].[@1] T
left outer join [@2].[@2] S 
	on (@5=@5)
where S.[@8] is null and T.DSQLT_SyncRowIsDeleted=0  

-- Änderungen 
-- entweder relevante Feldänderungen oder gelöschte Sätze wieder da
update [@1].[@1] 
set @7=@7, DSQLT_SyncRowModified=@TimeStamp,DSQLT_SyncRowIsDeleted=0 
from [@1].[@1] T
join [@2].[@2] S 
	on (@5=@5)
where (@6=@6) or T.DSQLT_SyncRowIsDeleted=1

-- Inserts
insert into [@1].[@1]
("@3",DSQLT_SyncRowCreated,DSQLT_SyncRowModified,DSQLT_SyncRowIsDeleted)
select @4 ,@TimeStamp,@TimeStamp,0
from [@1].[@1] T
right outer join [@2].[@2] S 
	on (@5=@5)
where T.[@8] is null

END
GO
PRINT N'[DSQLT].[@TableComparison] wird erstellt....';


GO
CREATE PROCEDURE [DSQLT].[@TableComparison]
	 @SourceSchema sysname = null
	,@SourceTable sysname= null
	,@TargetSchema sysname= null
	,@TargetTable sysname= null
	,@PrimaryKeySchema sysname=null
	,@PrimaryKeyTable sysname=null
	,@ResultSchema sysname= null
	,@ResultTable sysname= null
	,@IgnoreColumnList varchar(max)=''
	,@UseDefaultValues bit=0
	,@Create varchar(max)=null
	,@Print bit = 0
AS
DECLARE	@Source NVARCHAR (MAX)
DECLARE	@Target NVARCHAR (MAX)
DECLARE	@Result NVARCHAR (MAX)
DECLARE @PKTable NVARCHAR (MAX)   -- Tabelle mit Primärkeydefinition
DECLARE	@PrimaryKeyExpression NVARCHAR (MAX)
DECLARE	@PrimaryKeyCompareExpression NVARCHAR (MAX)
DECLARE	@PrimaryKeyField NVARCHAR (MAX)
DECLARE	@Template NVARCHAR (MAX)

SET	@Template =''
SET @Source=DSQLT.QuoteNameSB(@SourceSchema+'.'+@SourceTable)
set @Target = DSQLT.QuoteNameSB(@TargetSchema+'.'+@TargetTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeySchema+'.'+@PrimaryKeyTable)
if @PKTable is null SET @PKTable=@Source
set @Result = DSQLT.QuoteNameSB(@ResultSchema+'.'+@ResultTable)
if @Result is null SET @Result='#T'  -- Kennzeichen für temporäre Tabelle.
set @PrimaryKeyCompareExpression = DSQLT.PrimaryKeyCompareExpression(@PKTable,'S','T')
set @PrimaryKeyExpression = DSQLT.PrimaryKeyConcatExpression(@PKTable,'S')
select top 1 @PrimaryKeyField = [ColumnQ] from DSQLT.Columns(@PKTable)

declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select ColumnQ as [@1]
		,case when @UseDefaultValues=1 then Compare_Columns_With_Null else Compare_Columns end as [@2]
	from DSQLT.ColumnCompare(@Source,@Target,'S','T')
	where in_both_Tables=1 and is_primary_key=0 and [is_Sync_Column]=0
			and charindex(ColumnQ,@IgnoreColumnList) = 0 

exec DSQLT.Iterate 'DSQLT.@TableComparisonSingleField',@Cursor
	,@Result
	,@Source
	,@Target 
	,@PrimaryKeyExpression -- @6
	,@PrimaryKeyCompareExpression -- @7
	,@Template=@Template OUTPUT
	,@Print=null

exec DSQLT.[Execute] 'DSQLT.@TableComparison' 
	,@Source -- @1
	,@Target -- @2
	,@Result -- @3
	,@PrimaryKeyExpression -- (Source) @4
	,@PrimaryKeyCompareExpression -- @5
	,@PrimaryKeyField -- @6
	,@Template -- @7
	,@Create=@Create
	,@Print=@Print

RETURN 
DECLARE @4 as int  -- to avoid Syntax error
DECLARE @5 as int  -- to avoid Syntax error
DECLARE @6 as int  -- to avoid Syntax error
BEGIN
IF '@3'='#T' 
	BEGIN
		SELECT TOP 0 * INTO #T FROM DSQLT.CompareResult
	END
	
-- feststellen, ob es neue Datensätze gibt.
INSERT INTO [@3].[@3]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
 '@1'  -- @Source
,'@2'  -- @Target
,@4 -- @PrimaryKeyExpression"
,'*INSERT*'  -- @ColumnName   leer, da nicht Feldspezifisch
,'EXISTS'
,null  -- Evaluate @ColumnName to TargetValue
FROM [@1].[@1] S  -- @Source
left outer join [@2].[@2] T  -- @Target
	on (@5=@5)  -- @PrimaryKeyCompareExpression
where T.[@6] is null   -- @ColumnCompareExpression]


-- feststellen, ob Datensätze gelöscht wurden.
INSERT INTO [@3].[@3]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
 '@1'  -- @Source
,'@2'  -- @Target
,@4 -- @PrimaryKeyExpression"
,'*DELETE*'  -- @ColumnName   nicht Feldspezifisch
,null  
,'EXISTS'
FROM [@2].[@2] S  -- @Source
left outer join [@1].[@1] T  -- @Target
	on (@5=@5)  -- @PrimaryKeyCompareExpression
where T.[@6] is null   -- @ColumnCompareExpression]

-- hier wird das template für Feldvergleich eingefügt
/*@7*/
-- bis hierher

IF '@3'='#T' 
	BEGIN
	select * from #T
	drop table #T
	END
END
GO
PRINT N'[DSQLT].[@ForEachDatabaseSourceSearch] wird erstellt....';


GO


CREATE PROC [DSQLT].[@ForEachDatabaseSourceSearch]
@Pattern NVARCHAR (MAX),@DatabasePattern sysname ='%', @Print BIT=0
AS
declare @Database sysname
declare @Tempname char(36)
set @Tempname=cast(newid() as char(36))
Set @Database=DB_NAME()
SET @Pattern='%'+@Pattern+'%'

exec DSQLT.[Execute] null,@Tempname,@Template='SELECT TOP 0 * into [@1] from DSQLT.SourceSearch',@Print=@Print

declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select DatabaseQ from dsqlt.databases(@DatabasePattern)
exec DSQLT.iterate '[DSQLT].[@ForEachDatabaseSourceSearch]',@Cursor,@Pattern,@Tempname,@Database,@Print=@Print,@Database='@1'

exec DSQLT.[Execute] null,@Tempname,@Template='SELECT * from [@1]',@Print=@Print

exec DSQLT.[@DropTable] @Database=@Database, @Schema='dbo', @Table=@Tempname,@Print=@Print
RETURN
BEGIN
IF EXISTS (SELECT object_id from sys.sql_modules where definition like '@2')
	insert into [@4].dbo.[@3]
	select 
	@@servername as [Server]
	,DB_NAME() as [Database]
	,s.name as [Schema]
	,o.name as [Program] 
	,o.[type] 
	,o.type_desc 
	,m.definition
	from sys.sql_modules m
	join sys.objects o on m.object_id=o.object_id
	join sys.schemas s on o.schema_id=s.schema_id
	where m.definition like '@2'
END
GO
PRINT N'[DSQLT].[@SourceContains] wird erstellt....';


GO

CREATE PROC [DSQLT].[@SourceContains]
@Database [sysname],@Pattern NVARCHAR (MAX), @Print BIT=0
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
-- Template (unten zwischen BEGIN und END) holen
exec DSQLT.[Execute] '@SourceContains',@Pattern,@Database=@Database,@Print=@Print
-- Template ausführen, Ergebnis über tem. Tabelle holen
RETURN 
BEGIN
select 
S.name+'.'+O.name as SchemaProgram
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaProgramQ
,s.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,o.name as [Program] 
,QUOTENAME(O.name) as [ProgramQ] 
,o.[type] 
,o.type_desc 
,m.definition
from sys.sql_modules m
join sys.objects o on m.object_id=o.object_id
join sys.schemas s on o.schema_id=s.schema_id
where m.definition like '%'+'@1'+'%'
END
GO
PRINT N'[DSQLT].[@addSyncRowStatus] wird erstellt....';


GO

CREATE PROCEDURE [DSQLT].[@addSyncRowStatus]
@p1 NVARCHAR (MAX)=null, @Database [sysname]=null, @Print BIT=0
AS
exec DSQLT.[Execute] 'DSQLT.@addSyncRowStatus' ,@p1,@Database=@Database,@Print=@Print
RETURN 0
BEGIN
alter TABLE [@1].[@1]
add
	[DSQLT_SyncRowStatus] [tinyint] NULL

ALTER TABLE [@1].[@1] ADD  CONSTRAINT [DF_@1_DSQLT_SyncRowStatus]  DEFAULT ((0)) FOR [DSQLT_SyncRowStatus]
END
GO
PRINT N'[Backup] wird erstellt....';


GO
EXECUTE sp_addextendedproperty @name = N'Backup', @value = N'Vollsicherung';


GO
PRINT N'[Testdatenbank] wird erstellt....';


GO
EXECUTE sp_addextendedproperty @name = N'Testdatenbank', @value = N'0';


GO
/*
Vorlage für ein Skript nach der Bereitstellung							
--------------------------------------------------------------------------------------
 Diese Datei enthält SQL-Anweisungen, die an das Buildskript angefügt werden.		
 Schließen Sie mit der SQLCMD-Syntax eine Datei in das Skript nach der Bereitstellung ein.			
 Beispiel:   :r .\myfile.sql								
 Verweisen Sie mit der SQLCMD-Syntax auf eine Variable im Skript nach der Bereitstellung.		
 Beispiel:   :setvar TableName MyTable							
        SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
exec DSQLT._fillTypes
GO

GO
DECLARE @VarDecimalSupported AS BIT;

SELECT @VarDecimalSupported = 0;

IF ((ServerProperty(N'EngineEdition') = 3)
    AND (((@@microsoftversion / power(2, 24) = 9)
          AND (@@microsoftversion & 0xffff >= 3024))
         OR ((@@microsoftversion / power(2, 24) = 10)
             AND (@@microsoftversion & 0xffff >= 1600))))
    SELECT @VarDecimalSupported = 1;

IF (@VarDecimalSupported > 0)
    BEGIN
        EXECUTE sp_db_vardecimal_storage_format N'$(DatabaseName)', 'ON';
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET MULTI_USER 
    WITH ROLLBACK IMMEDIATE;


GO
PRINT N'Update abgeschlossen.';


GO
