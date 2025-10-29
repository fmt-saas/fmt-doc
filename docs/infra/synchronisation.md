# Synchronisation des données

## 1. Objectif général

Le système de **synchronisation** vise à harmoniser les données entre les instances locales (ex. syndics) et l'instance globale (FMT), tout en **préservant la responsabilité des données locales**.

👉 La position FMT :

> La responsabilité des données reste du ressort des **syndics**.
>  Le système facilite la mise à jour, mais **n’impose jamais** de modification automatique sur les champs sensibles.



## 2. Suivi des demandes de modification

### Entités principales

#### **UpdateRequest**

| Champ               | Description                             |
| ------------------- | --------------------------------------- |
| `id`                | Identifiant de la requête               |
| `object_class`      | Classe de l’objet concerné              |
| `instance_id`       | Identifiant de l’instance locale        |
| `managing_agent_id` | Référence du syndic / agent responsable |
| `request_date`      | Date de la demande                      |

#### **UpdateRequestLine**

| Champ               | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| `update_request_id` | Référence à `updateRequest`                                  |
| `object_field`      | Champ de l’objet concerné                                    |
| `object_id`         | Identifiant de l’objet                                       |
| `new_value`         | Nouvelle valeur proposée                                     |
| `old_value`         | Ancienne valeur (calculée)                                   |
| `status`            | `pending` / `approved` / `rejected`                          |
| `source_type`       | Type de source (locale, globale, etc.)                       |
| `source_origin`     | Origine de la donnée                                         |
| `source_date`       | Date de la donnée source                                     |
| `approval_user_id`  | Utilisateur ayant approuvé                                   |
| `approval_reason`   | Motif d’approbation (`unsupervised`, `verified`)             |
| `rejection_user_id` | Utilisateur ayant rejeté                                     |
| `rejection_reason`  | Motif de rejet (`conflict`, `incorrect_data`, `outdated_data`, `duplicate_request` |



## 3. Politiques de mise à jour

Les **UpdatePolicy** déterminent la sensibilité et le comportement de synchro **par entité et par champ**.

#### **SyncPolicy**

| Champ            | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| `name`           | (calc)                                                       |
| `object_class`   | Classe concernée (unique)                                    |
| `scope`          | Niveau de visibilité de la classe: `protected`, `private`    |
| `field_unique`   | Champ à utiliser pour déterminer si un objet est déjà présent ou non (pour assignation UUID) |
| `sync_direction` | Direction de la synchro : `ascending` (Local > Global) ou `descending` (Global > Local) |


| Scope           | Description                                                  | Comportement                                 |
| --------------- | ------------------------------------------------------------ | -------------------------------------------- |
| **`private`**   | Classe gérée exclusivement sur l'instance Globale (pas de modification possible par les instances Locales) | Synchronisation descendante seulement        |
| **`protected`** | Classe gérée sur l'instance Globale, mais pouvant faire l'objet de créations ou de modifications par les instances Locales. synchro | Synchro **supervisée** (via `UpdateRequest`) |
| **`public`**    | (Classes non synchronisées)                                  |                                              |

#### **SyncPolicyLine**

| Champ              | Description                                             |
| ------------------ | ------------------------------------------------------- |
| `update_policy_id` | Référence à `UpdatePolicy`                              |
| `object_field`     | Champ concerné (unique)                                 |
| `scope`            | Niveau de visibilité : `public`, `protected`, `private` |

| Scope           | Description                                                  | Comportement                                                 |
| --------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **`private`**   | Données strictement locales (ex. coordonnées personnelles, IBAN) | Non synchronisées                                            |
| **`protected`** | Données nécessitant supervision avant synchro                | Synchro **supervisée** (via `UpdateRequest`)                 |
| **`public`**    | Données considérées fiables, non sensibles                   | Synchro **automatique** (`UpdateRequest` avec `approval_reason` = `'unsupervised'`) |

> * Sur les instances locales, **tous les champs reçus sont considérés comme `protected`** par défaut (et nécessitent donc une validation manuelle).
> * Sur l'instance Globale, seuls les champs explicitement marqués comme `public` peuvent être synchronisés sans supervision.



## 4. Types de synchronisation

Dans tous les cas, les entités "Public", ne sont pas synchronisées (les éventuelles lignes sont sans effet).

Lors d'une synchronisation, quelle que soit la direction, pour une **entité protected** :

* tous les champs sont envoyés, à l'exception de ceux explicitement marqués comme "private"
* les champs "public" seront acceptés sans supervision par l'instance de destination (mais toujours dans le cadre d'une UpdateRequest, jamais appliquée automatiquement)

Lors d'une synchronisation, pour une **entité private** (en principe uniquement Global > Local):

* tous les champs sont envoyés, à l'exception de ceux explicitement marqués comme "private"
* l'instance de destination est automatiquement mise à jour sans supervision.

### 

### 🔼 Synchro ascendante (Local → Global)

Lorsqu’une instance locale propose une mise à jour :

- Les champs **private** ne remontent pas vers Global (ex. `phone`, `email`, `bank_account_iban` pour personnes physiques, sur base des UpdatePolicies).
- Les champs **unsupervised (public)** sont **acceptés automatiquement**.
- Les champs **supervised (protected)** nécessitent une **vérification** :
  - automatique (comparaison de sources sûres),
  - manuelle (validation par un utilisateur),
  - ou assistée (avec suggestion et préremplissage).



### 🔽 Synchro descendante (Global → Local)

- Les mises à jour descendantes pour les entités `private` **sont toujours appliquées automatiquement** (pas de validation/supervision).
- Les mises à jour descendantes pour les entités `protected` **ne sont jamais appliquées directement**: et ne se font que pour certains champs (il faut définir quelles entités) -> il faut définir une direction dans les Policies
- Elles apparaissent sous forme de **suggestion** dans l’instance locale.
- L’utilisateur local doit **valider manuellement** avant mise à jour effective.

#### Règles spécifiques :

| Scope           | Comportement                                |
| --------------- | ------------------------------------------- |
| **`private`**   | Jamais envoyées vers les instances locales  |
| **`public`**    | Transmises car considérées RGPD-compatibles |
| **`protected`** | Nécessitent validation manuelle locale      |

**Exemples de champs `public` transmis :**

- `first_name`
- `last_name`
- `birth_date` *(nécessaire même si RGPD)*
- `address`



## 5. Logique applicative : encodage et supervision

Lorsqu’un utilisateur encode ou modifie une donnée sur une instance Locale pour une classe `protected`:

- le système **propose la valeur connue au niveau Global**, si elle existe ;
- une **alerte** est affichée si la valeur saisie diffère du Global ;
- une **UpdateRequest** est créée pour suivi et validation éventuelle sur l'instance Globale.



## 6. Exemples de flux

### Exemple 1 – Champ public

Un champ `registration_date` (scope `public`) est mis à jour dans une instance locale.
 → Pas de synchro.

### Exemple 2 – Champ protégé

Un champ `address_street` (scope `protected`) est modifié.
 → Une `updateRequestLine` est envoyée vers l'instance Global avec `status = pending` 
 → Après vérification, un utilisateur Global valide (`approval_user_id`) ou rejette (`rejection_user_id`).

### Exemple 3 – Champ privé

Un champ `bank_account_iban` est modifié localement.
 → Non transmis vers Global (aucune synchro).



## 7. Rejets possibles

| Code                  | Signification                                 |
| --------------------- | --------------------------------------------- |
| `conflict`            | Conflit entre version locale et globale       |
| `incorrect_data`      | Données incohérentes ou erronées              |
| `outdated_data`       | Valeur basée sur une source ancienne          |
| `duplicate_request`   | Demande déjà enregistrée                      |
| `unauthorized_change` | Modification non autorisée selon la politique |



## Suivis



* Sur une base régulière un controller (cron) pourrait vérifier la synchronicité des valeurs entre une instance Locale et les valeurs correspondantes sur l'instance Globale 

