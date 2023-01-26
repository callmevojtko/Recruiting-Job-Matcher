USE [Role_Finder];
GO

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