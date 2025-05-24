
## Ecritures d'imputation

Lors de la **validation d’une facture d’achat**, une **écriture comptable unique** est automatiquement générée dans le journal concerné.
 Cette écriture peut comporter **plusieurs lignes**, en fonction des imputations définies (charges, reports, réserves...).

Les **libellés** des lignes tiennent compte des **périodes couvertes** par la facture, ce qui permet d’assurer une traçabilité fine dans le temps.


### Encodage de la facture

Lors de l’enregistrement d’une facture d'achat, une ligne d’imputation est créée pour le compte fournisseur (compte comptable associé au fournisseur).

Cette ligne est toujours présente, quelles que soient les opérations complémentaires (charges à reporter, utilisation d’un fonds de réserve, ou affectations en frais privatifs).

| Date       | Pièce              | Compte             | Libellé                           | Débit | Crédit |
| ---------- | ------------------ | ------------------ | --------------------------------- | ----- | ------ |
| 01/01/2025 | ACH 0041-2025-0001 | 440 - Fournisseurs | Prime du 01/01/2025 au 31/12/2025 |       | 2000   |


### Utilisation du fonds de roulement 

Lorsque les lignes de la facture **ne sont pas des frais privatifs**, chaque ligne est imputée en débitant le compte de charge correspondant (ex. 61xx), selon sa nature.


| Date       | Pièce              | Compte             | Libellé                           | Débit | Crédit |
| ---------- | ------------------ | ------------------ | --------------------------------- | ----- | ------ |
| 01/01/2025 | ACH 0041-2025-0001 | 611000 - Assurance | Prime du 01/01/2025 au 31/12/2025 | 2000  |        |


### Répartition sur plusieurs périodes

Lors de son enregistrement, si une facture d'achat couvre plusieurs périodes ou exercices (ex. assurance annuelle, contrats de maintenance…), pour respecter le principe de rattachement des charges, on répartit la charge dans le temps (même si la facture est payée en une seule fois).

Pour gérer cette situation, on utilise des "écritures planifiées" pour anticiper les écritures sur les périodes ultérieures.

Exemple d’une facture de **2 000 €** pour une assurance couvrant du **01/01/2025 au 31/12/2025** :


| Date       | Pièce              | Compte        | Libellé                                 | Débit                      | Crédit |
|------------|--------------------|---------------|-----------------------------------------|-----------------------------------------|---------|
| 01/01/2025 | ACH 0041-2025-0001 | 614 - Assurance   | Prime du 01/01/2025 au 31/03/2025   |                                         | 500     |
| 01/01/2025 | ACH 0041-2025-0001 | 614 - Assurance   | Prime du 01/04/2025 au 30/06/2025   |  | 500  |
| 01/01/2025 | ACH 0041-2025-0001 | 614 - Assurance | Prime du 01/04/2025 au 30/06/2025 |  | 500 |
| 01/01/2025 | ACH 0041-2025-0001 | 49 - Charges à reporter | Prime du 01/07/2025 au 30/09/2025 | 500 |      |
| 01/01/2025 | ACH 0041-2025-0001 | 49 - Charges à reporter | Prime du 01/10/2025 au 31/12/2025 | 500 |      |
| 01/01/2025 | ACH 0041-2025-0001 | 49 - Charges à reporter | Prime du 01/10/2025 au 31/12/2025 | 500 |  |


**écriture planifiées:**

| Date       | Pièce              | Compte        | Libellé                                 | Débit                      | Crédit |
|------------|--------------------|---------------|-----------------------------------------|-----------------------------------------|---------|
| 01/04/2025 | ACH 0041-2025-0001 | 49 - Charges à reporter | Prime du 01/04/2025 au 30/06/2025 |                                   | 500     |
| 01/04/2025 | ACH 0041-2025-0001 | 614 - Assurance   | Prime du 01/04/2025 au 30/06/2025   | 500 |      |


| Date       | Pièce              | Compte        | Libellé                                 | Débit                      | Crédit |
|------------|--------------------|---------------|-----------------------------------------|-----------------------------------------|---------|
| 01/07/2025 | ACH 0041-2025-0001 | 49 - Charges à reporter | Prime du 01/07/2025 au 30/09/2025 |                                   | 500     |
| 01/07/2025 | ACH 0041-2025-0001 | 614 - Assurance   | Prime du 01/07/2025 au 30/09/2025   | 500 |      |

| Date       | Pièce              | Compte        | Libellé                                 | Débit                      | Crédit |
|------------|--------------------|---------------|-----------------------------------------|-----------------------------------------|---------|
| 01/10/2025 | ACH 0041-2025-0001 | 49 - Charges à reporter | Prime du 01/10/2025 au 31/12/2025 |                                   | 500     |
| 01/10/2025 | ACH 0041-2025-0001 | 614 - Assurance   | Prime du 01/10/2025 au 31/12/2025   | 500 |      |

Note : en cas d'intersection partielle entre l'intervalle de dates choisi et les dates des périodes concernés, les montants assignés à chaque période sont proratisés sur base du nombre de jours concernés au sein de chaque période d'exercice.


#### Écritures prévisionnelles / écritures planifiées

Les écritures planifiées sont similaires à des écritures comptables mais restent hors comptabilité (elles ne sont pas directement visibles, ni reprises dans la balance).
Au moment de la création de la facture on génère les écritures planifiées (liées à la fois à une facture, à une copropriété et à une date).

* Les écriture planifiées ('planned') sont des éléments "système" : elles font partie de la logique système et ne peuvent pas être validées ou supprimées manuellement
* En cas d'annulation d'une pièce comptable, elles doivent être supprimées (en les détachant du invoice_id et en les supprimant)



### Utilisation de fonds de réserve

Lorsqu’une facture d’achat est financée, en tout ou en partie, par un fonds de réserve, une ou plusieurs lignes spécifiques sont ajoutées à l’écriture comptable pour en refléter l'utilisation. Cette imputation ne fait pas l’objet d’une répartition périodique: le montant imputé au fonds de réserve est enregistré **à une seule date**, qui correspond à la validation de la facture ou à la décision d’utilisation du fonds.

L’écriture comptable suit le schéma suivant :

| Compte                            | Débit | Crédit | Rôle                                       |
| --------------------------------- | ----- | ------ | ------------------------------------------ |
| `68160xx1 – Utilisation du fonds` | 500   |        | Représente la charge financée par le fonds |
| `160xx – Fonds de réserve`        |       | 500    | Diminution du passif lié au fonds          |

Cette écriture s’ajoute à celles liées aux charges (`61xx`), reports (`49`), et dettes fournisseurs (`440`) de la facture.

- La **clé de répartition** utilisée pour le fonds est **identique** à celle définie lors de l’appel initial du fonds (non modifiable).
- L’imputation au fonds ne dépend **ni de la date de facture**, ni de la période de prestation : elle est liée uniquement à la **date de validation**.
- L'utilisation du fonds n’est **pas répartie** dans les périodes suivantes : elle est **comptabilisée en une fois**.


| Libellé                                                   | Débit                              | Crédit                                  |
| --------------------------------------------------------- | ---------------------------------- | --------------------------------------- |
| Réception de la facture (ex. travaux votés : toiture)     | 672000 - Travaux toiture : 5.000 € | 440001 - Fournisseur : 5.000 €          |
| Paiement via le compte bancaire dédié au fonds de réserve | 440001 - Fournisseur : 5.000 €     | 550001 - Banque fonds réserve : 5.000 € |
| Enregistrement de la baisse du fonds de réserve (clôture) | 681601 - Travaux toiture : 5.000 € | 160001 - Fonds de réserve : 5.000 €     |

Note : Les factures sont toujours payées par le compte courant de la copropriété. Le syndic fait un transfert du compte épargne vers le compte courant. Cette double opération  pourrait être automatisée lors d'un paiement via un fonds de réserve (avec la création du SEPA et l'OD correspondante du compte épargne [associé au fonds de réserve] vers le compte courant).


### Frais privatifs

Lorsqu’une facture d’achat (ou une ou plusieurs de ses lignes) correspond à des **frais privatifs**, le montant concerné est refacturé à un ou plusieurs copropriétaires (ces frais ne sont pas répartis via une clé de répartition).

Deux approches sont possibles pour le traitement comptable de ces frais :

#### 1. Intégration différée via le décompte de charge

Les frais privatifs sont **encodés comme charges privatives**, mais **ne seront refacturés qu’au moment du décompte**.

- Aucun produit n’est généré immédiatement.
- La refacturation est effectuée dans le cadre du **décompte de charge**, générant les écritures associées.


#### 2. Refacturation immédiate (hors décompte de charge)

Permet de **refacturer directement les frais au copropriétaire concerné**, sans attendre la clôture d’une période comptable.

- Les frais **ne seront pas repris dans le décompte de charges**.
- Une écriture supplémentaire est générée dans les écritures de la facture d'achat.


Écritures toujours générées :

| Compte                   | Débit | Crédit | Description                           |
| ------------------------ | ----- | ------ | ------------------------------------- |
| 643xxx – Frais privatifs | x €   |        | Enregistrement de la charge privative |


Écritures supplémentaires avec "**refacturation immédiate des frais privatifs**":

| Compte                   | Débit | Crédit | Description                         |
| ------------------------ | ----- | ------ | ----------------------------------- |
| 4101xx – Copropriétaire  | x €   |        | Refacturation au copropriétaire     |
| 643xxx – Frais privatifs |       | x €    | Contrepassation du compte de charge |


### Arrondis

Lors de la répartition des charges entre les copropriétaires, de légers écarts peuvent apparaître en raison de l’arrondi des montants (au centime près). Ces écarts sont automatiquement compensés via un **compte dédié**, afin de garantir que les écritures restent équilibrées.

- La **somme des montants répartis** aux copropriétaires peut ne pas correspondre exactement au **montant total facturé** (écart de 0,01 € à quelques centimes).
- Pour assurer l’équilibre, cette différence est passée sur un compte d’ajustement.


#### Compte utilisé

- Compte 4991 – Écarts d’arrondi (`rounding_adjustment`)
- Ce compte est :
  - **Débité** si la répartition est **inférieure** au total facturé.
  - **Crédité** si la répartition est **supérieure** au total facturé.


#### Écriture comptable

L’écriture est générée **au moment de la clôture de période**, en complément des écritures principales du décompte :

| Compte                  | Débit     | Crédit    | Description                                   |
|-------------------------|-----------|-----------|-----------------------------------------------|
| 4991 – Écarts d’arrondi | x €       |           | Si la répartition est inférieure au total     |
| 4991 – Écarts d’arrondi |           | x €       | Si la répartition est supérieure au total     |


## Ecritures de clôture de période

A la clôture d'une période, des écritures sont générées pour transférer les charges des comptes de charge vers les comptes des copropriétaires, et permettre de : 

- Constater la consommation éventuelle de **fonds de réserve**
- Affecter les charges **réelles** de la période aux copropriétaires
- Conserver une trace des **frais privatifs**
- S'il s'agit de la dernière période : préparer l'exercice suivant en soldant les comptes temporaires liés aux provisions, aux charges à reporter, etc.


### Ecritures liées au décompte de charges

La validation du décompte correspond à la clôture d'une période (il n'est plus possible d'ajouter des charges à la période après cette étape).



Au débit : 

* les comptes propriétaires, selon ce qui est déterminé dans le décompte de charges

Au crédit : 

* les frais privatifs (s'ils ont déjà été mis sur le compte proprio, ils n'apparaissent pas dans le décompte)
* utilisation de fonds de réserve
* charges communes


#### Exemple


| Compte                      | Débit | Crédit | Description                                           |
| --------------------------- | ----- | ------ | ----------------------------------------------------- |
| `410xxx` – Copropriétaire   | X €   |        | Créance sur le copropriétaire (charge à lui facturer) |
| `611xxx` – Charges communes |       | Y €    | Extourne partielle ou totale des charges réparties    |
| `643xxx` – Frais privatifs  |       | Z €    | Pour les charges privatives                           |
| `681600x1` – Fonds utilisés |       | W €    | Si une part a été couverte par un fonds de réserve    |

Pour plus de lisibilité, une écriture distincte est réalisée par copropriétaire.


### Autres écritures de clôture


#### Charges à reporter 


Les écritures de charges à reporter sont planifiées au moment de l'encodage d'une facture d'achat (uniquement lorsqu'il y a une répartition sur plusieurs périodes), et sont générées au premier jour de la période concernée.



#### Utilisation des fonds de réserve

Les écritures liées aux dépenses couvertes par des fonds de réserve sont faites directement à la validation d'une facture d'achat.



#### Arrondi

Le solde d'arrondi ne représente que de quelques cents à quelques euros et est uniquement apuré en fin d'exercice comptable (annuel).



## Écritures d'ouverture de période

Il n'y a pas d'opération formelle d'ouverture de période : une période est toujours imputable tant qu'elle n'est pas clôturée.

Cependant, des opérations automatiques peuvent être planifiée pour le premier jour d'une période. C'est le cas, par exemple, des écritures comptables planifiées ('planned'), générées lors de la répartition d'une facture d'achat sur plusieurs périodes.



**Récap - 2 cas particuliers pour les accounting entries :**

1) écritures de report temporaires ('is_temp' - sont prises en compte dans la balance, mais pouvoir être supprimées)
2) écritures en attente d'ouverture de période ('planned' - ne sont pas prises en compte dans la balance, mais ne peuvent pas être supprimées)



A chaque ouverture de période comptable (passage de période), on peut identifier les écritures nécessaires (sur base de la date et de leur status "planned").