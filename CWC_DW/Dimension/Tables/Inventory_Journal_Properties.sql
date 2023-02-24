CREATE TABLE [Dimension].[Inventory_Journal_Properties] (
    [Inventory_Journal_Property_Key] TINYINT       IDENTITY (1, 1) NOT NULL,
    [Counting_Reason_CD]             VARCHAR (50)  NOT NULL,
    [Inventory_Status_CD]            VARCHAR (50)  NULL,
    [Counting_Reason]                VARCHAR (50)  NOT NULL,
    [Inventory_Status]               VARCHAR (50)  NULL,
    [is_Removed_From_Source]         BIT           NOT NULL,
    [ETL_Created_Date]               DATETIME2 (5) NOT NULL,
    [ETL_Modified_Date]              DATETIME2 (5) NOT NULL,
    [ETL_Modified_Count]             TINYINT       NOT NULL,
    CONSTRAINT [PK_Inventory_Journal_Properties] PRIMARY KEY CLUSTERED ([Inventory_Journal_Property_Key] ASC)
);

