CREATE TABLE [Dimension].[Catalog_Promotions] (
    [Catalog_Promotion_Key]  INT            IDENTITY (1, 1) NOT NULL,
    [Catalog_Key]            SMALLINT       NULL,
    [Source_CD]              VARCHAR (50)   NULL,
    [Coupon_CD]              VARCHAR (60)   NULL,
    [Catalog_Number]         VARCHAR (10)   NULL,
    [Catalog_Name]           VARCHAR (60)   NULL,
    [Catalog_Description]    VARCHAR (150)  NULL,
    [Catalog_Drop_Date]      DATE           NULL,
    [Promotion_Message]      NVARCHAR (400) NULL,
    [is_Removed_From_Source] BIT            NULL,
    [ETL_Created_Date]       DATETIME2 (5)  NULL,
    [ETL_Modified_Date]      DATETIME2 (5)  NULL,
    [ETL_Modified_Count]     SMALLINT       NULL,
    CONSTRAINT [PK_Catalog_Promotions] PRIMARY KEY CLUSTERED ([Catalog_Promotion_Key] ASC)
);

