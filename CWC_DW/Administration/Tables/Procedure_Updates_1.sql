CREATE TABLE [Administration].[Procedure_Updates] (
    [Procedure_Update_Key] INT            IDENTITY (1, 1) NOT NULL,
    [Procedure_Name]       VARCHAR (50)   NOT NULL,
    [Start_Date]           DATETIME       CONSTRAINT [DF_etl.ProcedureUpdates_StartDate] DEFAULT (getdate()) NOT NULL,
    [End_Date]             DATETIME       NULL,
    [Status]               VARCHAR (20)   NOT NULL,
    [Affected_Rows]        BIGINT         CONSTRAINT [DF_ProcedureUpdates_AffectedRows] DEFAULT ((0)) NOT NULL,
    [Error]                VARCHAR (8000) CONSTRAINT [DF_etl.ProcedureUpdates_Error] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_ProcedureUpdates] PRIMARY KEY CLUSTERED ([Procedure_Update_Key] ASC)
);

