CREATE TABLE [Fact].[Backorder_Relief_Summary] (
    [Product_Key]                   INT             NOT NULL,
    [Fiscal_Week_Year_Index]        INT             NOT NULL,
    [Fiscal_Week_Year]              VARCHAR (20)    NOT NULL,
    [Backorder_Amount]              NUMERIC (18, 6) NULL,
    [Backorder_Quantity]            SMALLINT        NULL,
    [Backorder_Average_Unit_Retail] NUMERIC (18, 6) NULL,
    [Backorder_Relief_Quantity]     SMALLINT        NULL,
    [Bakcorder_Releif_Amount]       NUMERIC (18, 6) NULL,
    [Backorder_Remainder_Quantity]  SMALLINT        NULL,
    [Backorder_Remainder_Amount]    NUMERIC (30, 6) NULL,
    [is_Show_Relief]                BIT             NULL,
    CONSTRAINT [PK_Backorder_Relief_Summary] PRIMARY KEY CLUSTERED ([Product_Key] ASC, [Fiscal_Week_Year_Index] ASC)
);

