## workflow

Une facture d'achat suit le workflow standard pour les factures : `proforma`, `invoice`, `cancelled`

Il est possible d’enregistrer une facture en tant que pro forma (statut proforma) dans un premier temps, afin de compléter ou corriger les informations avant validation finale.

A la validation (passage de 'proforma' à 'invoice')

* Une vérification de la conformité est réalisée (total déclaré et la somme des lignes, +autres contraintes).
* On assigne un numéro de cachet : invoice number (distinction `supplier_invoice_number`)
* On génère les écritures écritures immédiates
* On planifie les écritures pour chaque début de période à venir

## Informations à renseigner

Lors de l'encodage, les informations suivantes doivent être complétées :

| Champ                 | Description                                                                                                                                 |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **Fournisseur**       | Identifié automatiquement sur base du numéro de TVA                                                                                         |
| **Date de facture**   | Date indiquée sur le document reçu                                                                                                          |
| **Numéro de facture** | Numéro du document transmis par le fournisseur                                                                                              |
| **VCS**               | Référence fournisseur (ex. n° client interne ou code de suivi fournisseur)                                                                  |
| **Période couverte**  | Facultative – utile si le fournisseur découpe par période ; champs : `date_from` (début) et `date_to` (fin), issus de `<cac:InvoicePeriod>` |
| **Date d’échéance**   | Champ `<cbc:PaymentDueDate>`, indiqué sur la facture                                                                                        |
| **Pièces jointes**    | Documents PDF, images ou annexes liées à la facture (`docs_ids`)                                                                            |
| **Numéro de cachet**  | Assigné automatiquement à la validation (statut = `invoice`) ; non modifiable après validation                                              |

## Découpage de la facture en lignes d’imputation (`InvoiceLine`)

Lors de l’encodage d’une facture d’achat, le montant total de la facture n’est pas utilisée comme référence : ce sont les lignes de détail qui font foi pour l’imputation comptable.

Il est possible de définir une série de **lignes d’imputation**, chaque ligne permettant d'assigner des montants à des **comptes de charges** spécifiques. Ce découpage ne doit pas nécessairement à correspondre aux lignes présentes sur la facture d'origine : une facture peut être répartie différemment en fonction des critères comptables de la copropriété.

Une suggestion automatique est proposée sur base de la reconnaissance OCR, mais elle doit être validée ou corrigée par le gestionnaire.

Chaque ligne est associée à plusieurs éléments :

- **Un compte de charge** (généralement de type `61xx` ou autre catégorie spécifique).
- **Une clé de répartition**, définissant la manière dont les montants doivent être affectés.
- **Un ratio PROP / LOC**, utilisé pour répartir la charge entre les copropriétaires (ou autres entités concernées).

Ces informations sont copiées de la configuration du compte, mais peuvent être ajustées manuellement pour tenir compte de particularités ou d’exception de gestion.

Une assignation auto (compte, clé, part Prop/Loc) peut être faite via la sélection d'une "nature de dépense".

Les lignes de factures sont modélisées avec l'entité `InvoiceLine`.

Contraintes :

* il ne peut y avoir qu'une seule ligne pour un même compte de charge (dans le cas contraire, on ne peut pas retrouver à quel ligne correspond une imputation comptable)

#### Utilisation du fonds de roulement

Lorsque ce n'est pas précisé autrement, les charges sont considérées comme des charges communes qui devront être réparties entre les copropriétaires sur base de clés de répartitions.

Dans les autres situations, la part du paiement imputée au fonds de roulement correspond à la différence entre le montant total de la facture, la part éventuellement couverte par le ou les fonds de réserve, et les éventuelles parties privatives.

Pour chaque utilisation de fonds, il faut préciser le compte de réserve 160X utilisé.
Sur base du fonds sélectionné, le compte de charge correspondant (libellé « Appels ») est utilisé, par exemple 680010.
(Les informations de compte comptable et de clé de répartition ne peuvent pas être modifiées ; le ratio PROP / LOC n’est pas pertinent dans ce contexte.)

#### Frais privatifs

Certaines dépenses peuvent être considérées comme frais privatifs, c’est-à-dire applicables uniquement à un copropriétaire ou un lot spécifique, et non réparties entre l’ensemble des copropriétaires.

Dans ce cas, l’imputation se fait obligatoirement sur le compte 643 – Frais privatifs.

Les frais privatifs sont exclus des répartitions collectives et doivent faire l’objet d’un suivi individuel pour refacturation ou régularisation ultérieure.

#### Utilisation de fonds de réserve

Une partie ou la totalité d'une facture peut être payée via l'utilisation d'un ou plusieurs fonds de réserve.

**Le fonds de réserve est toujours utilisé avec la même clé de répartition que celle utilisée pour son appel.**
Cela garantit la traçabilité et l’équité dans la répartition entre copropriétaires (La clé de répartition ne peut pas être modifiée lors de l’utilisation du fonds.)

### Distinction entre date de facture, date d'imputation et période d'imputation

On fait une distinction entre la date de la facture (date d’émission par le fournisseur) et la période à laquelle les prestations ou services facturés se rapportent.

Si le fournisseur a renseigné une "période de facturation", celle-ci est utilisée par défaut comme intervalle de dates. Dans tous le cas, l'imputation peut  toujours être modifiée pour utiliser un autre intervalle ou une autre date.

Comme date pour l'imputation comptable , on utilise :

* la date d'imputation choisie (date d'encodage de la facture par défaut)
* si un intervalle de dates est renseigné (`date_from` et `date_to`), c’est la première date de l’intervalle qui est retenue 

Note : Lorsqu’une facture est financée, en tout ou en partie, par un fonds de réserve, l’imputation correspondante est toujours enregistrée à une seule date, indépendamment de la période couverte par la facture.

### Comptes comptables liés

Lors de la création d’un fonds de réserve, trois comptes comptables sont générés automatiquement, tous liés à la **même clé de répartition** (qui ne peut être modifiée, afin de garantir la cohérence entre appel et utilisation):

1. `160xxxx` – **Fonds de réserve** (passif)
   
   > Compte principal de stockage du fonds

2. `68160xx0` – **Appels de fonds de réserve**
   
   > Enregistrement des montants appelés auprès des copropriétaires

3. `68160xx1` – **Utilisation (consommation) du fonds de réserve**
   
   > Compte technique servant à enregistrer la sortie du fonds lors de son usage effectif

## Paiement

Il y a 3 méthodes de paiement possibles: 
a) par "domiciliation" (cette info doit être dans le contrat et est, en principe, reprise sur la facture d'achat)
b) par banque ("prélèvement direct") -> création SEPA
c) en utilisant un fonds de réserve -> création SEPA (compte épargne) 

* il est possible d'utiliser plusieurs fonds de réserve
* il est possible d'utiliser uniquement un fonds de réserve (pas de paiement via compte courant)

=> il faut deux indications "refuser la facture", "payer par domiciliation" (dans les deux cas, il faut empêcher de générer un SEPA) [on ne peut pas "ne pas payer" s'il y a une domiciliation]

Si domiciliation : pas de création de SEPA correspondante (pas d'implication sur l'utilisation ou non de fonds de réserve)
proposition (pas auto) de SEPA de transfert (épargne / à vue) uniquement si les fonds sont suffisants

!! ce n'est pas parce qu'une facture est encodée qu'on la paie
"ne pas payer" : ne pas générer le SEPA

possibilité de payer en plusieurs fois (Funding)

écran distinct pour les paiement (multi-factures), avec assignation des montants payés

### Utilisation du fonds de roulement

| Libellé                                  | Débit                                                                        | Crédit                             |
| ---------------------------------------- | ---------------------------------------------------------------------------- | ---------------------------------- |
| Paiement via le compte courant           | 440000 - Fournisseur : 1.000 €                                               | 550000 - Banque courant : 1.000 €  |
| Aucun mouvement direct sur le compte 100 | *Le compte 100 est affecté en fin d'exercice selon l’excédent ou le déficit* | *Pas d’écriture comptable directe* |

Rappel: le fonds de roulement (100) est un passif qui ne peut être alimenté que par des participations des copropriétaires (comptes copropriétaires) et n'est jamais directement utilisé (c'est le compte bancaire qui l'est).

### Utilisation de fonds de réserve

| Libellé                         | Débit                                  | Crédit                           |
| ------------------------------- | -------------------------------------- | -------------------------------- |
| Utilisation du fonds de réserve | 68160xx1 – Utilisation du fonds : 500€ |                                  |
| Affectation du fonds de réserve |                                        | 160xx – Fonds de réserve : 500 € |



## Informations complémentaires



Certaines informations additionnelles permettent de paramétrer le comportement du logiciel



* Paiement par domiciliation : si coché au niveau de la facture de vente, le paiement ne doit pas être fait à la main, l'information sera répercutée sur le Funding correspondant, et l'ordre de paiement (SEPA) ne pourra pas être généré (un extrait bancaire avec le mouvement sera reçu).
  
  


