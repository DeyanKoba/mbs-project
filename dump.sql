DROP DATABASE IF EXISTS mbs_project_2022;

CREATE DATABASE mbs_project_2022;

USE mbs_project_2022;

DROP TABLE IF EXISTS person;
CREATE TABLE person (
    id int AUTO_INCREMENT PRIMARY KEY,
    name varchar(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    birthdate DATE NOT NULL,
    employment VARCHAR(255),
    annual_salary INT unsigned NOT NULL
);

DROP TABLE IF EXISTS phone_number;
CREATE TABLE phone_number (
    id int AUTO_INCREMENT PRIMARY KEY,
    number varchar(255) NOT NULL,
    person_id int,
    FOREIGN KEY(person_id) REFERENCES person(id)
);

DROP TABLE IF EXISTS location;
CREATE TABLE location (
    zip_code varchar(5) PRIMARY KEY,
    city varchar(255) NOT NULL,
    state varchar(255) NOT NULL
);

DROP TABLE IF EXISTS bank;
CREATE TABLE bank (
    id int AUTO_INCREMENT PRIMARY KEY,
    name varchar(255) NOT NULL,
    address varchar(255) NOT NULL,
    address_number varchar(5) NULL,
    zip_code varchar(5) NOT NULL,
    vat_code varchar(255) NOT NULL,
    FOREIGN KEY(zip_code) REFERENCES location(zip_code)
);

DROP TABLE IF EXISTS property;
CREATE TABLE property (
    id int AUTO_INCREMENT PRIMARY KEY,
    address varchar(255) NOT NULL,
    address_number varchar(5) NULL,
    zip_code varchar(5) NOT NULL,
    value int unsigned NOT NULL,
    FOREIGN KEY(zip_code) REFERENCES location(zip_code)
);

DROP TABLE IF EXISTS mbs;
CREATE TABLE mbs (
    id int AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS mortgage;
CREATE TABLE mortgage (
    id int AUTO_INCREMENT PRIMARY KEY,
    amount int unsigned NOT NULL,
    annual_interest_rate tinyint unsigned NOT NULL,
    property_id int NOT NULL,
    bank_id int NOT NULL,
    date_of_signing DATE NOT NULL,
    maturity_years tinyint unsigned NOT NULL,
    mbs_id int NULL,
    FOREIGN KEY (property_id) REFERENCES property(id),
    FOREIGN KEY (bank_id) REFERENCES bank(id),
    FOREIGN KEY (mbs_id) REFERENCES mbs(id)
);

DROP TABLE IF EXISTS accountholder;
CREATE TABLE accountholder (
    mortgage_id int NOT NULL,
    person_id int NOT NULL,
    FOREIGN KEY (mortgage_id) REFERENCES mortgage(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);

DROP TABLE IF EXISTS mbs_tranche;
CREATE TABLE mbs_tranche (
    id int AUTO_INCREMENT PRIMARY KEY,
    mbs_id int,
    percentage tinyint unsigned NOT NULL,
    maturity_years tinyint unsigned NOT NULL,
    FOREIGN KEY(mbs_id) REFERENCES mbs(id)
);

DROP TABLE IF EXISTS mortgage_payment;
CREATE TABLE mortgage_payment (
    id int AUTO_INCREMENT PRIMARY KEY,
    mortgage_id int NOT NULL,
    amount int unsigned NOT NULL,
    month_reference tinyint unsigned NULL,
    year_reference year unsigned NULL,
    due_date date NULL,
    payment_date date NULL,
    FOREIGN KEY(mortgage_id) REFERENCES mortgage(id)
);