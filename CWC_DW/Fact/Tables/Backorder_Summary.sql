CREATE TABLE [Fact].[Backorder_Summary] (
    [Backorder Date]             DATE            NOT NULL,
    [Backorder Amount]           NUMERIC (38, 6) NULL,
    [Backorder Units]            INT             NULL,
    [Backorder New Quantity]     INT             NULL,
    [Backorder New Amount]       NUMERIC (38, 6) NULL,
    [Backorder Shipped Amount]   NUMERIC (38, 6) NULL,
    [Backorder Shipped Quantity] INT             NULL,
    [Backorder Cancel Amount]    NUMERIC (38, 6) NULL,
    [Backorder Cancel Units]     INT             NULL
);

