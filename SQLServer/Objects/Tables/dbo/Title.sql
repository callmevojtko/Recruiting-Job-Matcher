USE [Role_Finder];
GO

CREATE TABLE dbo.Title (
    TitleId SMALLINT IDENTITY(1,1) NOT NULL,
    DateCreated DATETIME2 CONSTRAINT DF_dbo_Title_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_dbo_Title_DateUpdated DEFAULT (GETDATE()),
    [Name] VARCHAR(100) NOT NULL
    CONSTRAINT PK_dbo_Title PRIMARY KEY (TitleId)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_dbo_Title_Name 
ON dbo.Title ([Name]);
GO

CREATE TRIGGER TR_dbo_Title_DateUpdated
ON dbo.Title
AFTER UPDATE
AS
    UPDATE dbo.Title
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN dbo.Title T ON I.TitleId = T.TitleId
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Stores job titles that were requested by a client',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'Title'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Job title name.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'Title',   
@level2type = N'Column',@level2name = 'Name' 
GO 