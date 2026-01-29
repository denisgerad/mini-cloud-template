import os
from typing import List

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import psycopg


app = FastAPI(title="Mini Cloud API")

origins = [
    "http://app.local",
    "http://api.local",
    "http://localhost",
    "http://127.0.0.1",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def _get_dsn() -> dict:
    return {
        "host": os.getenv("DB_HOST", "localhost"),
        "dbname": os.getenv("DB_NAME", "postgres"),
        "user": os.getenv("DB_USER", "postgres"),
        "password": os.getenv("DB_PASS", ""),
        "port": int(os.getenv("DB_PORT", "5432")),
    }


@app.get("/")
async def root():
    status = "OK"
    db_status = await _check_db()
    return {"status": status, "db": db_status}


@app.get("/health")
async def health():
    return {"status": "ok"}


async def _check_db() -> str:
    try:
        dsn = _get_dsn()
        conn = psycopg.connect(**dsn, connect_timeout=5)
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
            row = cur.fetchone()
        conn.close()
        return "OK" if row and row[0] == 1 else "UNKNOWN"
    except Exception as e:
        return f"ERROR: {e}"


@app.get("/db")
async def db_tables() -> dict:
    try:
        dsn = _get_dsn()
        conn = psycopg.connect(**dsn, connect_timeout=5)
        with conn.cursor() as cur:
            cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name LIMIT 50;")
            rows = cur.fetchall()
        conn.close()
        tables: List[str] = [r[0] for r in rows]
        return {"tables": tables}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
