DECLARE
  /*
   * 根据字段值搜索所在用户表字段
   * 用户为空表示搜索所有用户，多用户用逗号分隔
  */
  IN_USER  VARCHAR2(30)  := '';   --搜索的用户
  IN_FIND  VARCHAR2(100) := '请'; --搜索的字段值
  V_USER  VARCHAR2(30);
  V_SQL   VARCHAR2(2000);
  V_COUNT NUMBER;
  V_SQL_2 VARCHAR2(2000);
  TYPE i_cursor_type IS REF CURSOR;
  v_cursor i_cursor_type;
BEGIN
  V_SQL_2 := 'SELECT USERNAME FROM ALL_USERS';
  IF LENGTH(IN_USER) > 0 THEN
    V_SQL_2 := V_SQL_2 || ' WHERE USERNAME IN (''' || Upper(REPLACE(IN_USER, ',', ''',''')) || ''')';
  END IF;
  --DBMS_OUTPUT.PUT_LINE(V_SQL_2);
  OPEN v_cursor FOR V_SQL_2;
  LOOP 
    FETCH v_cursor INTO V_USER;
    EXIT WHEN v_cursor%NOTFOUND;
    --DBMS_OUTPUT.PUT_LINE(V_USER);
    
    FOR V_TABLE IN (SELECT TABLE_NAME, COLUMN_NAME
                 FROM ALL_TAB_COLUMNS
                WHERE OWNER = Upper(V_USER)) LOOP
      BEGIN
        V_SQL := 'SELECT COUNT(1) FROM ' || V_USER || '.' || V_TABLE.TABLE_NAME ||
                 ' WHERE ' || V_TABLE.COLUMN_NAME ||
                 --' = ''' || V_FIND || ''''
                 ' LIKE ''%' || IN_FIND || '%'''
                 ;
        --DBMS_OUTPUT.PUT_LINE(V_SQL);
        EXECUTE IMMEDIATE V_SQL
          INTO V_COUNT;
        IF (V_COUNT >= 1) THEN
          DBMS_OUTPUT.PUT_LINE('SELECT ' || V_TABLE.COLUMN_NAME ||
                               ' FROM ' || V_USER || '.' || V_TABLE.TABLE_NAME || ' WHERE ' ||
                               V_TABLE.COLUMN_NAME ||
                               --' = ''' || V_FIND || ''''
                               ' LIKE ''%' || IN_FIND || '%'';'
                               );
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    
  END LOOP;
  CLOSE v_cursor;

END;
