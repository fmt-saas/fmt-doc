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

ecran distinct pour les paiement (multi-factures), avec assignation des montants payés



### Utilisation du fonds de roulement

| Libellé                     | Débit       | Crédit          |
|--|--|--|
| Paiement via le compte courant           | 440000 - Fournisseur : 1.000 €                               | 550000 - Banque courant : 1.000 €  |
| Aucun mouvement direct sur le compte 100 | *Le compte 100 est affecté en fin d'exercice selon l’excédent ou le déficit* | *Pas d’écriture comptable directe* |

Rappel: le fonds de roulement (100) est un passif qui ne peut être alimenté que par des participations des copropriétaires (comptes copropriétaires) et n'est jamais directement utilisé (c'est le compte bancaire qui l'est).


### Utilisation de fonds de réserve

| Libellé                         | Débit                                  | Crédit                           |
| ------------------------------- | -------------------------------------- | -------------------------------- |
| Utilisation du fonds de réserve | 68160xx1 – Utilisation du fonds : 500€ |                                  |
| Affectation du fonds de réserve |                                        | 160xx – Fonds de réserve : 500 € |
