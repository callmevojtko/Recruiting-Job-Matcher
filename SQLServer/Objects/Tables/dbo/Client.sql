USE [Role_Finder];
GO

CREATE TABLE dbo.Client (
    ClientId SMALLINT IDENTITY(1,1) NOT NULL,
    DateCreated DATETIME2 CONSTRAINT DF_dbo_Client_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_dbo_Client_DateUpdated DEFAULT (GETDATE()),
    [Name] VARCHAR(500) NOT NULL
    CONSTRAINT PK_dbo_Client PRIMARY KEY (ClientId)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_dbo_Client_Name
ON dbo.Client ([Name]);
GO

CREATE TRIGGER TR_dbo_Client_DateUpdated
ON dbo.Client
AFTER UPDATE
AS
    UPDATE dbo.Client
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN dbo.Client C ON I.ClientId = C.ClientId
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Clients requesting a new hire.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'Client'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Client name.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'Client',   
@level2type = N'Column',@level2name = 'Name' 
GO  