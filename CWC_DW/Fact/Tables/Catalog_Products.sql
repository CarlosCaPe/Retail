CREATE TABLE [Fact].[Catalog_Products] (
    [Catalog_Product_Key]    INT           IDENTITY (1, 1) NOT NULL,
    [Catalog_Key]            SMALLINT      NOT NULL,
    [Product_Key]            INT           NOT NULL,
    [is_Removed_From_Source] BIT           NULL,
    [is_Excluded]            BIT           NULL,
    [ETL_Created_Date]       DATETIME2 (5) NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NULL,
    [ETL_Modified_Count]     SMALLINT      NULL,
    CONSTRAINT [PK_Catalog_Products] PRIMARY KEY CLUSTERED ([Catalog_Product_Key] ASC)
);

