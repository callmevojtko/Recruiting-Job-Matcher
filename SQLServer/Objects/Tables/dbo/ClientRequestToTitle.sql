USE [Role_Finder];
GO

CREATE TABLE dbo.ClientRequestToTitle (
	ClientRequestToTitleId INT IDENTITY(1,1) NOT NULL,
	DateCreated DATETIME2 CONSTRAINT DF_dbo_ClientRequestToTitle_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_dbo_ClientRequestToTitle_DateUpdated DEFAULT (GETDATE()),
	ClientRequestId INT NOT NULL CONSTRAINT FK_dbo_ClientRequest_dbo_ClientRequestToTitle FOREIGN KEY REFERENCES dbo.ClientRequest (ClientRequestId),
	TitleId SMALLINT NOT NULL CONSTRAINT FK_dbo_Title_dbo_ClientRequestToTitle FOREIGN KEY REFERENCES dbo.Title (TitleId),
	Experience TINYINT CONSTRAINT DF_dbo_ClientRequestToTitle_Experience DEFAULT (0),
	CONSTRAINT PK_dbo_ClientRequestToTitle PRIMARY KEY (ClientRequestToTitleId)
);

CREATE UNIQUE NONCLUSTERED INDEX UQ_dbo_ClientRequestToTitle_ClientRequestId_TitleId
ON dbo.ClientRequestToTitle (ClientRequestId, TitleId);
GO

CREATE TRIGGER TR_dbo_ClientRequestToTitle_DateUpdated
ON dbo.ClientRequestToTitle
AFTER UPDATE
AS
    UPDATE dbo.ClientRequestToTitle
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN dbo.ClientRequestToTitle CRTT ON I.ClientRequestToTitleId = CRTT.ClientRequestToTitleId
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Title requested by the client for a particular request.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToTitle'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Client request.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToTitle',   
@level2type = N'Column',@level2name = 'ClientRequestId' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Job Title requested by the client.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToTitle',   
@level2type = N'Column',@level2name = 'TitleId' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Years of experience for the requested job title.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToTitle',   
@level2type = N'Column',@level2name = 'Experience' 
GO 