CREATE TABLE [dbo].[Projects]
(
    [Id]          UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_Projects_Id] DEFAULT (NEWID()),
    [OrgId]       UNIQUEIDENTIFIER NOT NULL,
    [Name]        NVARCHAR(120)    NOT NULL,
    [Description] NVARCHAR(2000)   NOT NULL CONSTRAINT [DF_Projects_Description] DEFAULT (''),
    [Status]      VARCHAR(16)      NOT NULL CONSTRAINT [DF_Projects_Status] DEFAULT ('active'),
    [CreatedAt]   DATETIME2(3)     NOT NULL CONSTRAINT [DF_Projects_CreatedAt] DEFAULT (SYSUTCDATETIME()),
    [UpdatedAt]   DATETIME2(3)     NOT NULL CONSTRAINT [DF_Projects_UpdatedAt] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_Projects] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Projects_Organizations] FOREIGN KEY ([OrgId]) REFERENCES [dbo].[Organizations] ([Id]),
    CONSTRAINT [CK_Projects_Status] CHECK ([Status] IN ('active', 'archived'))
);
GO

-- Tenant-scoped lookups always filter by OrgId first.
CREATE INDEX [IX_Projects_OrgId] ON [dbo].[Projects] ([OrgId] ASC) INCLUDE ([Name], [Status]);
