CREATE TABLE [Dimension].[Sales_Order_Fill] (
    [Sales_Order_Fill_Key]   TINYINT      IDENTITY (1, 1) NOT NULL,
    [Fill_CD]                TINYINT      NOT NULL,
    [Sales_Order_Fill]       VARCHAR (50) NOT NULL,
    [Fill_Days]              VARCHAR (50) NOT NULL,
    [Fill_Days_Index]        TINYINT      NULL,
    [Sales_Order_Days]       VARCHAR (50) NULL,
    [Sales_Order_Days_Index] TINYINT      NULL,
    [1_Day_Fill]             VARCHAR (50) NOT NULL,
    [7_Day_Fill]             VARCHAR (50) NOT NULL,
    [30_Day_Fill]            VARCHAR (50) NOT NULL,
    [60_Day_Fill]            VARCHAR (50) NOT NULL,
    [90_Day_Fill]            VARCHAR (50) NOT NULL,
    [120_Day_Fill]           VARCHAR (50) NOT NULL,
    [Over_120_Day_Fill]      VARCHAR (50) NOT NULL,
    [Range_Start]            SMALLINT     NOT NULL,
    [Range_Stop]             SMALLINT     NULL,
    CONSTRAINT [PK__Sales_Or__00E3FB8F287C2450] PRIMARY KEY CLUSTERED ([Sales_Order_Fill_Key] ASC)
);

