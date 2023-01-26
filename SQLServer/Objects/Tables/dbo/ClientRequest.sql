USE [Role_Finder];
GO

CREATE TABLE dbo.ClientRequest (
	ClientRequestId INT IDENTITY(1,1) NOT NULL,
	DateCreated DATETIME2 CONSTRAINT DF_dbo_ClientRequest_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_dbo_ClientRequest_DateUpdated DEFAULT (GETDATE()),
	ClientId SMALLINT NOT NULL CONSTRAINT FK_dbo_Client_dbo_ClientRequest FOREIGN KEY REFERENCES dbo.Client (ClientId),
	DateRequested DATE NOT NULL,
	DateClosed DATETIME2 NULL,
	CONSTRAINT PK_dbo_ClientRequest PRIMARY KEY (ClientRequestId)
);

CREATE NONCLUSTERED INDEX IX_dbo_ClientRequest_ClientId_DateClosed_DateRequested
ON dbo.ClientRequest(ClientId, DateClosed, DateRequested DESC);
GO

CREATE TRIGGER TR_dbo_ClientRequest_DateUpdated
ON dbo.ClientRequest
AFTER UPDATE
AS
    UPDATE dbo.ClientRequest
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN dbo.ClientRequest CR ON I.ClientRequestId = CR.ClientRequestId
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Stores requests made by a client.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequest'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Client requesting a new hire.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequest',   
@level2type = N'Column',@level2name = 'ClientId' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Date the client requested a position.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequest',   
@level2type = N'Column',@level2name = 'DateRequested' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Date the client request was closed out.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequest',   
@level2type = N'Column',@level2name = 'DateClosed' 
GO 
