## Balances comptables


Une distinction est faite entre les **balances historiques** (périodiques) et la **balance instantanée** (courante).

- **Balances historiques (annuelle ou périodique)** : Calculées à une date donnée, elles fournissent un état figé des comptes et servent notamment à la validation des comptes lors d’une clôture de période ou d’exercice.
- **Balance courante (CurrentBalance)** : Mise à jour en temps réel, elle reflète l’état actuel des comptes à chaque écriture comptable.

Lorsqu’une écriture est validée :

- La **CurrentBalance** est mise à jour via les **CurrentBalanceLines** correspondant aux comptes affectés.
- Si aucune ligne de balance n’existe pour un compte donné, elle est automatiquement créée.

Les **account entries** suivent un processus transactionnel et passent par trois statuts :

1. **Pending** : En attente de validation.
2. **Validated** : Écriture finalisée et impactant la balance.
3. **Cancelled** : Écriture annulée avant validation.

Une fois une **account entry** validée, elle ne peut plus être annulée. Toute correction nécessite une contre-passation par une nouvelle écriture.
