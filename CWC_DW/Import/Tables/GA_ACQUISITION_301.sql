CREATE TABLE [Import].[GA_ACQUISITION_301] (
    [Insert_Date]     DATETIME      NULL,
    [Row_Id]          INT           NULL,
    [Date]            NVARCHAR (10) NULL,
    [Channel]         VARCHAR (50)  NULL,
    [Source]          VARCHAR (50)  NULL,
    [Medium]          VARCHAR (50)  NULL,
    [Campaign]        VARCHAR (250) NULL,
    [Content]         VARCHAR (250) NULL,
    [Device]          VARCHAR (50)  NULL,
    [Sessions]        BIGINT        NULL,
    [NewUsers]        BIGINT        NULL,
    [PercNewSessions] REAL          NULL,
    [Bounces]         BIGINT        NULL,
    [Duration]        FLOAT (53)    NULL,
    [Pages]           FLOAT (53)    NULL,
    [Transactions]    BIGINT        NULL,
    [Revenue]         MONEY         NULL,
    [Custom_Channel]  VARCHAR (50)  NULL
);

