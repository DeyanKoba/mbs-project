# Progetto per l'esame di Basi di Dati - "Mortgage Backed Securities"

Università degli studi di Trieste - Corso di Laurea in Ingegneria Elettronica ed Informatica - Deyan Koba
<br>
### Introduzione

Una banca d'investimento richiede la realizzazione di un database per gestire i propri Mortgage Backed Securities (MBS).
Un MBS, in breve, è un insieme di mutui raccolti in un "pacchetto", quest'ultimo viene successivamente suddiviso in quote con diverso ROI (Return On Investment) in base al rischio e vendute al pubblico come forma d'investimento. In tal modo le banche rientrano "immediatamente" del capitale concesso ed in pratica è l'investitore finale a fornire il capitale per finanziare i mutui.
<br>
> [Mortgage Backed Security Definition](https://www.investopedia.com/terms/m/mbs.asp)

<br>
La banca d'investimento acquista in blocco dalle centinaia alle migliaia di mutui rilasciati da altre banche commerciali, ad ogni mutuo viene assegnata una valutazione di rischio che potrà essere 'A', 'B' oppure 'C';

* 'A' indica un mutuo per il quale si suppone un basso rischio di insolvenza
* 'B' indica un rischio medio
* 'C' indica un rischio alto

Il fattore di rischio è calcolato su 4 parametri con diverse incidenze:

1. Rapporto tra rata mensile ed entrate mensili dei soggetti intestatari del mutuo, incidenza del 35%
2. Rapporto tra i giorni medi di ritardo nei pagamenti ed il mese commerciale, incidenza del 45%
3. Rapporto tra versamenti in surplus ed il capitale concesso, incidenza del 10%
4. Rapporto tra rate potenzialmente non incassabili dovute all'età del soggetto ed il capitale concesso, incidenza del 10%

<br>
Il fattore di rischio è quindi calcolato nel seguente modo:
**(35% \* *risultato al punto 1*) + (45% \* *risultato al punto 2*) + (10% \* *risultato al punto 3*) + (10% \* *risultato al punto 4*)**

Ogni MBS contiene in media dai 1000 ai 3000 mutui ed in una situazione normale è composto nel seguente modo:

* attorno all'80% da mutui di classe A
* il restante da mutui di classe B e C

<br>
<br>
