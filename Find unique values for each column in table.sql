DECLARE @TABLENAME VARCHAR(255) = 'vUniqueCampaingAttributes_ValidValues'
DECLARE @SQL NVARCHAR(MAX);
DECLARE @I INT = 2;
DROP TABLE ##TEMP;
DROP TABLE ##MAIN_TEMP;
DROP TABLE ##TEMP_DEL;
SET @SQL =
'WITH CTE AS' +
'(' +
'select COLUMN_NAME,ORDINAL_POSITION from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME like ''%'+ @TABLENAME +'%''' +
')' +
'SELECT * INTO ##TEMP FROM CTE;'

--PRINT @SQL;
execute sp_executesql @SQL;
--SET @SQL = 'SELECT * FROM ##TEMP'
--execute sp_executesql @SQL;
SET @SQL = 'Select distinct ID1=identity(int,1,1), ['+ (SELECT COLUMN_NAME FROM ##TEMP WHERE ORDINAL_POSITION = 1) + '] ''['+(SELECT COLUMN_NAME FROM ##TEMP WHERE ORDINAL_POSITION = 1) +']'' INTO ##MAIN_TEMP from vUniqueCampaingAttributes_ValidValues where ['+ (SELECT COLUMN_NAME FROM ##TEMP WHERE ORDINAL_POSITION = 1) + '] is not null';
--PRINT @SQL;
execute sp_executesql @SQL;
WHILE @I < (SELECT MAX(ORDINAL_POSITION) FROM ##TEMP)
BEGIN
--SET @SQL = 'ALTER TABLE ##TEMP2 ADD ['+ (SELECT COLUMN_NAME FROM ##TEMP WHERE ORDINAL_POSITION = @I)+'] VARCHAR(1024);'
--execute sp_executesql @SQL;
SET @SQL = 'Select distinct ID2=identity(int,1,1), ['+ (SELECT COLUMN_NAME FROM ##TEMP WHERE ORDINAL_POSITION = @I) + '] ''['+(SELECT COLUMN_NAME FROM ##TEMP WHERE ORDINAL_POSITION = @I) +']'' into ##TEMP_DEL from vUniqueCampaingAttributes_ValidValues where ['+ (SELECT COLUMN_NAME FROM ##TEMP WHERE ORDINAL_POSITION = @I) + '] is not null'
execute sp_executesql @SQL;
SET @SQL = 'SELECT ISNULL(A.ID1,B.ID2) ID,A.*,B.* INTO ##CURR_TEMP FROM ##MAIN_TEMP A FULL OUTER JOIN ##TEMP_DEL B ON A.ID1 = B.ID2;'
execute sp_executesql @SQL;
SET @SQL = 'ALTER TABLE ##CURR_TEMP DROP COLUMN ID1;'
execute sp_executesql @SQL;
SET @SQL = 'ALTER TABLE ##CURR_TEMP DROP COLUMN ID2;'
execute sp_executesql @SQL;
SET @SQL = 'EXEC tempdb.sys.sp_rename ''##CURR_TEMP.ID'', ''ID1'', ''COLUMN'';'
execute sp_executesql @SQL;
SET @SQL = 'DROP TABLE ##MAIN_TEMP;'
execute sp_executesql @SQL;
SET @SQL = 'SELECT * INTO ##MAIN_TEMP FROM ##CURR_TEMP;'
execute sp_executesql @SQL;
SET @SQL = 'DROP TABLE ##CURR_TEMP;'
execute sp_executesql @SQL;
SET @SQL = 'DROP TABLE ##TEMP_DEL;'
execute sp_executesql @SQL;
--PRINT @SQL;
SET @I = @I + 1;
END



select * from ##MAIN_TEMP;