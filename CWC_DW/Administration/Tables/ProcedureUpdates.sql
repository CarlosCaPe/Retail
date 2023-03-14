CREATE TABLE [Administration].[ProcedureUpdates] (
    [ProcedureUpdateKey] INT            IDENTITY (1, 1) NOT NULL,
    [ProcedureName]      VARCHAR (50)   NOT NULL,
    [StartDate]          SMALLDATETIME  CONSTRAINT [DF_etl.ProcedureUpdates_StartDate] DEFAULT (getdate()) NOT NULL,
    [EndDate]            SMALLDATETIME  NULL,
    [Status]             VARCHAR (20)   NOT NULL,
    [AffectedRows]       BIGINT         CONSTRAINT [DF_ProcedureUpdates_AffectedRows] DEFAULT ((0)) NOT NULL,
    [Error]              VARCHAR (8000) CONSTRAINT [DF_etl.ProcedureUpdates_Error] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_ProcedureUpdates] PRIMARY KEY CLUSTERED ([ProcedureUpdateKey] ASC)
);

