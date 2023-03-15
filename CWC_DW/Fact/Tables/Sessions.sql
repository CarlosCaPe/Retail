CREATE TABLE [Fact].[Sessions] (
    [Date_Key]               INT           NOT NULL,
    [Date]                   DATE          NOT NULL,
    [Sessions]               INT           NOT NULL,
    [Transactions]           INT           NOT NULL,
    [Revenue]                MONEY         NOT NULL,
    [is_Removed_From_Source] BIT           NOT NULL,
    [ETL_Created_Date]       DATETIME2 (5) NOT NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NOT NULL,
    [ETL_Modified_Count]     TINYINT       NOT NULL,
    PRIMARY KEY CLUSTERED ([Date_Key] ASC)
);






GO
 CREATE TRIGGER [Fact].[tr_Sessions_Audit] ON [Fact].Sessions
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
					INNER JOIN deleted d ON i.Date_Key = d.Date_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Date_Key = d.Date_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Sessions]'
		,@Operation
		,@RecordCount
END