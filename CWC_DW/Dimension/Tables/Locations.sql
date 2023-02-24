CREATE TABLE [Dimension].[Locations] (
    [Location_Key]           INT           IDENTITY (1, 1) NOT NULL,
    [Street]                 VARCHAR (200) NULL,
    [City]                   VARCHAR (100) NULL,
    [State]                  VARCHAR (5)   NULL,
    [Zip_Code]               VARCHAR (15)  NULL,
    [Country]                VARCHAR (10)  NULL,
    [is_Removed_From_Source] BIT           NULL,
    [is_Excluded]            BIT           NULL,
    [ETL_Created_Date]       DATETIME2 (5) NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NULL,
    [ETL_Modified_Count]     TINYINT       NULL,
    CONSTRAINT [PK_Locations] PRIMARY KEY CLUSTERED ([Location_Key] ASC),
    CONSTRAINT [UK_Locations] UNIQUE NONCLUSTERED ([Street] ASC, [City] ASC, [State] ASC, [Zip_Code] ASC, [Country] ASC)
);

