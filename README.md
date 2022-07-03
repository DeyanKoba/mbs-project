# Progetto per l'esame di Basi di Dati - "Mortgage Backed Securities"

Università degli studi di Trieste - Corso di Laurea in Ingegneria Elettronica ed Informatica - Deyan Koba IN0500754
<br>
## Introduzione

Una banca d'investimento con sede negli USA richiede la realizzazione di un database per gestire i propri Mortgage Backed Securities (MBS).
Un MBS, in breve, è un insieme di mutui raccolti in un "pacchetto", quest'ultimo viene successivamente suddiviso in quote (tranches) con diverso ROI (Return On Investment) in base a vari fattori tra cui rischio, tasso di interesse e durata, per essere vendute al pubblico come forma d'investimento. In tal modo le banche rientrano "immediatamente" del capitale concesso in prestito ed in pratica è l'investitore finale che acquista le tranches a fornire il capitale per finanziare i mutui, ricevendo periodicamente i dividendi generati dagli interessi dei mutui.
<br>
> [Mortgage Backed Security Definition](https://www.investopedia.com/terms/m/mbs.asp)<br>
> [Tranches Definition](https://www.investopedia.com/terms/t/tranches.asp)<br>
> [Investment Bank Definition](https://www.investopedia.com/terms/i/investmentbank.asp)<br>
> [Commercial Bank Definition](https://www.investopedia.com/terms/c/commercialbank.asp)<br>

<br>
La banca d'investimento acquista in blocco, una volta l'anno, dai 1000 ai 3000 mutui rilasciati da altre banche commerciali che vengono successivamente inseriti in un MBS, ad ogni mutuo viene assegnata una valutazione del rischio che potrà essere <b>A</b>, <b>B</b> oppure <b>C</b>;

* **A** indica un mutuo per il quale si suppone un basso rischio di insolvenza;
* **B** indica un rischio medio;
* **C** indica un rischio alto;

Il fattore di rischio è calcolato su 4 parametri con diverse incidenze:

1. Rapporto tra rata mensile ed entrate mensili dei soggetti intestatari del mutuo, incidenza del 35%
2. Rapporto tra i giorni medi di ritardo nei pagamenti ed la durata di un mese commerciale (30 giorni), incidenza del 45%
3. Rapporto tra versamenti in surplus ed il capitale concesso, incidenza del 10%
4. Rapporto tra rate potenzialmente non incassabili dovute all'età del soggetto ed il capitale concesso, incidenza del 10%

Per il punto 4 si assume che la vita media si attesti ad 80 anni, per cui il capitale a rischio per età degli intestatari è la somma delle rate mensili dovute oltre il compimento dell'ottantesimo anno di età.
Nel caso in cui un mutuo sia intestato a più di un soggetto e di questi solo alcuni siano a rischio di insolvenza per età, si terrà conto del rapporto tra reddito dei soggetti a rischio sul reddito totale dei cointestatari.

Il fattore di rischio è quindi calcolato nel seguente modo:

**(35%** • <b>*risultato al punto 1*) + (45%</b> • <b>*risultato al punto 2*) + (10%</b> • <b>*risultato al punto 3*) + (10%</b> • <b>*risultato al punto 4*)</b> <br><br>
Per valori inferiori a 0.15 viene assegnato un rating <b>A</b>, per valori maggiori o uguali a 0.15 e inferiori a 0.20 viene assegnato un rating <b>B</b>, altrimenti <b>C</b>

Ogni MBS in una situazione "normale" è composto nel seguente modo:

* attorno all'80% da mutui di classe A
* il restante da mutui di classe B e C

<br>
Di un mutuo si hanno i dati relativi al suo importo, il tasso d'interesse fisso annuo, la data in cui è stato stipulato, la durata in anni oltre ai dati della relativa proprietà per la quale è stato concesso il mutuo, gli intestatari e la banca che lo ha rilasciato.
Di un intestatario si hanno a disposizione nome, cognome, data di nascita, salario annuo ed eventualmente impiego.
Di una proprietà si ha il valore e l'indirizzo, mentre di una banca si ha nome ed indirizzo.
Per quanto riguarda i pagamenti si ha a disposizione l'importo del versamento, la data del versamento ed eventualmente una data di scadenza nel caso in cui il versamento faccia riferimento ad una rata.

## Azioni che devono essere eseguibili sul database

1. Inserire un mutuo acquistato ed i dati correlati ad esso, ovvero:
    * storico dei pagamenti
    * dati degli intestatari
    * dati sulla proprietà per la quale è stato concesso il mutuo
    * banca che ha rilasciato il mutuo
2. Calcolare il rating di un mutuo
3. Assegnare un mutuo ad un MBS
4. Ottenere la composizione percentuale suddivisa per rischio di un MBS
5. Ottenere la lista dei mutui presenti in database con il relativo rating che non sono ancora stati assegnati ad un MBS 

Tutte queste azioni vengono eseguite all'incirca 1 o 2 volte l'anno.

## Schema Entity-Relationship

![ER](documentation/ER.svg)

## Analisi della dimensione

Dalla banca d'investimenti ci vengono fornire le seguenti informazioni:
<br>
> *I mutui vengono acquistati in blocco una volta l'anno, in quell'occasione devono essere inseriti all'interno del gestionale con i relativi dati correlati entro un mese dal momento dell'acquisto;*<br>
> *Per politiche aziendali non vengono mai acquistati mutui più vecchi di 5 anni e l'età media del mutuo acquistato si aggira attorno ai 2-3 anni dalla stipula.*<br>
> *Circa l'85% dei mutui è intestato ad una persona singola ed il rimanente 15% a due persone.*<br>
> *I pagamenti in surplus vengono solitamente effettuati da clienti a rischio basso con una probabilità del 10%, per un numero medio di 1 versamento l'anno.*<br>
> *Le banche commerciali dalle quale vengono acquistati i mutui sono una ventina.*<br>

<br>
Con queste informazioni, tenendo in considerazione un acquisto medio di 2000 mutui andiamo a stimare le dimensioni del database:<br><br>

| Entità | Numero di entità inserite ogni anno | Tipologia | Note |
| ------ | ----------------------------------- | ---- |---- |
| Mortgage | 2000 | E | |
| Property | 2000 | E | Una proprietà per mutuo |
| Mortgage Payment | 60000 | E | In base alle dichiarazioni l'età media del mutuo al momento dell'acquisto si aggira attorno ai 2-3 anni;<br>in questo caso si è presa in considerazione una durata di 30 mesi, moltiplicata per i 2000 mutui<br>porta a 60000 pagamenti ordinari |
| Surplus Payment | 400 | E | 80% di 2000 mutui = 1600 mutui di classe A<br>10% di probabilità che un mutuo di classe A effettui un pagamento in surplus = 160 mutui effettuano pagamenti in surplus<br>1 versamento l'anno di media su una durata media di 30 mesi = 400 versamenti in surplus |
| Person | 2300 | E | 85% di 2000 = 1700 mutui intestati ad una persona<br>15% di 2000 = 300 mutui intestati a due persone |
| Bank | 20 | E |  |
| MBS | 1 | E |  |
| Location | 40000 | E | Location accoglie al suo interno i vari ZIP Codes con la relativa città e stato, negli USA questi sono circa 40000 |
| Accountholder | 2300 | R |  |
| Whereabouts | 2020 | R | Una per ogni immobile e per banca |
| Borrower | 2300 | R | Una per ogni persona |
| Collateral | 200 | R | Una per ogni mutuo con la relativa proprietà associata |
| Issuing | 2000 | R | Una per ogni mutuo emesso |
| Transaction | 60400 | R | Una transazione per ogni pagamento |
| Assignment | 2000 | R | Una per ogni mutuo |

## Ristrutturazione Schema ER

### Eliminazione degli attributi multivalore e composti
Si procede con la scomposizione dell'attributo *address* presente in *Bank* e *Property* in 3 attributi distinti: *Street Name*, *Address Number* e *ZIP Code*.<br>

### Eliminazione delle generalizzazioni
L'entità *Payment* può essere vista come parent di *Mortgage Payment* e *Surplus Payment* per le quali però l'unica differenza risiede nell'attributo *due_date* presente solamente in *Mortgage Payment*. Ritengo adeguato a questo punto unire le due entità in un'unica entità *Payment* con gli attributi di *Mortgage Payment* impostando però l'attributo *due_date* come nullable ovvero che permette valori `NULL` in tal modo otteniamo la distinzione tra le due tipologie di pagamento

## Vincoli non esprimibili graficamente

Da un'analisi del problema posto sorgono dei vincoli che non sono esprimibili graficamente:

* L'importo minimo concesso come mutuo è di $ 10.000,00;
* Una persona deve essere maggiorenne per poter stipulare o essere cointestatario di un mutuo;
* L'importo concesso per un mutuo non può superare il valore del relativo immobile;
* La durata ammissibile in anni di un mutuo può essere di 10, 15, 20 oppure 30 anni;
* La data di stipula di un mutuo non può essere datata nel futuro ed allo stesso modo non può essere più vecchia di 5 anni + 1 mese di tempo calcolato come margine per permettere l'inserimento dei dati all'interno del gestionale dal momento dell'acquisto;
* Un versamento non può essere datato nel futuro ed allo stesso modo non può essere datato prima della stipula di un mutuo;
* La data di scadenza di un pagamento così come la data stessa del pagamento non possono essere antecedenti la data di stipula del mutuo;
* Il versamento per un mutuo non può eccedere la parte rimanente da saldare;
* Il tasso di interesse non può essere negativo;

Per realizzare il vincolo sulla maggiore età di un intestatario è necessario ricorrere ad un trigger in quanto i CHECK non possono utilizzare al loro interno funzioni non deterministiche (in questo caso `curdate()`), così come per i check sulla data di stipulazione del mutuo e sulle date dei pagamenti.
Allo stesso modo per realizzare il check sul valore dell'immobile e per il check sull'importo del versamento è necessario ricorrere alle relazioni con i dati correlati per le quali è necessario ricorrere ad un trigger.

Per il vincolo sul tasso di interesse è necessario utilizzare un `CHECK` in quanto in MySQL il constraint `UNSIGNED` per gli attributi di tipo decimal è deprecato.
> [WL#12391: Deprecate unsigned attribute for DECIMAL and FLOAT data types](https://dev.mysql.com/worklog/task/?id=12391)

<br>
## Considerazioni sul dimensionamento dei singoli attributi

Per il dimensionamento degli attributi, in particolar modo per gli identificatori, si è cercato di ottenere un margine che permettesse l'inserimento di dati per almeno 20 anni con un carico di dati 10 volte superiore alla stima originale.

Con una stima di 2300 persone inserite nel DB ogni anno e circa 2000 mutui, dove ogni mutuo corrisponde ad una proprietà, è stato scelto di utilizzare `MEDIUMINT UNSIGNED` per l'identificatore di Person, Mortgage e Property; `MEDIUMINT UNSIGNED` accoglie valori che vanno da 0 a 16.777.215, il che vorrebbe dire che per esaurire tutti gli identificatori ci vorrebbero quasi 7000 anni (anche nel caso di un carico di dati 10 volte superiore alla stima originale si impiegherebbero quasi 700 anni per esaurire gli identificatori per le persone ed i mutui).
E' stato preso in considerazione di utilizare anche `SMALLINT UNSIGNED` che permette valori fino a 65535, è stato scartato in quanto con la stima dei dati attuali si impiegherebbero circa 30 anni per esaurire gli identificatori, che con un carico di dati 10 volte superiore alla stima originale diventerebbero circa 3.

Per l'identificatore di Payment è stato scelto di adottare `MEDIUMINT UNSIGNED`, con una media di 60.000 pagamenti all'anno esso sarebbe sufficiente per quasi 300 anni e con un carico 10 volte superiore tale stima sarebbe pari a quasi 30 anni.

Un ragionamento analogo è stato effettuato per gli identificatori di Bank per il quale è stato scelto `TINYINT UNSIGNED` che può accogliere valori da 0 a 255; considerando che le banche vengono inserite solamente quando si acquistano mutui da una banca non ancora presente nel DB ed avendo una stima di 20 banche abituali dalle quali vengono acquistati i mutui, con un carico di 10 volte tanto si va a 200, in questo caso un margine di 55 identificatori è stato ritenuto sufficiente.

Per gli MBS è stato scelto di utilizzare `TINYINT UNSIGNED`; siccome si stima di emettere un MBS all'anno questo valore è sufficiente per 255 anni, con un carico di dati 10 volte superiore (10 MBS emessi ogni anno) questo valore basterebbe per 25 anni.

Per l'attributo *amount* di *Mortgage* è stato utilizzato `MEDIUMINT UNSIGNED` che può accogliere valori compresi tra 0 e 16.777.215, si è ritenuto adeguato tale importo massimo in quanto difficilmente un mutuo supererà tale limite superiore, mentre `SMALLINT UNSIGNED` avrebbe imposto un limite superiore pari a 65.535 che è certamente insufficiente.

Per l'attributo *value* di *Property* è stato scelto di adottare `MEDIUMINT UNSIGNED` in quanto va ad imporre un limite superiore al valore dell'immobile pari a 16.777.215, limite che si è ritenuto adeguato (anche in questo caso si è escluso `SMALLINT UNSIGNED` in quanto avrebbe imposto un valore massimo dell'immobile pari a 65.535).
Di conseguenza per l'attributo *amount* di *Payment* è stato scelto di utilizzare `DECIMAL(7,2)` in quanto implicherebbe un importo massimo pari a 99.999,99. Si è considerato che un valore 10 volte più piccolo sarebbe stato insufficiente in quanto ci potrebbero essere dei versamenti in surplus superiori 10.000,00, allo stesso modo si è considerato che difficilmente ci potranno essere dei versamenti in surplus superiori a 99.999,99.

Per quanto riguarda annual\_interest\_rate è stato scelto di adottare `DECIMAL(4,2)` che permette valori decimali per un totale di 4 cifre di cui 2 decimali (in tal modo si riescono ad avere tassi di interesse fino al 99.99%). Non si è ritenuto sufficiente utilizzare `DECIMAL(3,2)` in quanto il suo limite superiore sarebbe stato 9.99% che è stato ritenuto non sufficientemente alto consultando i dati storici antecedenti il 1991.

> Fonte: FreddieMac (Federal Home Loan Mortgage Corporation), [30-Year Fixed-Rate Mortgages Since 1971](https://www.freddiemac.com/pmms/pmms30)

## Diagramma ER Ristrutturato
![ER Ristrutturato](documentation/ER-restructured.svg)

## Passaggio al modello relazionale
Per permettere l'inserimento di un solo mutuo per immobile si va ad impostare un constraint di tipo `UNIQUE` sull'attribute property_id che è chiave esterna con riferimento a `Property.id` <br>

## Schema logico
![ERD](documentation/ERD.svg)

## Creazione fisica

### Query per la creazione delle tabelle assieme ai check base
```
DROP DATABASE IF EXISTS mbs_project_2022;

CREATE DATABASE mbs_project_2022;

USE mbs_project_2022;

CREATE TABLE person (
    id MEDIUMINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    birthdate DATE NOT NULL,
    employment VARCHAR(255),
    annual_salary MEDIUMINT unsigned NOT NULL
);

CREATE TABLE location (
    zip_code VARCHAR(5) PRIMARY KEY,
    city VARCHAR(255) NOT NULL,
    state VARCHAR(255) NOT NULL
);

CREATE TABLE bank (
    id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    street_name VARCHAR(255) NOT NULL,
    address_number VARCHAR(5) NULL,
    zip_code VARCHAR(5) NOT NULL,
    FOREIGN KEY(zip_code) REFERENCES location(zip_code)
);

CREATE TABLE property (
    id MEDIUMINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    street_name VARCHAR(255) NOT NULL,
    address_number VARCHAR(5) NULL,
    zip_code VARCHAR(5) NOT NULL,
    value MEDIUMINT UNSIGNED NOT NULL,
    FOREIGN KEY(zip_code) REFERENCES location(zip_code)
);

CREATE TABLE mbs (
    id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE mortgage (
    id MEDIUMINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    amount MEDIUMINT UNSIGNED NOT NULL,
    annual_interest_rate DECIMAL(4,2) NOT NULL,
    property_id INT UNSIGNED NOT NULL,
    bank_id SMALLINT UNSIGNED NOT NULL,
    date_of_signing DATE NOT NULL,
    maturity_years TINYINT unsigned NOT NULL,
    mbs_id SMALLINT UNSIGNED NULL,
    FOREIGN KEY (property_id) REFERENCES property(id),
    FOREIGN KEY (bank_id) REFERENCES bank(id),
    FOREIGN KEY (mbs_id) REFERENCES mbs(id),
    CONSTRAINT is_more_than_10000_dollars CHECK (amount >= 10000),
    CONSTRAINT maturity_years_in_valid_range CHECK (maturity_years IN (10, 15, 20, 30)),
    CONSTRAINT annual_interest_rate_is_more_than_0 CHECK (annual_interest_rate > 0)
);

CREATE TABLE accountholder (
    mortgage_id MEDIUMINT NOT NULL,
    person_id MEDIUMINT NOT NULL,
    FOREIGN KEY (mortgage_id) REFERENCES mortgage(id),
    FOREIGN KEY (person_id) REFERENCES person(id)
);

CREATE TABLE payment (
    id MEDIUMINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    mortgage_id MEDIUMINT UNSIGNED NOT NULL,
    amount DECIMAL(7,2) NOT NULL,
    due_date DATE NULL,
    payment_date DATE NOT NULL,
    FOREIGN KEY(mortgage_id) REFERENCES mortgage(id),
    CONSTRAINT amount_is_more_than_0 CHECK (amount > 0)
);
```

### Query per la creazione dei trigger

```
DELIMITER $$

CREATE TRIGGER check_person_age BEFORE INSERT ON person
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.birthdate, curdate()) < 18 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The person must be at least 18 years old';
    END IF;
END $$

CREATE TRIGGER check_mortgage_amount BEFORE INSERT ON mortgage
FOR EACH ROW
BEGIN
    DECLARE property_value INT;
    SELECT value INTO property_value FROM property WHERE id = NEW.property_id;
    
    IF NEW.amount > property_value THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mortgage value cannot be more than the property value';
    END IF;
END $$

CREATE TRIGGER check_mortgage_date_of_signing BEFORE INSERT ON mortgage
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(DAY, NEW.date_of_signing, curdate()) < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mortgage signing date cannot be in the future';
    END IF;

    IF TIMESTAMPDIFF(MONTH, NEW.date_of_signing, curdate()) > 61 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot insert a mortgage older than 5 years';
    END IF;
END $$

CREATE TRIGGER check_payment_dates BEFORE INSERT ON mortgage_payment
FOR EACH ROW
BEGIN
    DECLARE mortgage_signing_date DATE;
    SELECT date_of_signing INTO mortgage_signing_date FROM mortgage WHERE id = NEW.mortgage_id;

    IF NEW.due_date IS NOT NULL AND NEW.due_date < mortgage_signing_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A payment due date cannot be before the mortgage signing date';
    END IF;

    IF NEW.payment_date < mortgage_signing_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A payment cannot be made before the mortgage signing date';
    END IF;

    IF NEW.payment_date > curdate() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A mortgage payment cannot be made in a date in the future';
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

DELIMITER ;
```
