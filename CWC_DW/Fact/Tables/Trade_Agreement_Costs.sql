﻿CREATE TABLE [Fact].[Trade_Agreement_Costs] (
    [Trade_Agreement_Cost_Key] INT             IDENTITY (1, 1) NOT NULL,
    [Product_Key]              INT             NOT NULL,
    [Price_Disc_Rec_ID]        BIGINT          NOT NULL,
    [Cost]                     NUMERIC (18, 6) NOT NULL,
    [Start_Date]               DATE            NOT NULL,
    [End_Date]                 DATE            NOT NULL,
    [is_Removed_From_Source]   BIT             NOT NULL,
    [ETL_Created_Date]         DATETIME2 (5)   NOT NULL,
    [ETL_Modified_Date]        DATETIME2 (5)   NOT NULL,
    [ETL_Modified_Count]       INT             NOT NULL,
    PRIMARY KEY CLUSTERED ([Trade_Agreement_Cost_Key] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Product_Key_Start_Date_End_Date]
    ON [Fact].[Trade_Agreement_Costs]([Product_Key] ASC, [Start_Date] ASC, [End_Date] ASC)
    INCLUDE([Cost]);
