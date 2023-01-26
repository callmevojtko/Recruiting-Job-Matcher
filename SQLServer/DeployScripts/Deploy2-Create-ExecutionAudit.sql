/*
CREATE SCHEMA ExecutionAudit
CREATE TABLE ExecutionAudit.UserSession
CREATE TABLE ExecutionAudit.CalledProcedure
CREATE TABLE ExecutionAudit.ActionType
CREATE TABLE ExecutionAudit.ExecutionLog
CREATE PROCEDURE ExecutionAudit.StoExecutionLog

Deploy 2

*/

USE [Role_Finder];
GO

CREATE SCHEMA ExecutionAudit;
GO

--UserSession
CREATE TABLE ExecutionAudit.UserSession (
    UserSessionId INT IDENTITY(1,1) NOT NULL,
    DateCreated DATETIME2 NOT NULL,
    CONSTRAINT PK_ExecutionAudit_UserSession PRIMARY KEY (UserSessionId)
)
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_ExecutionAudit_UserSession_DateCreated
ON ExecutionAudit.UserSession (DateCreated)
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Stores unique session for identifying triggered events.',  
@level0type = N'Schema', @level0name = 'ExecutionAudit',  
@level1type = N'Table', @level1name = 'UserSession'
GO  


--CalledProcedure
CREATE TABLE ExecutionAudit.CalledProcedure (
    CalledProcedureId SMALLINT IDENTITY(1,1) NOT NULL,
    DateCreated DATETIME2 CONSTRAINT DF_ExecutionAudit_CalledProcedure_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_ExecutionAudit_CalledProcedure_DateUpdated DEFAULT (GETDATE()),
    [Name] VARCHAR(255) NOT NULL
    CONSTRAINT PK_ExecutionAudit_CalledProcedure PRIMARY KEY (CalledProcedureId)
)
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_ExecutionAudit_CalledProcedure_Name
ON ExecutionAudit.CalledProcedure ([Name])
GO

CREATE TRIGGER TR_ExecutionAudit_CalledProcedure_DateUpdated
ON ExecutionAudit.CalledProcedure
AFTER UPDATE
AS
    UPDATE ExecutionAudit.CalledProcedure
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN ExecutionAudit.CalledProcedure CP ON I.CalledProcedureId = CP.CalledProcedureId
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Stores the stored procedure names for the triggered event.',  
@level0type = N'Schema', @level0name = 'ExecutionAudit',  
@level1type = N'Table', @level1name = 'CalledProcedure'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Name of the stored procedure.',  
@level0type = N'Schema', @level0name = 'ExecutionAudit',  
@level1type = N'Table', @level1name = 'CalledProcedure',   
@level2type = N'Column',@level2name = 'Name' 
GO  


--ActionType
CREATE TABLE ExecutionAudit.ActionType (
    ActionTypeId TINYINT IDENTITY(1,1) NOT NULL,
    DateCreated DATETIME2 CONSTRAINT DF_ExecutionAudit_ActionType_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_ExecutionAudit_ActionType_DateUpdated DEFAULT (GETDATE()),
    [Name] VARCHAR(100) NOT NULL
    CONSTRAINT PK_ExecutionAudit_ActionType PRIMARY KEY (ActionTypeId)
)
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_ExecutionAudit_ActionType_Name
ON ExecutionAudit.ActionType ([Name])
GO

CREATE TRIGGER TR_ExecutionAudit_ActionType_DateUpdated
ON ExecutionAudit.ActionType
AFTER UPDATE
AS
    UPDATE ExecutionAudit.ActionType
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN ExecutionAudit.ActionType A ON I.ActionTypeId = A.ActionTypeId

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Stores the actions taking place within the stored procedure.',  
@level0type = N'Schema', @level0name = 'ExecutionAudit',  
@level1type = N'Table', @level1name = 'ActionType'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Action name.',  
@level0type = N'Schema', @level0name = 'ExecutionAudit',  
@level1type = N'Table', @level1name = 'ActionType',   
@level2type = N'Column',@level2name = 'Name' 
GO  


--ExecutionLog
CREATE TABLE ExecutionAudit.ExecutionLog (
    ExecutionLogId INT IDENTITY(1,1) NOT NULL,
    DateCreated DATETIME2 CONSTRAINT DF_ExecutionAudit_ExecutionLog_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_ExecutionAudit_ExecutionLog_DateUpdated DEFAULT (GETDATE()),
    CalledProcedureId SMALLINT NOT NULL CONSTRAINT FK_executionAudit_CalledProcedure_executionAudit_ExecutionLog FOREIGN KEY REFERENCES ExecutionAudit.CalledProcedure (CalledProcedureId),
	ActionTypeId TINYINT NOT NULL CONSTRAINT FK_executionAudit_ActionType_executionAudit_ExecutionLog FOREIGN KEY REFERENCES ExecutionAudit.ActionType (ActionTypeId),
	UserSessionId INT NOT NULL CONSTRAINT FK_executionAudit_UserSession_executionAudit_ExecutionLog FOREIGN KEY REFERENCES ExecutionAudit.UserSession (UserSessionId),
	Comment VARCHAR(1000) NULL,
    CONSTRAINT PK_ExecutionAudit_ExecutionLog PRIMARY KEY (ExecutionLogId)
)
GO

CREATE NONCLUSTERED INDEX IX_ExecutionAudit_ExecutionLog_CalledProcedure_ActionType_UserSession
ON ExecutionAudit.ExecutionLog (CalledProcedureId, ActionTypeId, UserSessionId)
GO

CREATE TRIGGER TR_ExecutionAudit_ExecutionLog_DateUpdated
ON ExecutionAudit.ExecutionLog
AFTER UPDATE
AS
    UPDATE ExecutionAudit.ExecutionLog
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN ExecutionAudit.ExecutionLog EL ON I.ExecutionLogId = EL.ExecutionLogId

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Stores the events taking place within the stored procedure.',  
@level0type = N'Schema', @level0name = 'ExecutionAudit',  
@level1type = N'Table', @level1name = 'ExecutionLog'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Stored procedure.',  
@level0type = N'Schema', @level0name = 'ExecutionAudit',  
@level1type = N'Table', @level1name = 'ExecutionLog',   
@level2type = N'Column',@level2name = 'CalledProcedureId' 
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Event action.',  
@level0type = N'Schema', @level0name = 'ExecutionAudit',  
@level1type = N'Table', @level1name = 'ExecutionLog',   
@level2type = N'Column',@level2name = 'ActionTypeId' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Unique session for the triggered event.',  
@level0type = N'Schema', @level0name = 'ExecutionAudit',  
@level1type = N'Table', @level1name = 'ExecutionLog',   
@level2type = N'Column',@level2name = 'UserSessionId' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Additional information about the action.',  
@level0type = N'Schema', @level0name = 'ExecutionAudit',  
@level1type = N'Table', @level1name = 'ExecutionLog',   
@level2type = N'Column',@level2name = 'Comment' 
GO 



CREATE PROCEDURE ExecutionAudit.StoExecutionLog @CalledProcedure VARCHAR(255), 
												@ActionType VARCHAR(100),
												@Comment VARCHAR(1000),
												@UserSessionId INT = NULL OUTPUT
AS

/*******************************************************************************\
Object Name: ExecutionAudit.StoExecutionLog 

Parameters: 
	@CalledProcedure VARCHAR(255)
	@ActionType VARCHAR(100)
	@Comment VARCHAR(1000)
	@UserSessionId INT = NULL

Purpose: 
	Logs an event that was triggered within a procedure.

Example: 
	DECLARE	@CalledProcedure VARCHAR(255) = 'dbo.StoSaveClientRequest', 
			@ActionType VARCHAR(100) = 'Start',
			@Comment VARCHAR(1000) = NULL
			@UserSessionId INT = NULL

	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId

---------------------------------------------------------------------------------
Change History
2023-01-25 - TH - Initial creation

\*******************************************************************************/
SET NOCOUNT ON;

DECLARE @CalledProcedureId SMALLINT,
		@ActionTypeId TINYINT

--CalledProcedure
IF EXISTS (SELECT TOP 1 1 FROM ExecutionAudit.CalledProcedure WHERE [Name] = @CalledProcedure)
BEGIN
	SELECT @CalledProcedureId = CalledProcedureId
	FROM ExecutionAudit.CalledProcedure
	WHERE [Name] = @CalledProcedure 

END
ELSE
BEGIN
	INSERT INTO ExecutionAudit.CalledProcedure ([Name])
	VALUES (@CalledProcedure)

	SELECT @CalledProcedureId = SCOPE_IDENTITY()

END

--ActionType
IF EXISTS (SELECT TOP 1 1 FROM ExecutionAudit.ActionType WHERE [Name] = @ActionType)
BEGIN
	SELECT @ActionTypeId = ActionTypeId
	FROM ExecutionAudit.ActionType
	WHERE [Name] = @ActionType

END
ELSE
BEGIN
	INSERT INTO ExecutionAudit.ActionType ([Name])
	VALUES (@ActionType)

	SELECT @ActionTypeId = SCOPE_IDENTITY()

END

--UserSession
IF @UserSessionId IS NULL
BEGIN
	INSERT INTO ExecutionAudit.UserSession (DateCreated)
	VALUES (GETDATE())

	SELECT @UserSessionId = SCOPE_IDENTITY()

END

--Log events
INSERT INTO ExecutionAudit.ExecutionLog (CalledProcedureId, ActionTypeId, UserSessionId, Comment)
VALUES (@CalledProcedureId, @ActionTypeId, @UserSessionId, @Comment)


GO

GO