CREATE TABLE [Fact].[Forecast] (
    [Forecast_Date_Key]      INT           NOT NULL,
    [Forecast_Date]          DATE          NULL,
    [Print_Cycle]            VARCHAR (25)  NULL,
    [Pct_Week]               FLOAT (53)    NULL,
    [Demand]                 INT           NULL,
    [Orders]                 INT           NULL,
    [Units]                  INT           NULL,
    [is_Removed_From_Source] BIT           NULL,
    [is_Excluded]            BIT           NULL,
    [ETL_Created_Date]       DATETIME2 (5) NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NULL,
    [ETL_Modified_Count]     TINYINT       NULL,
    CONSTRAINT [PK_Forecast] PRIMARY KEY CLUSTERED ([Forecast_Date_Key] ASC)
);

