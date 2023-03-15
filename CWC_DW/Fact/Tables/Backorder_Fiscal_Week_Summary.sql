CREATE TABLE [Fact].[Backorder_Fiscal_Week_Summary] (
    [Fiscal_Week_Index]          INT              NOT NULL,
    [Fiscal_Week]                VARCHAR (25)     NOT NULL,
    [Fiscal_Week_Short]          VARCHAR (8)      NULL,
    [Week_Beginning]             DATE             NULL,
    [Demand_Amount]              NUMERIC (38, 6)  NULL,
    [Orders]                     INT              NULL,
    [Beginning_Backorder_Amount] NUMERIC (18, 6)  NULL,
    [New_Backorder_Amount]       NUMERIC (18, 6)  NULL,
    [New_Backorder_Rate]         NUMERIC (18, 6)  NULL,
    [Backorder_Shipped_Amount]   NUMERIC (18, 6)  NULL,
    [Shipped_Backorder_Rate]     NUMERIC (18, 6)  NULL,
    [Backorder_Misc]             NUMERIC (18, 6)  NULL,
    [Ending_Backorder_Amount]    NUMERIC (18, 6)  NULL,
    [Demand_12_Week_Amount]      NUMERIC (18, 6)  NULL,
    [Backorder_Rate]             NUMERIC (18, 6)  NULL,
    [Backorder_Diff]             NUMERIC (18, 6)  NULL,
    [Demand_Shipped_Amount]      NUMERIC (18, 6)  NULL,
    [Demand_Shipped_Units]       INT              NULL,
    [Units]                      INT              NULL,
    [Backorder_Orders]           INT              NULL,
    [Beginning_Backorder_Units]  INT              NULL,
    [New_Backorder_Units]        INT              NULL,
    [Backorder_Shipped_Units]    INT              NULL,
    [Ending_Backorder_Units]     INT              NULL,
    [Unit_Fill_Rate]             NUMERIC (35, 19) NULL,
    [Order_Fill_Rate]            NUMERIC (35, 19) NULL,
    [Receipt_Backorder]          INT              NULL,
    [Receipt_Other]              INT              NULL,
    [Backorder_Canceled]         NUMERIC (18, 6)  NULL
);






GO
 CREATE TRIGGER [Fact].[tr_Backorder_Fiscal_Week_Summary_Audit] ON [Fact].[Backorder_Fiscal_Week_Summary]
AFTER INSERT
	,UPDATE
	,DELETE
AS
BEGIN
	DECLARE @Operation CHAR(1)
	DECLARE @RecordCount INT

	IF EXISTS (
			SELECT NULL
			FROM inserted
			)
	BEGIN
		IF EXISTS (
				SELECT NULL
				FROM deleted
				)
		BEGIN
			SET @Operation = 'U'	
			SET @RecordCount = (	
					SELECT COUNT(*)	
					FROM inserted	
					)	

			
		END
		ELSE
		BEGIN
			SET @Operation = 'I'
			SET @RecordCount = @@ROWCOUNT
		END
	END
	ELSE
	BEGIN
		SET @Operation = 'D'
		SET @RecordCount = @@ROWCOUNT
	END

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Backorder_Fiscal_Week_Summary]'
		,@Operation
		,@RecordCount
END