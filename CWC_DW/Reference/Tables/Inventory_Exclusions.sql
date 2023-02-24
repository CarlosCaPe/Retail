CREATE TABLE [Reference].[Inventory_Exclusions] (
    [Item_Number]            VARCHAR (50)  NOT NULL,
    [Color_ID]               VARCHAR (50)  NOT NULL,
    [Size_ID]                VARCHAR (50)  NOT NULL,
    [is_Removed_From_Source] BIT           NULL,
    [is_Excluded]            BIT           NULL,
    [ETL_Created_Date]       DATETIME2 (5) NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NULL,
    [ETL_Modified_Count]     SMALLINT      NOT NULL,
    CONSTRAINT [UK_SKU] UNIQUE NONCLUSTERED ([Item_Number] ASC, [Color_ID] ASC, [Size_ID] ASC)
);

