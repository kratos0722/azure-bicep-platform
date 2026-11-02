CREATE TABLE [dbo].[Users]
(
    [Id]           UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_Users_Id] DEFAULT (NEWID()),
    [OrgId]        UNIQUEIDENTIFIER NOT NULL,
    [Email]        NVARCHAR(256)    NOT NULL,
    [PasswordHash] NVARCHAR(200)    NOT NULL,
    [Role]         VARCHAR(16)      NOT NULL CONSTRAINT [DF_Users_Role] DEFAULT ('member'),
    [CreatedAt]    DATETIME2(3)     NOT NULL CONSTRAINT [DF_Users_CreatedAt] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Users_Organizations] FOREIGN KEY ([OrgId]) REFERENCES [dbo].[Organizations] ([Id]),
    CONSTRAINT [CK_Users_Role] CHECK ([Role] IN ('owner', 'member'))
);
GO

CREATE UNIQUE INDEX [UX_Users_Email] ON [dbo].[Users] ([Email] ASC);
GO

CREATE INDEX [IX_Users_OrgId] ON [dbo].[Users] ([OrgId] ASC);
