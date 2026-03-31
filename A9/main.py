import os
import oracledb
from dotenv import load_dotenv

load_dotenv()

oracledb.init_oracle_client(lib_dir=os.getenv("ORACLE_CLIENT_LIB_DIR"))

conn = oracledb.connect(
    user=os.environ.get("ORACLE_USERNAME"),
    password=os.environ.get("ORACLE_PASSWORD"),
    host="oracle.scs.ryerson.ca",
    port=1521,
    sid="orcl"
)

print("Connected:", conn.version)
conn.close()