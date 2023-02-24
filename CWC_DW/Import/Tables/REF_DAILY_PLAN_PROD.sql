CREATE TABLE [Import].[REF_DAILY_PLAN_PROD] (
    [Insert_Date] DATETIME      NULL,
    [Row_Id]      INT           NULL,
    [FISCALYEAR]  INT           NULL,
    [FISCALMONTH] VARCHAR (3)   NULL,
    [WEEKNUMBER]  INT           NULL,
    [DOW]         VARCHAR (15)  NULL,
    [FDATE]       NVARCHAR (10) NULL,
    [Print_Cycle] VARCHAR (25)  NULL,
    [Pct_Week]    FLOAT (53)    NULL,
    [Demand]      BIGINT        NULL,
    [Orders]      BIGINT        NULL,
    [Units]       BIGINT        NULL
);

