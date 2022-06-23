# Progetto per l'esame di Basi di Dati - "Mortgage Backed Securities"

Università degli studi di Trieste - Corso di Laurea in Ingegneria Elettronica ed Informatica - Deyan Koba
<br>
### Introduzione

Una banca d'investimento richiede la realizzazione di un database per gestire i propri Mortgage Backed Securities (MBS).
Un MBS, in breve, è un insieme di mutui raccolti in un "pacchetto", quest'ultimo viene successivamente suddiviso in quote (tranches) con diverso ROI (Return On Investment) in base al rischio e vendute al pubblico come forma d'investimento. In tal modo le banche rientrano "immediatamente" del capitale concesso in prestito ed in pratica è l'investitore finale che acquista le tranches a fornire il capitale per finanziare i mutui, ricevendo periodicamente i dividendi generati dagli interessi dei mutui.
<br>
> [Mortgage Backed Security Definition](https://www.investopedia.com/terms/m/mbs.asp)
> [Tranches Definition](https://www.investopedia.com/terms/t/tranches.asp)

<br>
La banca d'investimento acquista in blocco, una volta l'anno, dai 1000 ai 3000 mutui rilasciati da altre banche commerciali, ad ogni mutuo viene assegnata una valutazione di rischio che potrà essere 'A', 'B' oppure 'C';

* **A** indica un mutuo per il quale si suppone un basso rischio di insolvenza;
* **B** indica un rischio medio;
* **C** indica un rischio alto;

Il fattore di rischio è calcolato su 4 parametri con diverse incidenze:

1. Rapporto tra rata mensile ed entrate mensili dei soggetti intestatari del mutuo, incidenza del 35%
2. Rapporto tra i giorni medi di ritardo nei pagamenti ed la durata di un mese commerciale (30 giorni), incidenza del 45%
3. Rapporto tra versamenti in surplus ed il capitale concesso, incidenza del 10%
4. Rapporto tra rate potenzialmente non incassabili dovute all'età del soggetto ed il capitale concesso, incidenza del 10%

Per il punto 4 si assume che la vita media si attesti ad 80 anni, per cui il capitale a rischio per età degli intestatari è la somma delle rate mensili dovute oltre il compimento dell'ottantesimo anno di età.
Nel caso in cui un mutuo sia intestato a più di un soggetto e di questi solo alcuni siano a rischio di insolvenza per età, si terrà conto del rapporto tra reddito dei soggetti a rischio sul reddito toale dei cointestatari.

Il fattore di rischio è quindi calcolato nel seguente modo:

**(35%** • <b>*risultato al punto 1*) + (45%</b> • <b>*risultato al punto 2*) + (10%</b> • <b>*risultato al punto 3*) + (10%</b> • <b>*risultato al punto 4*)</b>

Ogni MBS in una situazione "normale" è composto nel seguente modo:

* attorno all'80% da mutui di classe A
* il restante da mutui di classe B e C

<br>
### Azioni eseguibili sul database

1. Inserire un mutuo acquistato ed i dati correlati ad esso, ovvero:
    * storico dei pagamenti
    * dati degli intestatari
    * dati sulla proprietà per la quale è stato concesso il mutuo
    * banca che ha rilasciato il mutuo
2. Calcolare il rating di un mutuo
3. Assegnare un mutuo ad un MBS
4. Ottenere la composizione percentuale suddivisa per rischio di un MBS

<br>
### Analisi nel dettaglio

Dalla banca d'investimenti ci vengono fornire le seguenti informazioni:
<br>
> *I mutui vengono acquistati in blocco una volta l'anno, in quell'occasione devono essere inseriti all'interno del gestionale con i relativi dati correlati;*
> *Per politiche aziendali non vengono mai acquistati mutui più vecchi di 5 anni e l'età media del mutuo acquistato si aggira attorno ai 2-3 anni dalla stipula.*
> *Circa l'85% dei mutui è intestato ad una persona singola ed il rimanente 15% a due persone.*
> *I pagamenti in surplus vengono solitamente effettuati da clienti a rischio basso con una probabilità del 10%, per un numero medio di 1 versamento l'anno.*
> *Le banche commerciali dalle quale vengono acquistati i mutui sono una ventina.*

<br>
Con queste informazioni, tenendo in considerazione un acquisto medio di 2000 mutui andiamo a stimare le dimensioni del database:

| Entità | Numero di entità inserite ogni anno | Note |
| ------ | ----------------------------------- | ---- |
| Mutuo | 2000 |  |
| Proprietà | 2000 | Una proprietà per mutuo |
| Pagamento | 60000 | In base alle dichiarazioni l'età media del mutuo al momento dell'acquisto si aggira attorno ai 2-3 anni;<br>in questo caso si è presa in considerazione una durata di 30 mesi, moltiplicata per i 2000 mutui<br>porta a 60000 pagamenti ordinari. Ai 60000 pagamenti ordinari andrebbero sommati 400 pagamenti <br>in surplus ottenuti nel seguente modo:<br><br>80% di 2000 mutui = 1600 mutui di classe A<br>10% di probabilità che un mutuo di classe A effettui un pagamento in surplus = 160 mutui effettuano pagamenti in surplus<br>1 versamento l'anno di media su una durata media di 30 mesi = 400 versamenti in surplus totali<br><br>Quest'ultimo risultato è stato trascurato dato il rapporto di incidenza minore dell'1% sul numero complessivo di pagamenti |
| Persone | 2300 | 85% di 2000 = 1700 mutui intestati ad una persona<br>15% di 2000 = 300 mutui intestati a due persone |
| Banca | 20 |  |
| MBS | 1 |  |
<br>
<br>
<br>
<br>
<br>
<br>
