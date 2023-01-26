USE [Role_Finder];
GO

CREATE TABLE dbo.ClientRequestToSkill (
	ClientRequestToSkillId INT IDENTITY(1,1) NOT NULL,
	DateCreated DATETIME2 CONSTRAINT DF_dbo_ClientRequestToSkill_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_dbo_ClientRequestToSkill_DateUpdated DEFAULT (GETDATE()),
	ClientRequestId INT NOT NULL CONSTRAINT FK_dbo_ClientRequest_dbo_ClientRequestToSkill FOREIGN KEY REFERENCES dbo.ClientRequest (ClientRequestId),
	SkillId SMALLINT NOT NULL CONSTRAINT FK_dbo_Skill_dbo_ClientRequestToSkill FOREIGN KEY REFERENCES dbo.Skill (SkillId),
	Experience TINYINT CONSTRAINT DF_dbo_ClientRequestToSkill_Experience DEFAULT (0),
	CONSTRAINT PK_dbo_ClientRequestToSkill PRIMARY KEY (ClientRequestToSkillId)
);

CREATE UNIQUE NONCLUSTERED INDEX UQ_dbo_ClientRequestToSkill_ClientRequestId_SkillId_Experience
ON dbo.ClientRequestToSkill (ClientRequestId, SkillId, Experience);
GO

CREATE TRIGGER TR_dbo_ClientRequestToSkill_DateUpdated
ON dbo.ClientRequestToSkill
AFTER UPDATE
AS
    UPDATE dbo.ClientRequestToSkill
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN dbo.ClientRequestToSkill CRTS ON I.ClientRequestToSkillId = CRTS.ClientRequestToSkillId
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Skills requested by the client for a particular request.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToSkill'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Client request.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToSkill',   
@level2type = N'Column',@level2name = 'ClientRequestId' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Skills requested by the client.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToSkill',   
@level2type = N'Column',@level2name = 'SkillId' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Years of experience for the requested skill.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToSkill',   
@level2type = N'Column',@level2name = 'Experience' 
GO 