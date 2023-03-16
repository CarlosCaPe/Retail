CREATE TABLE [Administration].[Procedure_Tables] (
    [Procedure_Table_Key] INT           IDENTITY (1, 1) NOT NULL,
    [Procedure_Name]      VARCHAR (100) NULL,
    [Table_Name]          VARCHAR (100) NULL,
    CONSTRAINT [PK_Procedure_Tables] PRIMARY KEY CLUSTERED ([Procedure_Table_Key] ASC)
);

