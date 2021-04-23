"""Armaps model (database) API."""
import os
import flask
import psycopg2
import psycopg2.extras
import armaps


def get_db():
    """Open a new database connection."""
    if "db_con" not in flask.g:
        flask.g.db_con = psycopg2.connect(
            host=os.getenv('POSTGRES_HOST'),
            port=armaps.app.config['POSTGRESQL_DATABASE_PORT'],
            user=armaps.app.config['POSTGRESQL_DATABASE_USER'],
            # Uncomment to deploy to prod
            password=os.getenv('POSTGRESQL_DATABASE_PASSWORD'),
            # password=armaps.app.config['POSTGRESQL_DATABASE_PASSWORD'],
            database=armaps.app.config['POSTGRESQL_DATABASE_DB'],
        )
        flask.g.db_cur = flask.g.db_con.cursor(
            cursor_factory=psycopg2.extras.RealDictCursor
        )
    return flask.g.db_cur


@armaps.app.teardown_appcontext
def close_db(error):
    """Close the database at the end of a request."""
    assert error or not error  # Needed to avoid superfluous style error
    db_cur = flask.g.pop('db_cur', None)
    db_con = flask.g.pop('db_con', None)
    if db_con is not None:
        db_con.commit()
        db_cur.close()
        db_con.close()