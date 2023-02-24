CREATE TABLE [Dimension].[Sales_Margin] (
    [Sales_Margin_Key]       TINYINT      IDENTITY (1, 1) NOT NULL,
    [Sales_Margin_Threshold] VARCHAR (25) NOT NULL,
    [Sales_Margin_Index]     TINYINT      NOT NULL,
    [Start_Range]            SMALLINT     NULL,
    [Stop_Range]             SMALLINT     NULL,
    PRIMARY KEY CLUSTERED ([Sales_Margin_Key] ASC)
);

