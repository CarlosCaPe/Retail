CREATE TABLE [Dimension].[Catalogs] (
    [Catalog_Key]            SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Catalog_Number]         VARCHAR (10)  NOT NULL,
    [Catalog_Name]           VARCHAR (60)  NOT NULL,
    [Catalog_Description]    VARCHAR (128) NULL,
    [Catalog_Drop_Date]      DATE          NULL,
    [is_Removed_From_Source] BIT           NULL,
    [is_Excluded]            BIT           NULL,
    [ETL_Created_Date]       DATETIME2 (5) NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NULL,
    [ETL_Modified_Count]     TINYINT       NULL,
    PRIMARY KEY CLUSTERED ([Catalog_Key] ASC),
    CONSTRAINT [UK_Catalog_Number] UNIQUE NONCLUSTERED ([Catalog_Number] ASC)
);

