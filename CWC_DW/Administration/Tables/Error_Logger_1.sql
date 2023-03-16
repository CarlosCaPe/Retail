CREATE TABLE [Administration].[Error_Logger] (
    [ErrorLogID]      INT            IDENTITY (1, 1) NOT NULL,
    [StoredProcedure] VARCHAR (100)  NOT NULL,
    [InputParameters] NVARCHAR (MAX) NOT NULL,
    [ErrorSeverity]   INT            NOT NULL,
    [ErrorState]      INT            NOT NULL,
    [ErrorLine]       INT            NOT NULL,
    [ErrorNumber]     INT            NOT NULL,
    [ErrorMessage]    VARCHAR (245)  NOT NULL,
    [ErrorDateTime]   DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([ErrorLogID] ASC)
);

