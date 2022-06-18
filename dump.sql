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
    DECLARE surplus_ratio DECIMAL(5,4) DEFAULT 0;

    SELECT
        SUM(mortgage_payment.amount) / mortgage.amount
    INTO surplus_ratio
    FROM mortgage
        LEFT JOIN mortgage_payment ON mortgage.id = mortgage_payment.mortgage_id
    WHERE
        due_date IS NULL
        AND
        mortgage.id = p_mortgage_id
    GROUP BY
        mortgage.id;
    
    RETURN COALESCE(surplus_ratio, 0);
    
END $$

CREATE FUNCTION get_mortgage_payment_average_days_delay (
    p_mortgage_id int
)
RETURNS decimal(5,4) DETERMINISTIC
BEGIN
    DECLARE average_delay TINYINT UNSIGNED DEFAULT 0;

    SELECT 
        AVG(GREATEST(0, payment_date - due_date))
    INTO average_delay
    FROM mortgage 
        LEFT JOIN mortgage_payment ON mortgage.id = mortgage_payment.mortgage_id
    WHERE
        due_date IS NOT NULL
        AND
        mortgage.id = p_mortgage_id;

    RETURN average_delay;
        
END $$

CREATE FUNCTION get_mortgage_monthly_payment_to_income_ratio (
    p_mortgage_id int
)
RETURNS decimal(5,4) DETERMINISTIC
BEGIN
    DECLARE mortgage_value INT UNSIGNED DEFAULT 0;
    DECLARE mortgage_annual_interest_rate DECIMAL(4,2) UNSIGNED DEFAULT 0;
    DECLARE mortgage_maturity_years TINYINT(3) UNSIGNED DEFAULT 0;
    DECLARE accountholders_total_monthly_income DECIMAL(7,2) DEFAULT 0;
    DECLARE monthly_payment_to_income_ratio DECIMAL (4,2) DEFAULT 0;

	SELECT 
    	amount,
        annual_interest_rate,
        maturity_years
        INTO
        mortgage_value,
        mortgage_annual_interest_rate,
        mortgage_maturity_years
    FROM
    	mortgage
    WHERE id = p_mortgage_id;
    
    SELECT
    	SUM(annual_salary) / 12
    INTO accountholders_total_monthly_income 
    FROM person
    	INNER JOIN accountholder ON person.id = accountholder.person_id
        INNER JOIN mortgage ON accountholder.mortgage_id = mortgage.id
    WHERE mortgage.id = p_mortgage_id
    GROUP BY mortgage.id;

 	RETURN get_mortgage_monthly_payment(mortgage_value, mortgage_annual_interest_rate, mortgage_maturity_years) / accountholders_total_monthly_income;   
 	
END $$

CREATE FUNCTION get_dates_difference_in_years(
    past_date date,
    future_date date
) RETURNS int DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, past_date, future_date);
END $$

CREATE FUNCTION get_mortgage_amount_percentage_risk_due_to_accountholders_age(
    p_mortgage_id int
) RETURNS decimal(5,4) DETERMINISTIC 
BEGIN
    DECLARE amount_at_risk decimal(5,4) UNSIGNED DEFAULT 0;

    SELECT
        SUM(
            get_mortgage_monthly_payment(
                mortgage.amount,
                annual_interest_rate,
                maturity_years
            ) 
            *
            12
            *
            (annual_salary / total)
            *
            GREATEST(
                0,
                get_dates_difference_in_years(
                    birthdate,
                    DATE_ADD(
                        date_of_signing,
                        INTERVAL maturity_years YEAR
                    )
                ) - 80
            ) / mortgage.amount
        )
    INTO amount_at_risk
    FROM
        mortgage
    INNER JOIN accountholder ON mortgage_id = mortgage.id
    INNER JOIN person ON person_id = person.id
    INNER JOIN(
        SELECT
            mortgage.id AS id,
            SUM(annual_salary) AS total
        FROM
            mortgage
        INNER JOIN accountholder ON mortgage_id = mortgage.id
        INNER JOIN person ON person_id = person.id
        GROUP BY
            mortgage.id
    ) t1
    ON
        t1.id = mortgage.id  
    WHERE mortgage.id = p_mortgage_id
    GROUP BY mortgage.id;

    RETURN amount_at_risk;
END $$

CREATE FUNCTION get_mortgage_rating(
    p_mortgage_id int
) RETURNS char(1) DETERMINISTIC
BEGIN
    DECLARE risk_percentage decimal(5,4);

    SET risk_percentage
    = 
    (get_mortgage_monthly_payment_to_income_ratio(p_mortgage_id) * 0.35)
    +
    ((get_mortgage_payment_average_days_delay(p_mortgage_id) / 30) * 0.45)
    +
    (get_mortgage_amount_percentage_risk_due_to_accountholders_age(p_mortgage_id) * 0.10)
    +
    (get_mortgage_surplus_payments_ratio(p_mortgage_id) * 0.10);

    RETURN 
        CASE
        WHEN risk_percentage < 0.15 THEN 'A'
        WHEN risk_percentage >= 0.15 AND risk_percentage < 0.20 THEN 'B'
        ELSE 'C'
        END;
END $$

DELIMITER ;
