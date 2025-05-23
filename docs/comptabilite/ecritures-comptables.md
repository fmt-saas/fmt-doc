## Ecritures comptables

Le flux d'écritures comptables est alimenté par les factures et les pièces comptables.

Types d'écritures : 

* factures, notes de crédit, notes de frais : ligne par ligne (ACH - journal des achats)
* mouvements bancaires (BAN - journal des banques)
* opérations diverses (OD)
* comptabilisation provisions (imputation et report de charge automatique - partie dans les charges et partie à reporter)
* comptabilisation des appel de fonds (toujours avec clés de répartition)

Possibilité d'encodage avec ou sans période (par défaut, la date de prélèvement sur le compte bancaire):

* période (ex. nettoyage du bâtiment en janvier) [le plus courant] - possibilité de choisir des périodes prédéfinies
  * pour tout l'exercice (en cours)
  * pour le mois de la facture
  * pour le mois précédent (possibilité d'assigner la période par type de fournisseur)
* pas de période (date de validité date_fin = date_début)


Répartition sur la période renseignée :

* sur l'exercice: nb/jour exercice en cours / durée exercice 6xx (+)
* le reste sur le compte "charges à reporter" (bilan) 490 (+)

Au début d'exercice (automatique) : on utilise le compte de charge pour faire une OD => 490 en (-) et 6xx en (+)



Lors de l'encodage d'une facture, ligne par ligne, on renseigne le taux de TVA appliqué, mais il n'y a pas d'écriture pour la TVA (uniquement gérer pour pouvoir communiquer au proprio ce qu'il peut)

* possibilité de marquer une facture comme ne devant pas (encore) être payée (validation)
* identification / distinction entre factures domiciliées et non domiciliées (confusion "à ne pas payer")



Dans le cas où on a une facture, et qu'on sait qu'elle correspond à un montant qui devrait arriver à un moment sans savoir exactement quand, on crée une ligne sur un compte d'attente (49xx : directement au bilan) : 

* stocks (exemple : clés)
* sinistres
* factures en attente de répartition (comptable ne sait pas où la mettre : à reclasser ultérieurement)



Important: une fois qu'une écriture est faite, elle ne peut pas être supprimée, mais uniquement annulée par une autre écriture).



### Structure

Les écritures comptables sont modélisées sur base de deux entités:

- **AccountingEntry** : Représente une écriture comptable en tant qu’ensemble cohérent d’opérations affectant la comptabilité.
- **AccountingEntryLine** : Correspond à une ligne d’écriture détaillant l’impact sur un compte spécifique.

La logique est basée sur les principes suivants : 

* **Équilibre obligatoire** : La somme des montants débités et crédités d’une `AccountingEntry` doit toujours être égale.
*  **Transactionnalité** : Une écriture n’est prise en compte dans la comptabilité qu’après validation.

*  **Immutabilité** : Une fois validée, une écriture ne peut plus être supprimée, seule une contre-passation peut la corriger.



Chaque `AccountingEntry` est composé d’une ou plusieurs `AccountingEntryLines`, qui détaillent :

- Le **compte comptable** concerné.
- Le **montant au débit ou au crédit**.
- La **référence du journal** et de la période concernée.
- L’**éventuel rattachement à une pièce comptable**

Une `AccountingEntry` suit un cycle de validation et possède les statuts suivants :

1. **Pending** : Écriture en attente de validation manuelle, modifiable.
2. **Planned** : Écriture en attente de validation automatique, non modifiable.
3. **Validated** : Écriture définitivement enregistrée, impactant la balance.



| Situation                         | `status`    | `is_temp` | `is_cancelled` | Comptabilisée ? | Supprimable ?          |
| --------------------------------- | ----------- | --------- | -------------- | --------------- | ---------------------- |
| En attente de validation manuelle | `pending`   | false     | false          | ❌               | ✅                      |
| Planifiée pour futur              | `planned`   | false     | false          | ❌               | ✅                      |
| Validée (définitive)              | `validated` | false     | false          | ✅               | ❌                      |
| Validée temporaire                | `validated` | true      | false          | ✅               | ✅ (si période ouverte) |
| Annulée (via extourne)            | `validated` | false     | true           | ✅ (neutralisée) | ❌                      |
