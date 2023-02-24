﻿CREATE TABLE [Dimension].[Dates] (
    [Date_Key]                    INT           NOT NULL,
    [Calendar_Date]               DATE          NOT NULL,
    [Calendar_Month]              TINYINT       NOT NULL,
    [Calendar_Day]                TINYINT       NOT NULL,
    [Calendar_Year]               SMALLINT      NOT NULL,
    [Calendar_Quarter]            TINYINT       NOT NULL,
    [Calendar_Quarter_Name]       CHAR (2)      NULL,
    [Calendar_Quarter_Year_Name]  CHAR (8)      NULL,
    [Day_Name]                    VARCHAR (9)   NOT NULL,
    [Day_of_Week]                 TINYINT       NOT NULL,
    [Day_of_Week_in_Month]        TINYINT       NOT NULL,
    [Day_of_Week_in_Year]         TINYINT       NOT NULL,
    [Day_of_Week_in_Quarter]      TINYINT       NOT NULL,
    [Day_of_Quarter]              TINYINT       NOT NULL,
    [Day_of_Year]                 SMALLINT      NOT NULL,
    [Week_of_Month]               TINYINT       NOT NULL,
    [Week_of_Quarter]             TINYINT       NOT NULL,
    [Week_of_Year]                TINYINT       NOT NULL,
    [Month_Name]                  VARCHAR (9)   NOT NULL,
    [First_Date_of_Week]          DATE          NOT NULL,
    [Last_Date_of_Week]           DATE          NOT NULL,
    [First_Date_of_Month]         DATE          NOT NULL,
    [Last_Date_of_Month]          DATE          NOT NULL,
    [First_Date_of_Quarter]       DATE          NOT NULL,
    [Last_Date_of_Quarter]        DATE          NOT NULL,
    [First_Date_of_Year]          DATE          NOT NULL,
    [Last_Date_of_Year]           DATE          NOT NULL,
    [is_Holiday]                  BIT           NOT NULL,
    [is_Holiday_Season]           BIT           NOT NULL,
    [Holiday_Name]                VARCHAR (50)  NULL,
    [Holiday_Season_Name]         VARCHAR (50)  NULL,
    [is_Weekday]                  BIT           NOT NULL,
    [is_Business_Day]             BIT           NOT NULL,
    [Previous_Business_Day]       DATE          NULL,
    [Next_Business_Day]           DATE          NULL,
    [is_Leap_Year]                BIT           NOT NULL,
    [Days_in_Month]               TINYINT       NOT NULL,
    [Fiscal_Day_of_Year]          SMALLINT      NULL,
    [Fiscal_Week_of_Year]         TINYINT       NULL,
    [Fiscal_Month]                TINYINT       NULL,
    [Fiscal_Quarter]              SMALLINT      NULL,
    [Fiscal_Quarter_Name]         CHAR (2)      NULL,
    [Fiscal_Quarter_Year_Name]    VARCHAR (22)  NULL,
    [Fiscal_Year]                 SMALLINT      NULL,
    [Fiscal_Year_Name]            CHAR (7)      NULL,
    [Fiscal_Month_Year]           CHAR (10)     NULL,
    [Fiscal_MMYYYY]               CHAR (6)      NULL,
    [Fiscal_Date_Last_Year]       DATE          NULL,
    [Fiscal_First_Day_of_Month]   DATE          NULL,
    [Fiscal_Last_Day_of_Month]    DATE          NULL,
    [Fiscal_First_Day_of_Quarter] DATE          NULL,
    [Fiscal_Last_Day_of_Quarter]  DATE          NULL,
    [Fiscal_First_Day_of_Year]    DATE          NULL,
    [Fiscal_Last_Day_of_Year]     DATE          NULL,
    [Fiscal_Month_Name]           AS            (datename(month,dateadd(month,CONVERT([tinyint],[Fiscal_Month]),(-1)))),
    [Fiscal_Week_of_Year_Name]    AS            (CONVERT([varchar](5),'Wk '+CONVERT([varchar](4),[Fiscal_Week_of_Year]))),
    [is_Current_Inventory_Date]   BIT           NULL,
    [is_Current_Backorder_Date]   BIT           NULL,
    [is_Removed_From_Source]      BIT           NULL,
    [is_Excluded]                 BIT           NULL,
    [ETL_Created_Date]            DATETIME2 (5) NULL,
    [ETL_Modified_Date]           DATETIME2 (5) NULL,
    [ETL_Modified_Count]          TINYINT       NULL,
    CONSTRAINT [PK_Dates] PRIMARY KEY CLUSTERED ([Date_Key] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Calendar_Date]
    ON [Dimension].[Dates]([Calendar_Date] ASC)
    INCLUDE([Date_Key]);
