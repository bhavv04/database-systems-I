import os
import oracledb

_oracle_client_initialized = False

def get_connection():
    global _oracle_client_initialized
    
    if not _oracle_client_initialized:
        oracledb.init_oracle_client(lib_dir=os.getenv("ORACLE_CLIENT_LIB_DIR"))
        _oracle_client_initialized = True
        
    return oracledb.connect(
        user=os.environ.get("ORACLE_USERNAME"),
        password=os.environ.get("ORACLE_PASSWORD"),
        host=os.environ.get("ORACLE_HOST", "oracle.scs.ryerson.ca"),
        port=int(os.environ.get("ORACLE_PORT", 1521)),
        sid=os.environ.get("ORACLE_SID", "orcl")
    )

def execute_sql_file(file_path):
    conn = get_connection()
    cursor = conn.cursor()
    
    with open(file_path, 'r') as f:
        sql_content = f.read()
        
    lines = [line for line in sql_content.split('\n') if not line.strip().startswith('--') and line.strip().lower() not in ['exit', 'commit', '']]
    sql_content = '\n'.join(lines)
    statements, current, in_plsql = [], [], False
   
    for line in sql_content.split('\n'):
        upper = line.strip().upper()
        if 'CREATE OR REPLACE TRIGGER' in upper or 'CREATE TRIGGER' in upper:
            in_plsql = True
            current.append(line)
            continue
        if upper.startswith('BEGIN') and in_plsql:
            current.append(line)
            continue
        if line.strip() == '/' and in_plsql:
            in_plsql = False
            stmt = '\n'.join(current).strip()
            if stmt:
                statements.append(stmt)
            current = []
            continue
        current.append(line)
        if line.rstrip().endswith(';'):
            if not in_plsql:
                stmt = '\n'.join(current).strip().rstrip(';')
                if stmt:
                    statements.append(stmt)
                current = []
    errors, success = [], 0
    for stmt in statements:
        if stmt and stmt.strip():
            try:
                cursor.execute(stmt)
                success += 1
            except Exception as e:
                errors.append(f"{stmt[:80]}... | Error: {str(e)}")
    conn.commit()
    cursor.close()
    conn.close()
    return {'success': success, 'errors': errors}

def execute_query(sql):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(sql)
    columns = [desc[0] for desc in cursor.description]
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return {'columns': columns, 'rows': rows}