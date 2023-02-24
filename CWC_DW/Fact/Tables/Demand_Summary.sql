CREATE TABLE [Fact].[Demand_Summary] (
    [Date_Key]                    INT             NOT NULL,
    [Demand]                      NUMERIC (38, 6) NULL,
    [Units]                       INT             NULL,
    [Orders]                      INT             NULL,
    [Amount_Canceled]             NUMERIC (38, 6) NULL,
    [Units_Canceled]              INT             NULL,
    [Amount_Backorder]            NUMERIC (38, 6) NULL,
    [Units_Backorder]             INT             NULL,
    [Orders_Backorder]            INT             NULL,
    [Backorder_Shipped_Amount]    NUMERIC (38, 6) NULL,
    [Backorder_Shipped_Quantity]  INT             NULL,
    [Backorder_Canceled_Amount]   NUMERIC (38, 6) NULL,
    [Backorder_Canceled_Quantity] INT             NULL,
    [is_Removed_From_Source]      BIT             NULL,
    [ETL_Created_Date]            DATETIME2 (5)   NULL,
    [ETL_Modified_Date]           DATETIME2 (5)   NULL,
    [ETL_Modified_Count]          SMALLINT        NULL,
    CONSTRAINT [PK_Demand_Summary] PRIMARY KEY CLUSTERED ([Date_Key] ASC)
);

