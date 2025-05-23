## Suivis de paiement


### Funding

Un **Financement** (`Funding`) représente une somme d'argent à recouvrer ou à verser. Dans la grande majorité des cas, il s'agit d'un montant réclamé à un copropriétaire, dans le cadre d'un **appel de fonds**, d’un **état des dépenses** ou d’un **décompte de charges**. Il correspond à une attente comptable, assimilable à une facture de vente.

> 💡 Bien que les `Funding` représentent des montants dus, leur cumul ne reflète pas toujours l'état réel du compte comptable d'un copropriétaire : certains financements peuvent ne pas avoir encore été générés, annulés ou faire l'objet de situations particulières.


#### Origine comptable

Chaque `Funding` est toujours rattaché, **directement ou indirectement**, à une **pièce comptable de référence**, telle que :

- un `FundRequestExecution` (appel de fonds exécuté)
- un `ExpenseStatement` (état des dépenses ou décompte)
- une `Invoice` (facture fournisseur - à payer)

Plusieurs `Funding` peuvent être générés à partir d'une seule pièce. 

Dans le cas d’un **montant négatif**, le `Funding` est tout de même créé (notamment pour visualiser le droit à remboursement), mais son traitement dépend du contexte : il peut être ignoré, soldé par compensation ou supprimé si aucun remboursement n’est demandé.


#### Attribution automatique des paiements

Lors de la création d’un `Funding`, le système recherche automatiquement les **paiements disponibles** pour le copropriétaire concerné. Ces paiements, issus d’extraits bancaires et liés à des écritures comptables, sont alors affectés au `Funding` nouvellement créé, permettant de réduire le solde dû sans intervention manuelle.


#### Statuts d’un Financement (`status`)

Le champ `status` reflète exclusivement l’état financier du `Funding`, indépendamment de son éventuelle annulation :

| Statut           | Signification                             |
| ---------------- | ----------------------------------------- |
| `pending`        | Aucun paiement n’a encore été affecté     |
| `debit_balance`  | Paiement partiel                          |
| `balanced`       | Montant payé intégralement                |
| `credit_balance` | Trop-perçu par rapport au montant attendu |


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

Les `Payments` représentent les sommes **effectivement versées** par un copropriétaire. Ils sont liés à des écritures bancaires et peuvent être affectés à un ou plusieurs `Fundings`.

#### À la création du paiement

- Un `Payment` est toujours créé **à partir d’un extrait bancaire**
- Il est initialement toujours lié à un Funding via réconciliation (auto ou manuelle)
- lorsqu'il est réconcilié, il est **rattaché à une écriture comptable**.
- La direction dépend du signe du montant (positif = réception, négatif = dépense)

#### Création d’un Funding

- Tous les `Payments` orphelins ou en crédit disponibles pour le copropriétaire sont **réaffectés automatiquement** à ce nouveau Funding.
- Le `funding_id` est mis à jour

#### En cas d’annulation d’un Funding

- Tous les `Payments` liés sont **détachés** (`funding_id = NULL`)
- Ils peuvent être **réaffectés** manuellement ou automatiquement à un autre Funding actif (par défaut, au premier Funding non totalement payé)
