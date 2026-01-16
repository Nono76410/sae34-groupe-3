-- Créer la base de données RADIUS
CREATE DATABASE IF NOT EXISTS radius;

-- Se connecter à la base de données radius
\c radius;

-- Créer les tables RADIUS
CREATE TABLE IF NOT EXISTS radcheck (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) NOT NULL,
    attribute VARCHAR(64) NOT NULL,
    op VARCHAR(2) NOT NULL DEFAULT '==',
    value VARCHAR(253) NOT NULL
);

CREATE TABLE IF NOT EXISTS radreply (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) NOT NULL,
    attribute VARCHAR(64) NOT NULL,
    op VARCHAR(2) NOT NULL DEFAULT '=',
    value VARCHAR(253) NOT NULL
);

CREATE TABLE IF NOT EXISTS radgroupcheck (
    id SERIAL PRIMARY KEY,
    groupname VARCHAR(64) NOT NULL,
    attribute VARCHAR(64) NOT NULL,
    op VARCHAR(2) NOT NULL DEFAULT '==',
    value VARCHAR(253) NOT NULL
);

CREATE TABLE IF NOT EXISTS radgroupreply (
    id SERIAL PRIMARY KEY,
    groupname VARCHAR(64) NOT NULL,
    attribute VARCHAR(64) NOT NULL,
    op VARCHAR(2) NOT NULL DEFAULT '=',
    value VARCHAR(253) NOT NULL
);

CREATE TABLE IF NOT EXISTS radusergroup (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) NOT NULL,
    groupname VARCHAR(64) NOT NULL,
    priority INT DEFAULT 1
);

CREATE TABLE IF NOT EXISTS radacct (
    radacctid BIGSERIAL PRIMARY KEY,
    acctsessionid VARCHAR(32) NOT NULL,
    acctuniqueid VARCHAR(32) NOT NULL UNIQUE,
    username VARCHAR(64) NOT NULL,
    realm VARCHAR(64) DEFAULT '',
    nasipaddress VARCHAR(15) NOT NULL,
    nasportid VARCHAR(15),
    nasporttype VARCHAR(32),
    acctstarttime TIMESTAMP,
    acctstoptime TIMESTAMP,
    acctsessiontime INT,
    acctauthentic VARCHAR(32),
    connectinfo_start VARCHAR(50),
    connectinfo_stop VARCHAR(50),
    acctinputoctets BIGINT DEFAULT 0,
    acctoutputoctets BIGINT DEFAULT 0,
    calledstationid VARCHAR(50),
    callingstationid VARCHAR(50),
    acctterminatecause VARCHAR(32),
    servicetype VARCHAR(32),
    framedprotocol VARCHAR(32),
    framedipaddress VARCHAR(15)
);

-- Créer les indexes
CREATE INDEX idx_radcheck_username ON radcheck(username);
CREATE INDEX idx_radreply_username ON radreply(username);
CREATE INDEX idx_radacct_username ON radacct(username);
CREATE INDEX idx_radacct_acctsessionid ON radacct(acctsessionid);
CREATE INDEX idx_radacct_acctstarttime ON radacct(acctstarttime);

-- Insérer des utilisateurs de test
-- Utilisateur 1: steve / testing
INSERT INTO radcheck (username, attribute, op, value) VALUES ('steve', 'User-Password', ':=', 'testing');
INSERT INTO radreply (username, attribute, op, value) VALUES ('steve', 'Reply-Message', '=', 'Welcome Steve');

-- Utilisateur 2: sqluser / sqlpassword (pour test SQL)
INSERT INTO radcheck (username, attribute, op, value) VALUES ('sqluser', 'User-Password', ':=', 'sqlpassword');
INSERT INTO radreply (username, attribute, op, value) VALUES ('sqluser', 'Reply-Message', '=', 'Welcome SQL User');

-- Créer un rôle RADIUS avec les permissions appropriées
CREATE ROLE IF NOT EXISTS radius WITH LOGIN PASSWORD 'radpass';
GRANT CONNECT ON DATABASE radius TO radius;
GRANT USAGE ON SCHEMA public TO radius;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO radius;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO radius;

