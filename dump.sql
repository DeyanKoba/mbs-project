DROP DATABASE IF EXISTS mbs_project_2022;

CREATE DATABASE mbs_project_2022;

USE mbs_project_2022;

DROP TABLE IF EXISTS persona;
CREATE TABLE persona (
    id int AUTO_INCREMENT PRIMARY KEY,
    nome varchar(255) NOT NULL,
    cognome VARCHAR(255) NOT NULL,
    data_nascita DATE NOT NULL,
    impiego VARCHAR(255),
    salario_annuo INT unsigned NOT NULL
);

DROP TABLE IF EXISTS recapito_telefonico;
CREATE TABLE recapito_telefonico (
    id int AUTO_INCREMENT PRIMARY KEY,
    telefono varchar(255) NOT NULL,
    persona_id int,
    FOREIGN KEY(persona_id) REFERENCES persona(id)
);

DROP TABLE IF EXISTS banca;
CREATE TABLE banca (
    id int AUTO_INCREMENT PRIMARY KEY,
    indirizzo varchar(255) NOT NULL,
    civico varchar(5) NULL,
    cap varchar(5) NOT NULL,
    citta varchar(255) NOT NULL,
    provincia varchar(255) NOT NULL,
    piva varchar(255) NOT NULL,
    codice_rea varchar(255) NOT NULL
);

DROP TABLE IF EXISTS immobile;
CREATE TABLE immobile (
    id int AUTO_INCREMENT PRIMARY KEY,
    indirizzo varchar(255) NOT NULL,
    civico varchar(5) NULL,
    cap varchar(5) NOT NULL,
    citta varchar(255) NOT NULL,
    provincia varchar(255) NOT NULL,
    valore int unsigned NOT NULL 
);

DROP TABLE IF EXISTS mbs;
CREATE TABLE mbs (
    id int AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS mutuo;
CREATE TABLE mutuo (
    id int AUTO_INCREMENT PRIMARY KEY,
    importo int unsigned NOT NULL,
    tasso_interesse_annuo tinyint unsigned NOT NULL,
    immobile_id int NOT NULL,
    banca_id int NOT NULL,
    data_sottoscrizione DATE NOT NULL,
    durata_anni tinyint unsigned NOT NULL,
    mbs_id int NULL,
    FOREIGN KEY (immobile_id) REFERENCES immobile(id),
    FOREIGN KEY (banca_id) REFERENCES banca(id),
    FOREIGN KEY (mbs_id) REFERENCES mbs(id)
);

DROP TABLE IF EXISTS intestatario;
CREATE TABLE intestatario (
    mutuo_id int NOT NULL,
    persona_id int NOT NULL,
    FOREIGN KEY (mutuo_id) REFERENCES mutuo(id),
    FOREIGN KEY (persona_id) REFERENCES persona(id)
);

DROP TABLE IF EXISTS rata;
CREATE TABLE rata (
    id int AUTO_INCREMENT PRIMARY KEY,
    importo int unsigned NOT NULL,
    data_scadenza DATE NOT NULL,
    mutuo_id int,
    FOREIGN KEY(mutuo_id) REFERENCES mutuo(id)
);

DROP TABLE IF EXISTS mbs_tranche;
CREATE TABLE mbs_tranche (
    id int AUTO_INCREMENT PRIMARY KEY,
    mbs_id int,
    percentuale tinyint unsigned NOT NULL,
    maturity_years tinyint unsigned NOT NULL
);
