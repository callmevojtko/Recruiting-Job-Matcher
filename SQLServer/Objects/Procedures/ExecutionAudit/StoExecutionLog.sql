USE [Role_Finder];
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