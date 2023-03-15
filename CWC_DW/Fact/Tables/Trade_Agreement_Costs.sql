CREATE TABLE [Fact].[Trade_Agreement_Costs] (
    [Trade_Agreement_Cost_Key] INT             IDENTITY (1, 1) NOT NULL,
    [Product_Key]              INT             NOT NULL,
    [Price_Disc_Rec_ID]        BIGINT          NOT NULL,
    [Cost]                     NUMERIC (18, 6) NOT NULL,
    [Start_Date]               DATE            NOT NULL,
    [End_Date]                 DATE            NOT NULL,
    [is_Removed_From_Source]   BIT             NOT NULL,
    [ETL_Created_Date]         DATETIME2 (5)   NOT NULL,
    [ETL_Modified_Date]        DATETIME2 (5)   NOT NULL,
    [ETL_Modified_Count]       INT             NOT NULL,
    PRIMARY KEY CLUSTERED ([Trade_Agreement_Cost_Key] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Product_Key_Start_Date_End_Date]
    ON [Fact].[Trade_Agreement_Costs]([Product_Key] ASC, [Start_Date] ASC, [End_Date] ASC)
    INCLUDE([Cost]);


GO
 CREATE TRIGGER [Fact].[tr_Trade_Agreement_Costs_Audit] ON [Fact].Trade_Agreement_Costs
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
			IF EXISTS (
					SELECT NULL
					FROM inserted i
					INNER JOIN deleted d ON i.Trade_Agreement_Cost_Key = d.Trade_Agreement_Cost_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Trade_Agreement_Cost_Key = d.Trade_Agreement_Cost_Key
						WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
						)
			END
			ELSE
			BEGIN
				SET @Operation = 'U'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted
						)
			END
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Trade_Agreement_Costs]'
		,@Operation
		,@RecordCount
END