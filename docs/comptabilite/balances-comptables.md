# Balances et états comptables



# 1. Vue d’ensemble

Le moteur comptable repose sur une séparation stricte entre :

1. **La vérité comptable**
   → `AccountingEntry` et `AccountingEntryLine`
2. **Les points de contrôle légaux**
   → `ClosingBalance`
3. **La projection cumulative optimisée**
   → `AccountBalanceChange`

Cette séparation permet :

- Une traçabilité complète des écritures
- Une clôture annuelle juridiquement fiable
- Des calculs de balances rapides et scalables
- Une reconstruction possible en cas d’incohérence



# 2. Les couches du moteur comptable

## 2.1 AccountingEntry / AccountingEntryLine (Source of Truth)

Les écritures validées (`status = validated`) constituent la seule réalité comptable active.

Caractéristiques :

- Une écriture validée n’est jamais modifiée.
- Toute correction passe par :
  - création d’une écriture inverse,
  - validation,
  - passage des deux écritures en `reversed`.
- Seules les écritures validées sont prises en compte dans les calculs comptables.

La vérité comptable est donc définie par :

```
SUM(AccountingEntryLine WHERE entry.status = 'validated')
```



## 2.2 ClosingBalance (Checkpoint légal)

Un historique figé est conservé via des **balances ** , qui sont des instantanés de la situation comptable à un moment donné.

- Les **Balances (annuelle ou périodique)**  sont calculées à une date donnée, elles fournissent un état figé des comptes et servent notamment à la validation des comptes lors d’une clôture de période ou d’exercice.

`ClosingBalance` représente :

- Un instantané figé à la fin d’un exercice
- Un point d’ancrage juridique
- Un point de reconstruction technique

Propriétés :

- Immutable après validation
- Correspond exactement aux écritures validées jusqu’à la date de clôture
- Sert de base pour les reports et les rebuild partiels



## 2.3 AccountBalanceChange (Projection cumulative)

`AccountBalanceChange` est une série temporelle cumulative.

Chaque ligne représente :

- L’état cumulé d’un compte
- À une date donnée
- Après application de toutes les écritures validées jusqu’à cette date

Structure logique :

```
(condo_id, account_id, date)
debit_balance
credit_balance
```

Il n’y a **qu’une seule ligne par compte et par date de mouvement**.



# 3. Logique de fonctionnement

## 3.1 Principe cumulatif

Pour un compte donné :

```
balance(t_n) = balance(t_n-1) + delta(t_n)
```

Où :

```
delta(t_n) = somme des lignes d’écriture validées à la date t_n
```

Si aucune écriture ne touche le compte à une date donnée, aucune ligne n’est créée.

La table reste sparse (clairsemée).



## 3.2 Mise à jour lors d’une validation

Lorsqu’une `AccountingEntry` passe en `validated` :

1. Les `AccountingEntryLine` sont parcourues.
2. Les lignes non encore postées (`is_posted = false`) sont agrégées par compte.
3. Pour chaque compte :
   - On récupère la balance précédente (< date).
   - On ajoute le delta.
   - On met à jour ou crée la ligne `AccountBalanceChange` à la date de l’écriture.
4. On ajuste toutes les lignes ultérieures en cas de backdating.
5. Les lignes sont marquées `is_posted = true`.

Important :

- Une ligne postée ne doit jamais être repostée.
- Une ligne postée ne doit jamais redevenir non postée.



## 3.3 Gestion des annulations

Annulation d’une écriture validée :

1. Création d’une écriture inverse.
2. Validation de cette écriture inverse.
3. Les deux écritures passent en `reversed`.

Effet :

- L’écriture inverse neutralise l’originale.
- Aucune suppression.
- Aucune modification de projection existante.
- Les lignes restent `is_posted = true`.

La projection reflète donc :

```
SUM(lignes postées)
```

Et non :

```
SUM(lignes WHERE status='validated')
```



# 4. Calcul des balances sur une période

Pour une plage `[date_from, date_to]` :

Pour chaque compte :

```
balance_end   = dernier AccountBalanceChange ≤ date_to
balance_start = dernier AccountBalanceChange < date_from
delta         = balance_end - balance_start
```

Cela permet :

- Balance à une date arbitraire
- Variation sur période
- États comptables (bilan, balance générale, etc.)

Aucune lecture directe des `AccountingEntryLine` n’est nécessaire.



# 5. Contraintes techniques

## 5.1 Indexation obligatoire

La table `AccountBalanceChange` doit être indexée sur :

```
(condo_id, account_id, date)
```

Cela garantit :

- Recherche rapide du dernier solde
- Range scan efficace
- Scalabilité



## 5.2 Unicité

L’unicité logique :

```
(condo_id, account_id, date)
```

est garantie par l’ORM.

La base ne porte qu’un index composite (pas une contrainte UNIQUE SQL).



## 5.3 Transactions

Toutes les mises à jour doivent être transactionnelles :

- Validation d’écriture
- Mise à jour projection
- Marquage `is_posted`

Sinon incohérence possible.



# 6. Risque d’erreur cumulative

Une erreur dans `AccountBalanceChange` se propage :

```
Si balance(t_k) est faux
→ balance(t_k+1) est faux
→ ...
```

Mais :

- La vérité comptable reste intacte.
- La projection est reconstructible.



# 7. Rebuild du moteur

## 7.1 Rebuild complet

1. Supprimer tous les `AccountBalanceChange`.
2. Rejouer toutes les écritures validées.



## 7.2 Rebuild partiel basé sur ClosingBalance (recommandé)

1. Trouver le dernier `ClosingBalance`.
2. Supprimer les projections postérieures.
3. Injecter la balance de clôture comme point d’ancrage.
4. Rejouer uniquement les écritures validées postérieures.

Optimisation majeure pour gros historiques.



# 8. Vérification d’intégrité

Deux niveaux :

### 8.1 Vérification à la clôture

Comparer :

```
ClosingBalance == AccountBalanceChange à la date de clôture
```

### 8.2 Vérification périodique

Recalcul partiel via SUM des lignes validées
et comparaison avec projection.



# 9. Invariants du système

Le système repose sur les invariants suivants :

1. Une écriture validée n’est jamais modifiée.
2. Toute correction passe par une écriture inverse.
3. Une ligne postée n’est jamais repostée.
4. Une ligne postée ne redevient jamais non postée.
5. ClosingBalance est immuable.
6. AccountBalanceChange est reconstructible.
7. Les écritures reversed n’ont plus d’effet actif.



