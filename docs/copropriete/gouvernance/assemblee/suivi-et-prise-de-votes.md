# Suivi du déroulé d'une Assemblée et prises de votes





### 📘 Création automatique des votes à l’ouverture d’une résolution

Lorsqu’une **résolution** est ouverte et qu’elle **implique un vote**, le système procède automatiquement à la création et à la préparation des votes selon les règles suivantes :

#### 1. Création des votes

- Un **vote** (statut initial : `pending`) est créé **pour chaque propriété (ownership)** concernée par la résolution **et** dont le propriétaire est **présent ou représenté** à l’assemblée.
- Cette création se base sur la liste des **ownerships impliqués** dans le point de résolution (`involved_ownerships_ids`).

#### 2. Vérification des représentations

Pour chaque **ownership représenté**, le système vérifie :

- que le type de représentation (`representation_type`) est cohérent ;
- et, dans le cas d’une **représentation par procuration** (`proxy`), que le **mandat d’assemblée** associé (`assembly_mandate_id`) :
  - a un statut `validated`,
  - et est marqué comme `is_valid = true`.

Les ownerships représentés sans mandat valide sont **exclus de la création de vote**.

#### 3. Application des intentions de vote

Avant de finaliser le vote, le système recherche une **intention de vote existante** correspondant à la combinaison :

- `ownership_id` = même propriété,
- `assembly_item_id` = même résolution,
- et, le cas échéant, `assembly_mandate_id` identique si la représentation est de type `proxy`.

Si une intention valide est trouvée :

- les valeurs (`vote_value`, `assembly_item_choice_id`) sont reprises,
- et le vote est automatiquement **“casté”** (transition du statut `pending` → `casted`).

#### 4. Gestion des statuts de vote

Chaque vote possède un **statut** qui reflète son état :

- `pending` → le vote est enregistré mais non encore exprimé ;
- `casted` → le vote a été validé ou confirmé.

En cas de **re-vote**, les votes concernés sont remis au statut `pending`.
 Les **résultats de vote** ne sont visibles qu’une fois les votes passés au statut `casted`.

