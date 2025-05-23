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



### Écritures d'ouverture de période

Il n'y a pas d'opération formelle d'ouverture de période : une période est toujours imputable tant qu'elle n'est pas clôturée.

Cependant, des opérations automatiques peuvent être planifiée pour le premier jour d'une période. C'est le cas, par exemple, des écritures comptables planifiées ('planned'), générées lors de la répartition d'une facture d'achat sur plusieurs périodes.



**Récap - 2 cas particuliers pour les accounting entries :**

1) écritures de report temporaires ('is_temp' - sont prises en compte dans la balance, mais pouvoir être supprimées)
2) écritures en attente d'ouverture de période ('planned' - ne sont pas prises en compte dans la balance, mais ne peuvent pas être supprimées)



A chaque ouverture de période comptable (passage de période), on peut identifier les écritures nécessaires (sur base de la date et de leur status "planned").
