## Suivis de paiement


### Funding

Un objet `Funding` représente un **flux de trésorerie attendu ou initié**, dans le cadre d’un financement, d’un virement, d’un remboursement ou d’un mouvement interne. Dans la grande majorité des cas, il s'agit d'un montant réclamé à un copropriétaire, dans le cadre d'un **appel de fonds**, d’un **état des dépenses** ou d’un **décompte de charges**. Il correspond à une attente comptable, liée à des écritures.

!!! note "Distinction entre suivi et comptabilité"
    💡 Le cumul des `Funding` relatifs aux appels de fonds ne reflète pas toujours la situation comptable réelle  : certains financements peuvent ne pas avoir encore été générés, annulés ou faire l'objet de situations particulières.
    💡 Les funding et les paiements sont uniquement des moyens de suivre les paiements attendus et de générer des SEPA/QR codes, et sont dissociés des écritures comptables (mais liés via l'objet auquel ils se rapportent) permettent d'identifier à quel moment des écritures sont nécessaires ou peuvent être faites.



#### Origine comptable

Un `Funding` est le plus souvent rattaché, directement ou indirectement, à une **pièce comptable de référence**, telle que :

- un `FundRequestExecution` (appel de fonds exécuté)
- un `ExpenseStatement` (état des dépenses ou décompte)
- une `Invoice` (facture fournisseur - à payer)
- `MiscOperation` (OD de remboursement )
- `MoneyTransfer` (transfert entre comptes internes)



Notes : 

* dans le cas de Funding avec montant négatif (funding de paiement - typiquement facture d'achat), une option permet de générer un SEPA (ordre de paiement à envoyer à la banque)
* dans les autre cas, on peut générer un bordereau de paiement avec QR code (template selon la pièce comptable)



Plusieurs `Funding` peuvent être générés à partir d'une seule pièce. 

Le type d'un `Funding` est identité via le champ `funding_type`:

| Type           | Description                                        |
| ---------------- | ---------------------------------------------------- |
| `installment`        | Financement pour le versement d'un acompte. |
| `reimbursement`        | Financement pour un remboursement. |
| `transfer`        | Financement pour transfert interne entre comptes.|
| `invoice`  | Financement pour le paiement d'une facture. |
| `fund_request`       | Financement d'appel de fonds. |
| `expense_statement` | Financement de régulation suite à un décompte périodique. |



!!! note "Montants négatifs & Remboursements"
    Dans le cas d’un **montant négatif**, le `Funding` est tout de même créé (notamment pour visualiser le droit à remboursement), mais son traitement dépend du contexte : il peut être ignoré, soldé par compensation ou supprimé si aucun remboursement n’est demandé.




#### Attribution automatique des paiements

Lors de la création d’un `Funding`, le système recherche automatiquement les **paiements disponibles** pour le copropriétaire concerné. Ces paiements, issus d’extraits bancaires et liés à des écritures comptables, sont alors affectés au `Funding` nouvellement créé, permettant de réduire le solde dû sans intervention manuelle.


#### Statuts d’un Financement (`status`)

Le champ `status` reflète exclusivement l’état financier du `Funding`, indépendamment de son éventuelle annulation :

| Statut           | Signification                                        |
| ---------------- | ---------------------------------------------------- |
| `pending`        | Aucun paiement n’a encore été affecté                |
| `debit_balance`  | Paiement partiel                                     |
| `balanced`       | Montant payé intégralement                           |
| `credit_balance` | Trop-perçu (ou versé) par rapport au montant attendu |





#### Lien avec les comptes bancaires
 Chaque `Funding` peut impliquer **un ou deux comptes bancaires**, selon son type et son rôle (entrant / sortant).

##### Champ `bank_account_id` (compte principal)

Le champ `bank_account_id` représente le **compte bancaire concerné par le mouvement principal**.

- Si le **montant (`amount`) est positif** : le compte `bank_account_id` est **le bénéficiaire attendu** du paiement (ex. : on attend un versement sur ce compte).
- Si le **montant est négatif** : le compte `bank_account_id` est **le compte à débiter** pour effectuer un paiement sortant.

> 🎯 **Interprétation métier** : `bank_account_id` est toujours "le compte concerné par le mouvement côté copropriété".



##### Champ `counterpart_bank_account_id` (compte opposé)

Le champ `counterpart_bank_account_id` est renseigné **seulement si le type de `Funding` l'exige**. Il permet de **spécifier l’autre extrémité du flux**, lorsque le mouvement est un **transfert ou un remboursement bilatéral**.

- Dans un **virement interne**, c’est le compte bancaire **de destination** si `bank_account_id` est le compte de départ.
- Dans un **remboursement**, c’est le compte bancaire **du tiers ou du client**.
- Dans un **appel de fonds**, ce champ est souvent laissé vide (on ne connaît pas les comptes des copropriétaires).

> 🔐 **Contrôle** : la présence ou l'absence de `counterpart_bank_account_id` dépend du **type** de `Funding`, via une contrainte conditionnelle.



##### Règles d’interprétation

| Montant       | `bank_account_id` est…               | `counterpart_bank_account_id` est…             |
| ------------- | ------------------------------------ | ---------------------------------------------- |
| Positif (> 0) | Le compte **recevant** le paiement   | (optionnel) Le compte de provenance (si connu) |
| Négatif (< 0) | Le compte **effectuant** le paiement | Le compte de destination                       |



##### Cas typiques

###### Appel de fonds / Paiement attendu :

```
amount = 150.00
bank_account_id = compte bancaire de la copropriété
counterpart_bank_account_id = null (le copropriétaire peut faire le versement via n'importe quel compte)
```

###### Paiement à un fournisseur :

```
amount = -450.00
bank_account_id = compte bancaire de la copropriété
counterpart_bank_account_id = compte du fournisseur
```

###### Virement interne :

```
amount = -5000.00
bank_account_id = compte source
counterpart_bank_account_id = compte de destination
```



#### Annulation d’une pièce de référence

Lorsqu’un document de référence (appel, décompte…) est annulé :

- Tous les `Funding` associés sont marqués comme **annulés** (`is_cancelled = true`)
- Les `Payments` affectés à ces financements sont **détachés** (`funding_id = null`) et redeviennent disponibles pour être affectés à d’autres `Funding`, existants ou futurs.


#### Génération d’un ordre bancaire (SEPA)

Certains `Funding`, en particulier ceux correspondant à des montants **à rembourser** aux copropriétaires ou à des tiers, peuvent faire l'objet d'une **génération d’ordre bancaire**, matérialisée par un fichier **SEPA**.

Pour en assurer le suivi, un indicateur booléen `is_sent` est utilisé :

- `false` : le financement n’a pas encore été transmis sous forme d’ordre bancaire
- `true` : l’ordre de virement a été généré (et potentiellement transmis à la banque)

Cela permet d’identifier facilement les `Funding` en attente de traitement par le gestionnaire financier (comptable, syndic, etc.) et d’éviter les doublons ou oublis lors des campagnes de remboursement.





### Payment

Les `Payments` représentent les sommes **effectivement versées** : ils sont liés à des lignes d'extraits bancaires et peuvent être affectés à un ou plusieurs `Fundings`.

#### À la création du paiement

- Un `Payment` est toujours créé **à partir d’un extrait bancaire**;
- Il est initialement toujours lié à un Funding via réconciliation (auto ou manuelle);
- lorsqu'il est réconcilié, il est **rattaché à une écriture comptable**;
- La direction dépend du signe du montant (positif = réception, négatif = dépense)

#### Création d’un Funding

Lors de la création d'un nouveau financement, tous les `Payments` orphelins ou en crédit disponibles pour le copropriétaire sont **réaffectés automatiquement** au nouveau `Funding` (leur champ `funding_id` est mis à jour).

#### En cas d’annulation d’un Funding

- Tous les `Payments` liés sont **détachés** (`funding_id = NULL`), et peuvent alors être **réaffectés** manuellement ou automatiquement à un autre `Funding` actif (par défaut, au premier `Funding` non totalement payé)



#### Logique entre Financements et écritures comptables

Lorsqu'on crée un funding, dans certains cas on créée des écritures pour indiquer qu'un montant est attendu (appels de fonds ou relevés périodiques)
dans d'autres cas, on fait une action qui aboutira à des écritures (assimilables à des OD).

Dans tous les cas, c'est le Financement qui renseigne sur les écritures à réaliser.
