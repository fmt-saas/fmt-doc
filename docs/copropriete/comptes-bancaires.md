## Comptes bancaires

Les comptes bancaires sont associés aux identités.


Par défaut, une identité permet de préciser un compte bancaire principal. Mais une identité peut être associée à un nombre non limité de comptes bancaires supplémentaires.

Pour faciliter l'encodage, il y a une synchro entre la liste de compte et le compte renseigné dans l'identité : de sorte que le compte de l'identité est toujours présent également dans la liste.



La clé d'unicité des `BankAccount` est le numéro IBAN (il ne peut pas y avoir deux comptes avec le même IBAN / deux Identity ne peuvent jamais avoir un compte identique).

Les comptes bancaires référencés dans le cadre des copropriétés sont des entités spécifiques :

* **CondominiumBankAccount** : associe une copropriété (`condo_id`) et un compte comptable du PCMN de l'ACP
* **SuppliershipBankAccount** : associe un fournisseur (`Suppliership`) et un compte bancaire spécifique (le compte bancaire à utiliser est susceptible de changer en fonction du type de contrat ou selon le compte bancaire détenu par la copropriété - pour minimiser les frais et les délais). Cette entité utilise une autre table, synchronisée avec les compes ciblés.

Quand on ajoute un fournisseur à une copropriété, par défaut, on ajoute le compte bancaire principal du fournisseur (`is_primary`) dans les `SuppliershipBankAccount`.





Parfait, voici une version plus directe et synthétique de la documentation pour les `MoneyTransfer`, respectant le style attendu :


### Transfert bancaire interne (`MoneyTransfer`)

Le transfert de fonds entre deux comptes bancaires d’une copropriété est géré à l’aide de l’objet `MoneyTransfer`. Il s’agit d’un type spécialisé d’`operation diverse` (`MiscOperation`) conçu pour formaliser les mouvements internes entre comptes.

Chaque `MoneyTransfer` associe un compte source (`bank_account_id`) et un compte cible (`counterpart_bank_account_id`), tous deux rattachés à la même copropriété (`condo_id`). Le montant à transférer est défini via le champ `amount`. Le transfert peut être lié à un objet `Funding`, utilisé notamment lorsqu’un SEPA doit être généré ou que le mouvement répond à une demande spécifique.

L’enregistrement du transfert implique la validation de plusieurs conditions :

* les deux comptes doivent être renseignés et compatibles avec la copropriété ;
* le montant doit être strictement positif ;
* la date comptable (`posting_date`) doit correspondre à la date du jour ;
* le solde du compte source doit couvrir le montant à transférer (vérification via `CurrentBalanceLine`) ;
* un compte comptable de type `bank_transfer` doit exister pour la copropriété.

Une fois les contrôles validés, le passage à l’état `posted` déclenche la génération des écritures comptables :

* le compte cible est crédité ;
* un compte intermédiaire `bank_transfer` est débité.

L'attribut `is_complete` permet de marquer le transfert comme terminé, généralement après confirmation via un relevé bancaire. En cas de lien avec un `Funding`, le transfert peut être exporté sous forme de fichier SEPA (`pain.001`) à des fins d’exécution bancaire.

