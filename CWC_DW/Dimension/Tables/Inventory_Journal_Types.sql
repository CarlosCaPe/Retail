CREATE TABLE [Dimension].[Inventory_Journal_Types] (
    [Inventory_Journal_Type_Key] TINYINT       IDENTITY (1, 1) NOT NULL,
    [Inventory_Journal_Type_CD]  VARCHAR (5)   NULL,
    [Inventory_Journal]          VARCHAR (25)  NULL,
    [is_Removed_From_Source]     BIT           NULL,
    [ETL_Created_Date]           DATETIME2 (5) NULL,
    [ETL_Modified_Date]          DATETIME2 (5) NULL,
    [ETL_Modified_Count]         TINYINT       NULL,
    CONSTRAINT [PK_Inventory_Journal_Types] PRIMARY KEY CLUSTERED ([Inventory_Journal_Type_Key] ASC)
);

