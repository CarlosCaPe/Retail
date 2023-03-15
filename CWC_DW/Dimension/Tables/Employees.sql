CREATE TABLE [Dimension].[Employees] (
    [Employee_Key]           SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Personnel_Number]       NVARCHAR (25)  NOT NULL,
    [User_ID]                NVARCHAR (20)  NULL,
    [Employee_Full_Name]     NVARCHAR (100) NOT NULL,
    [License_Source]         VARCHAR (15)   NULL,
    [Start_Date]             DATE           NOT NULL,
    [End_Date]               DATE           NULL,
    [Summary_Valid_From]     DATETIME2 (5)  NULL,
    [is_Active]              BIT            NOT NULL,
    [is_Removed_From_Source] BIT            NOT NULL,
    [is_Excluded]            BIT            NOT NULL,
    [ETL_Created_Date]       DATETIME2 (5)  NOT NULL,
    [ETL_Modified_Date]      DATETIME2 (5)  NOT NULL,
    [ETL_Modified_Count]     TINYINT        NOT NULL,
    CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED ([Employee_Key] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Employees_Audit] ON [Dimension].[Employees]
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
					INNER JOIN deleted d ON i.Employee_Key = d.Employee_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Employee_Key = d.Employee_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Employees]'
		,@Operation
		,@RecordCount
END