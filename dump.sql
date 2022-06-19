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
    annual_salary INT unsigned NOT NULL,
    CONSTRAINT is_over_18 CHECK TIMESTAMPDIFF(YEAR, birthdate, curdate()) >= 18,
    CONSTRAINT is_less_than_100 CHECK TIMESTAMPDIFF(YEAR, birthdate, curdate()) < 100
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
    annual_interest_rate decimal(4,2) unsigned NOT NULL,
    property_id int NOT NULL,
    bank_id int NOT NULL,
    date_of_signing DATE NOT NULL,
    maturity_years tinyint unsigned NOT NULL,
    mbs_id int NULL,
    FOREIGN KEY (property_id) REFERENCES property(id),
    FOREIGN KEY (bank_id) REFERENCES bank(id),
    FOREIGN KEY (mbs_id) REFERENCES mbs(id),
    CONSTRAINT is_more_than_10000_dollars CHECK (amount >= 10000),
    CONSTRAINT maturity_years_in_valid_range CHECK (maturity_years IN (10, 15, 20, 30))
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
    FOREIGN KEY(mortgage_id) REFERENCES mortgage(id),
    CONSTRAINT month_reference_in_valid_range CHECK (month_reference >= 1 AND month_reference <= 12),
    CONSTRAINT month_and_year_reference_and_due_date_null_or_not CHECK (
        (month_reference IS NULL AND year_reference IS NULL AND due_date IS NULL)
        OR
        (month_reference IS NOT NULL AND year_reference IS NOT NULL AND due_date IS NOT NULL)
    )
);

DELIMITER $$

CREATE TRIGGER check_mortgage_amount BEFORE INSERT ON mortgage
FOR EACH ROW
BEGIN
    DECLARE property_value INT;
    SELECT value INTO property_value FROM property WHERE id = NEW.property_id;
    
    IF NEW.amount > property_value THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mortgage value cannot be more than the property value';
    END IF;
END $$

CREATE TRIGGER check mortgage_date_of_signing BEFORE INSERT ON mortgage
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(DAY, NEW.date_of_signing, curdate()) < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mortgage signing date cannot be in the future';
    END IF;

    IF TIMESTAMPDIFF(YEAR, NEW.date_of_signing, curdate()) > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot insert a mortgage older than 5 years';
    END IF;
END $$

CREATE TRIGGER check_mortgage_payment_dates BEFORE INSERT ON mortgage_payment
FOR EACH ROW
BEGIN
    DECLARE mortgage_signing_date date;

    IF NEW.month_reference IS NOT NULL AND NEW.year_reference IS NOT NULL AND NEW.due_date IS NOT NULL THEN
        SELECT date_of_signing INTO mortgage_signing_date FROM mortgage WHERE id = NEW.mortgage_id;
        
        IF (NEW.year_reference > YEAR(curdate())) OR (NEW.year_reference = YEAR(curdate()) AND NEW.month_reference > MONTH(curdate())) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The mortgage payment cannot refer to a future date';
        END IF;

        IF (NEW.year_reference < YEAR(mortgage_signing_date)) OR (NEW.year_reference = YEAR(mortgage_signing_date) AND NEW.month_reference < MONTH(mortgage_signing_date)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The mortgage payment cannot refer to a date before the mortgage signing date';
        END IF;

        IF NEW.due_date < mortgage_signing_date THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The mortgage payment due date cannot be before the mortgage signing date';
        END IF;

    END IF;

    IF NEW.payment_date < mortgage_signing_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The mortgage payment cannot be made before signing date';
    END IF;

    IF NEW.payment_date > curdate() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The mortgage payment cannot be made in a date in the future';
    END IF;

END $$

CREATE TRIGGER mortgage_payment_not_over_total_to_pay BEFORE INSERT ON mortgage_payment
FOR EACH ROW
BEGIN
    DECLARE extra_payments DECIMAL(9,2) DEFAULT 0;
    DECLARE total_to_pay DECIMAL(9,2) DEFAULT 0;
    DECLARE total_payed DECIMAL(9,2) DEFAULT 0;
    DECLARE mortgage_amount INT DEFAULT 0;
    DECLARE mortgage_annual_interest_rate DECIMAL(4,2) DEFAULT 0;
    DECLARE mortgage_maturity_years TINYINT UNSIGNED DEFAULT 0;

    SELECT 
        amount,
        annual_interest_rate,
        maturity_years
    INTO
        mortgage_amount,
        mortgage_annual_interest_rate,
        mortgage_maturity_years
    FROM
        mortgage
    WHERE
        id = NEW.mortgage_id;

    SELECT
        COALESCE(SUM(amount), 0)
    INTO
        extra_payments
    FROM
        mortgage_payment
    WHERE
        due_date IS NULL
        AND
        mortgage_id = NEW.mortgage_id;

    SELECT
        get_mortgage_monthly_payment(mortgage_amount - extra_payments, mortgage_annual_interest_rate, mortgage_maturity_years)
        *
        12
        *
        mortgage_maturity_years
    INTO
        total_to_pay;

    SELECT SUM(amount) INTO total_payed FROM mortgage_payment WHERE mortgage_id = NEW.mortgage_id AND due_date IS NOT NULL;

    IF (total_to_pay - total_payed) < NEW.amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The mortgage payment cannot be more than the remaining amount to pay';
    END IF;

END $$

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
