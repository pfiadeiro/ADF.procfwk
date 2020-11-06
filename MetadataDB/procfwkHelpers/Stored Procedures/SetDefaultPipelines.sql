CREATE PROCEDURE [procfwkHelpers].[SetDefaultPipelines]
AS
BEGIN
	DECLARE @Pipelines TABLE
		(
		[DataFactoryId] [INT] NOT NULL,
		[StageId] [INT] NOT NULL,
		[PipelineName] [NVARCHAR](200) NOT NULL,
		[LogicalPredecessorId] [INT] NULL,
		[Enabled] [BIT] NOT NULL,
		[ScheduleMonthOfYear] [NVARCHAR] (50) NOT NULL,
		[ScheduleDayOfWeek] [NVARCHAR] (30) NOT NULL,
		[ScheduleDayOfMonth] [NVARCHAR] (100) NOT NULL
		)

	INSERT @Pipelines
		(
		[DataFactoryId],
		[StageId],
		[PipelineName], 
		[LogicalPredecessorId],
		[Enabled],
		[ScheduleMonthOfYear],
		[ScheduleDayOfWeek],
		[ScheduleDayOfMonth]
		) 
	VALUES 
		(1,1	,'Wait 1'				,NULL		,1,		'*',						'*',			'*'),
		(1,1	,'Wait 2'				,NULL		,1,		'Jan,Mar,May,Jul,Sep,Nov',	'Tue',			'*'),
		(1,1	,'Intentional Error'	,NULL		,1,		'Nov,Dec',					'*',			'*'),
		(1,1	,'Wait 3'				,NULL		,1,		'Feb',						'*',			'*'),
		(1,2	,'Wait 4'				,NULL		,1,		'Mar',						'*',			'*'),
		(1,2	,'Wait 5'				,1			,1,		'Nov,Dec',					'Mon,Wed,Fri',	'1,5,10'),
		(1,2	,'Wait 6'				,1			,1,		'Nov,Dec',					'Tue,Thu',		'*'),
		(1,2	,'Wait 7'				,NULL		,1,		'Nov,Dec',					'*',			'1,2,3,4,5'),
		(1,3	,'Wait 8'				,1			,1,		'Nov,Dec',					'*',			'*'),
		(1,3	,'Wait 9'				,6			,1,		'Nov,Dec',					'Mon',			'1,2,3'),
		(1,4	,'Wait 10'				,9			,1,		'*',						'*',			'6,7,8,9,10');

	MERGE INTO [procfwk].[Pipelines] AS tgt
	USING 
		@Pipelines AS src
			ON tgt.[PipelineName] = src.[PipelineName]
	WHEN MATCHED THEN
		UPDATE
		SET
			tgt.[DataFactoryId] = src.[DataFactoryId],
			tgt.[StageId] = src.[StageId],
			tgt.[LogicalPredecessorId] = src.[LogicalPredecessorId],
			tgt.[Enabled] = src.[Enabled],
			tgt.[ScheduleMonthOfYear] = src.[ScheduleMonthOfYear],
			tgt.[ScheduleDayOfWeek] = src.[ScheduleDayOfWeek],
			tgt.[ScheduleDayOfMonth] = src.[ScheduleDayOfMonth]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT
			(
			[DataFactoryId],
			[StageId],
			[PipelineName], 
			[LogicalPredecessorId],
			[Enabled],
			[ScheduleMonthOfYear],
			[ScheduleDayOfWeek],
			[ScheduleDayOfMonth]
			)
		VALUES
			(
			src.[DataFactoryId],
			src.[StageId],
			src.[PipelineName], 
			src.[LogicalPredecessorId],
			src.[Enabled],
			src.[ScheduleMonthOfYear],
			src.[ScheduleDayOfWeek],
			src.[ScheduleDayOfMonth]
			)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;	
END;