"""Armaps development configuration"""
import pathlib

# Root of the application
APPLICATION_ROOT = '/'

# Secret key if we add in cookies
SECRET_KEY = b'\xb4iu!\xeb\xd4"1U-\xad\xfe.mO]\xde#"N\xc6\x9c\xf8\x9b'

# Postgres database info
POSTGRESQL_DATABASE_HOST = "0.0.0.0"
POSTGRESQL_DATABASE_PORT = 5432
POSTGRESQL_DATABASE_USER = "armaps_user"
POSTGRESQL_DATABASE_PASSWORD = "password"
POSTGRESQL_DATABASE_DB = "armaps"