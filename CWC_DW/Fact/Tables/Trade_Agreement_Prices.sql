CREATE TABLE [Fact].[Trade_Agreement_Prices] (
    [Trade_Agreement_Price_Key] INT             IDENTITY (1, 1) NOT NULL,
    [Product_Key]               INT             NOT NULL,
    [Price_Disc_Rec_ID]         BIGINT          NOT NULL,
    [Price]                     NUMERIC (18, 6) NOT NULL,
    [Start_Date]                DATE            NOT NULL,
    [End_Date]                  DATE            NOT NULL,
    [is_Removed_From_Source]    BIT             NOT NULL,
    [ETL_Created_Date]          DATETIME2 (5)   NOT NULL,
    [ETL_Modified_Date]         DATETIME2 (5)   NOT NULL,
    [ETL_Modified_Count]        INT             NOT NULL,
    PRIMARY KEY CLUSTERED ([Trade_Agreement_Price_Key] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Product_Key]
    ON [Fact].[Trade_Agreement_Prices]([Product_Key] ASC, [is_Removed_From_Source] ASC, [Start_Date] ASC, [End_Date] ASC);

