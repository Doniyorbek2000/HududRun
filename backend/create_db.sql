DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='admin') THEN
    CREATE ROLE admin LOGIN PASSWORD 'adm12';
  ELSE
    ALTER ROLE admin PASSWORD 'adm12';
  END IF;
END
$$;
SELECT 'CREATE DATABASE hududrun OWNER admin' WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname='hududrun')\gexec
