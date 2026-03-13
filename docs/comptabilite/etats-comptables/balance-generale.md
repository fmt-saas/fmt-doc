# Balance générale

La **balance générale** est un état comptable qui présente l’ensemble des mouvements enregistrés dans les comptes d’une comptabilité sur une période donnée. Elle permet de vérifier la cohérence des écritures comptables et d’analyser les mouvements et soldes des comptes.

Dans sa forme la plus simple, la balance liste **toutes les lignes d’écriture comptable** (`AccountingEntryLine`) enregistrées dans le système. Chaque ligne correspond à un mouvement au débit ou au crédit d’un compte comptable.

La balance générale peut être filtrée selon plusieurs critères, notamment :

- une **période comptable** (date de début et date de fin),
- un **exercice comptable** (`FiscalYear`),
- un **journal** (`Journal`),
- un **compte comptable** (`Account`),
- ou encore des catégories spécifiques comme les **fournisseurs** ou les **copropriétaires**.

Seules les écritures **validées** (`status = validated`) sont prises en compte, afin de garantir que la balance reflète uniquement des opérations comptables confirmées.

## Période et exercice comptable

La consultation de la balance repose principalement sur une **période définie par une date de début et une date de fin**.

Un **exercice comptable** peut également être sélectionné afin de faciliter la navigation dans les données. Toutefois, le calcul de la balance s’appuie **uniquement sur les dates de la période demandée**, indépendamment de l’exercice sélectionné.

L’exercice sert donc principalement :

- à proposer une **période par défaut**,
- à identifier le **contexte comptable** dans lequel s’inscrit la consultation.

Par défaut, l’exercice sélectionné est **l’exercice en cours**.

Lorsque la date de début ne correspond pas au début d’un exercice, le système détermine automatiquement le **solde initial** à partir des informations disponibles dans les périodes précédentes.

## Détermination des comptes inclus

Afin d’obtenir une balance correcte tout en limitant le volume de données à traiter, les comptes inclus dans la balance sont déterminés à partir de plusieurs sources :

- les comptes présents dans les **soldes d’ouverture** (`OpeningBalanceLine`) de l’exercice,
- les comptes ayant subi une **variation de solde** (`AccountBalanceChange`) entre le début de l’exercice et la date de début demandée,
- les comptes présentant **au moins un mouvement comptable** (`AccountingEntryLine`) dans la période sélectionnée.

Cette approche garantit que les comptes possédant un **solde initial mais aucun mouvement dans la période** sont correctement pris en compte.

## Calcul du solde initial

Lorsque la période consultée ne commence pas au début d’un exercice, la balance doit tenir compte des opérations enregistrées avant la période afin de déterminer le **solde initial** des comptes.

Ce solde est déterminé selon l’ordre de priorité suivant :

1. le **dernier changement de solde enregistré** (`AccountBalanceChange`) avant la date de début,
2. le **solde d’ouverture de l’exercice** (`OpeningBalanceLine`),
3. à défaut, un **solde nul**.

Cette logique reproduit le mécanisme comptable de **report des soldes** entre périodes.

Le système tient également compte du fait qu’il peut **ne pas exister d’exercice précédent**.

## Structure des données

Chaque ligne de la balance correspond à une **ligne d’écriture comptable** et contient notamment les informations suivantes :

- **Date de l’écriture** (`entry_date`)
  Date à laquelle l’opération est enregistrée dans la comptabilité.

- **Compte comptable** (`account_id`)
  Compte impacté par la ligne d’écriture.

- **Journal** (`journal_id`)
  Journal dans lequel l’écriture comptable a été enregistrée.

- **Écriture comptable** (`accounting_entry_id`)
  Référence de l’écriture dont la ligne fait partie.

- **Description** (`description`)
  Texte décrivant l’opération.

- **Débit** (`debit`)
  Montant débité sur le compte.

- **Crédit** (`credit`)
  Montant crédité sur le compte.

- **Solde de la ligne** (`balance`)
  Différence entre le débit et le crédit :

  ```
  balance = debit − credit
  ```

Ce solde permet de déterminer l’impact de la ligne sur le compte :

- un **solde positif** correspond à un mouvement au **débit**,
- un **solde négatif** correspond à un mouvement au **crédit**.

## Objectif de la balance générale

La balance générale remplit plusieurs fonctions essentielles :

### Vérification comptable

Elle permet de vérifier que la comptabilité est équilibrée.
Dans une comptabilité en partie double, la somme totale des débits doit être égale à la somme totale des crédits.

### Analyse des comptes

Elle permet d’analyser :

- les mouvements sur chaque compte,
- la nature des opérations comptables,
- les montants enregistrés sur une période donnée.

### Base de production des états comptables

La balance constitue également la **base de travail pour produire les états financiers**, notamment :

- le **grand livre**,
- le **bilan**,
- le **compte de résultats**,
- ou encore les **décomptes analytiques** dans certains contextes (par exemple en copropriété).

## Balance détaillée et balance agrégée

La présentation de la balance peut être soit **détaillée**, c’est-à-dire une liste de toutes les lignes d’écriture.

soit **agrégée par compte**, en calculant :

- le total des débits par compte,
- le total des crédits par compte,
- le solde du compte.

Dans la version détaillée, les lignes sont généralement **triées par compte, puis par date d’écriture**, afin de faciliter la lecture des mouvements comptables et l’analyse chronologique des opérations.

