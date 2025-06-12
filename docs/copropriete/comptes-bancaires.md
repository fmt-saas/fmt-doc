# Comptes bancaires

Les comptes bancaires sont associés aux identités.


Par défaut, une identité permet de préciser un compte bancaire principal. Mais une identité peut être associée à un nombre non limité de comptes bancaires supplémentaires.

Pour faciliter l'encodage, il y a une synchro entre la liste de compte et le compte renseigné dans l'identité : de sorte que le compte de l'identité est toujours présent également dans la liste.


La clé d'unicité des `BankAccount` est le numéro IBAN (il ne peut pas y avoir deux comptes avec le même IBAN / deux Identity ne peuvent jamais avoir un compte identique).

Les comptes bancaires référencés dans le cadre des copropriétés sont des entités spécifiques :

* **CondominiumBankAccount** : associe une copropriété (`condo_id`) et un compte comptable du PCMN de l'ACP
* **SuppliershipBankAccount** : associe un fournisseur (`Suppliership`) et un compte bancaire spécifique (le compte bancaire à utiliser est susceptible de changer en fonction du type de contrat ou selon le compte bancaire détenu par la copropriété - pour minimiser les frais et les délais). Cette entité utilise une autre table, synchronisée avec les compes ciblés.

Quand on ajoute un fournisseur à une copropriété, par défaut, on ajoute le compte bancaire principal du fournisseur (`is_primary`) dans les `SuppliershipBankAccount`.



## Extraits bancaires (`BankStatement`)

Un relevé bancaire est considéré comme une pièce comptable (mais n'en est pas réelelment une) et suit un process similaire à l’import et au traitement des autres types de documents.


### Import des extraits

Les relevés bancaires peuvent provenir :

- d’un **relevé unique** lié à un seul compte,
- ou d’un **relevé global** (ex. fichier ISABEL) contenant plusieurs extraits, chacun lié à un compte distinct.

L’import se fait en deux étapes :

1. Création d’un objet `BankStatementImport` pour encapsuler l’ensemble des extraits.
2. Pour chaque extrait détecté :
   - Un objet `BankStatement` est généré,
   - Il est associé à un `DocumentProcess`,
   - Un fichier virtuel (XLSX) est généré pour la traçabilité.


### Traitement des lignes d’extrait (`BankStatementLine`)

Chaque `BankStatement` contient une ou plusieurs lignes représentant les opérations bancaires (entrées/sorties de fonds). Chaque ligne peut être marquée comme :

- **ignorée** (non pertinente),
- **à rembourser** (ex. erreur, trop-perçu),
- **réconciliée** (traitée).

#### Réconciliation

Une ligne est considérée comme **réconciliée** lorsque :

- Elle est associée à un ou plusieurs **paiements** (objets `Payment`),
- Ces paiements couvrent **exactement** le montant de la ligne d’extrait (versement réel),
- Chaque paiement est lié à un ou plusieurs **financements** (`Funding`) représentant des montants attendus.

Les paiements créés automatiquement sont initialement en **statut "brouillon"** (`proforma`).


### Actions possibles

#### Réconciliation manuelle ou automatique

L'action `reconcile` sur un `BankStatement` tente :

- Une **réconciliation automatique** ligne par ligne (si possible),
- Puis déclenche l’**enregistrement comptable** de l’extrait s’il est totalement réconcilié.

#### Enregistrement comptable (post)

L’action `post` d’un `BankStatement` :

- Est uniquement possible si **toutes les lignes** sont réconciliées,
- **Valide** les paiements associés (changement d’état),
- **Génère les écritures comptables** correspondantes à partir des paiements.



### Impact sur les financements (`Funding`)

Lorsqu’un **paiement est publié** :

- Le financement (`Funding`) auquel il est lié est **mis à jour** (changement d’état éventuel),
- Une **tentative d’enregistrement automatique** du financement est lancée,
  - Ce processus vise à **générer les écritures comptables** liées à la pièce d’origine du financement (facture, échéancier, etc.).



## Transfert bancaire interne (`MoneyTransfer`)

Le transfert de fonds entre deux **comptes bancaires** d’une copropriété est géré via l’objet `MoneyTransfer`. Il s’agit d’un **type spécialisé d’`operation diverse` (`MiscOperation`)**, conçu pour modéliser les **mouvements internes** entre comptes bancaires de la même copropriété, et qui implique la création d'écritures comptables à deux moments : 

1) lors de la création de la demande du transfert (et de l'envoi du SEPA correspondant)
2) lors de la réception de l'extrait bancaire qui acte le transfert au niveau de la banque

Un `MoneyTransfer` associe :

* un **compte source** (`bank_account_id`)
* un **compte de destination** (`counterpart_bank_account_id`)
* une **copropriété** (`condo_id`)
* un **montant** (`amount`)
* une **date comptable** (`posting_date`), généralement la date du jour



### Validation d'un transfert 

Un transfert n'est valide (et autorisé) que s'il y a assez d'argent sur le compte d'origine.
Le montant disponible est identifié sur base de la balance courante du compte comptable associé (montant au débit).


### Déroulement comptable en deux temps

#### **1. Demande de transfert (ordre de virement)**

Lorsqu’un transfert est initié (manuellement ou via SEPA), une première écriture comptable est générée :

* le **compte source est crédité**
* un **compte transitoire `58xxxx` (bank\_transfer)** est débité

```plaintext
DEBIT   58xxxx - Compte transitoire "Virements internes"
CREDIT  512xxx - Compte bancaire source
```

> Cela permet de réduire immédiatement la disponibilité du compte source, même si le virement n’est pas encore effectif. Le montant est alors considéré comme "en transit".



#### **2. Réception du virement (encodage de l’extrait)**

Quand le virement est visible sur l’extrait du compte de destination, une seconde écriture est générée :

* le **compte de destination est débité**
* le **compte de virement interne est crédité**

```plaintext
DEBIT   512yyy - Compte bancaire destination
CREDIT  58xxxx - Compte transitoire "Virements internes"
```

> L’opération est alors **soldée**, le virement est visible des deux côtés.



###  Réconciliation et suivi

Le suivi des opérations de versement est réalisé avec des financements (Funding).

Les deux `Funding` générées (demande et réception) peuvent être liées entre elles via un champ comme :

* `mirror_misc_operation_id`
* `transfer_pair_id`
* ou via un objet `MoneyTransfer` central qui référence les deux.

Cela permet de suivre l’état de complétion (`is_complete`) et de vérifier que l'extrait bancaire a bien été comptabilisé.



``` Bank Statement > Bank Statement Line > Funding > {accounting document} > AccountingEntry```

accounting document : 
* misc operation (OD)
* purchase invoice
* expense statement
* fund request


### Lien entre`Funding` et export SEPA

Un `MoneyTransfer` peut être **lié à un `Funding`** lorsqu’il représente :

* une **demande de paiement SEPA** (ex. virement vers un autre compte)
* une **instruction métier validée** (ex. mouvement autorisé par l’AG)

Dans ce cas :

* le `Funding` permet de déclencher l’export SEPA (pain.001)
* l’état du `Funding` évolue au fil du traitement (créé, exporté, exécuté)
* l’objet `MoneyTransfer` devient la **traduction comptable du `Funding`**



### Calcul du solde disponible d’un compte bancaire

Pour éviter les erreurs (ex. : réinitier un transfert alors que des fonds sont déjà engagés), le solde disponible d’un compte est calculé comme suit :

```php
availableBalance = current_account_balance
                 - sum(pending outgoing Fundings)
                 + sum(pending incoming Fundings)
```

Ce champ calculé (`available_balance`) permet de :

* tenir compte du solde réel (`AccountBalance`)
* déduire les Fundings en attente d'exécution
* informer l'utilisateur du montant effectivement mobilisable



### Règles de validation avant transfert

Avant validation (`posted`), les conditions suivantes sont vérifiées :

* les deux comptes bancaires doivent appartenir à la même copropriété
* le montant doit être > 0
* la date comptable doit être définie
* le compte source doit disposer d’un solde suffisant (via `CurrentBalanceLine`)
* un compte comptable de type `bank_transfer` doit être défini



