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
    amount decimal(10,2) unsigned NOT NULL,
    month_reference tinyint unsigned NULL,
    year_reference year unsigned NULL,
    due_date date NULL,
    payment_date date NULL,
    FOREIGN KEY(mortgage_id) REFERENCES mortgage(id)
);

DELIMITER $$
CREATE FUNCTION get_mortgage_monthly_payment (
    mortgage_amount int,
    annual_interest_rate decimal(10,2),
    years tinyint
) 
RETURNS decimal(10,2) DETERMINISTIC
BEGIN 
    RETURN ROUND(
        (mortgage_amount * (annual_interest_rate / 100 / 12) * POWER( (1 + (annual_interest_rate / 100 / 12) ), (12 * years) ))
        /
        ( POWER( (1 + (annual_interest_rate / 100 / 12)), (12 * years)) - 1)
    , 2);
END $$

CREATE FUNCTION get_mortgage_surplus_payments_ratio (
    p_mortgage_id int
) RETURNS decimal(5,4) DETERMINISTIC
BEGIN
    SELECT
        SUM(mortgage_payment.amount) / mortgage.amount
    INTO @surplus_ratio
    FROM mortgage
        LEFT JOIN mortgage_payment ON mortgage.id = mortgage_payment.mortgage_id
    WHERE
        due_date IS NULL
        AND
        mortgage.id = p_mortgage_id
    GROUP BY
        mortgage.id;
    
    RETURN @surplus_ratio;
    
END $$

CREATE FUNCTION get_mortgage_payment_average_days_delay (
    p_mortgage_id int
)
RETURNS decimal(5,4) DETERMINISTIC
BEGIN
    SELECT 
        AVG(GREATEST(0, payment_date - due_date))
    INTO @average_delay
    FROM mortgage 
        LEFT JOIN mortgage_payment ON mortgage.id = mortgage_payment.mortgage_id
    WHERE
        due_date IS NOT NULL
        AND
        mortgage.id = p_mortgage_id;

    RETURN @average_delay;
        
END $$

CREATE FUNCTION get_mortgage_monthly_payment_to_income_ratio (
    p_mortgage_id int
)
RETURNS decimal(5,4) DETERMINISTIC
BEGIN
	SELECT 
    	amount,
        annual_interest_rate,
        maturity_years
        INTO
        @mortgage_value,
        @mortgage_annual_interest_rate,
        @mortgage_maturity_years
    FROM
    	mortgage
    WHERE id = p_mortgage_id;
    
    SELECT
    	SUM(annual_salary) / 12
    INTO @accountholders_total_monthly_income 
    FROM person
    	INNER JOIN accountholder ON person.id = accountholder.person_id
        INNER JOIN mortgage ON accountholder.mortgage_id = mortgage.id
    WHERE mortgage.id = p_mortgage_id
    GROUP BY mortgage.id;
 	SET @monthly_payment_to_income_ratio = get_mortgage_monthly_payment(@mortgage_value, @mortgage_annual_interest_rate, @mortgage_maturity_years) / @accountholders_total_monthly_income;   
 	
   	RETURN @monthly_payment_to_income_ratio;
END $$
DELIMITER ;
