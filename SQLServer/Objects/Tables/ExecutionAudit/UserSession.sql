USE [Role_Finder];
GO

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