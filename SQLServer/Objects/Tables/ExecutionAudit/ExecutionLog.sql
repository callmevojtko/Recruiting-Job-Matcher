USE [Role_Finder];
GO

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