-- Create test database for running tests
CREATE DATABASE pokeql_test;

-- Grant all privileges to postgres user on test database
GRANT ALL PRIVILEGES ON DATABASE pokeql_test TO postgres;