USE [Role_Finder];
GO

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