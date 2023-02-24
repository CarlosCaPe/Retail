CREATE TABLE [Fact].[Sessions] (
    [Date_Key]               INT           NOT NULL,
    [Date]                   DATE          NOT NULL,
    [Sessions]               INT           NOT NULL,
    [Transactions]           INT           NOT NULL,
    [Revenue]                MONEY         NOT NULL,
    [is_Removed_From_Source] BIT           NOT NULL,
    [ETL_Created_Date]       DATETIME2 (5) NOT NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NOT NULL,
    [ETL_Modified_Count]     TINYINT       NOT NULL,
    PRIMARY KEY CLUSTERED ([Date_Key] ASC)
);

