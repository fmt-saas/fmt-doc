## Comptes bancaires

Les comptes bancaires sont associés aux identités.


Par défaut, une identité permet de préciser un compte bancaire principal. Mais une identité peut être associée à un nombre non limité de comptes bancaires supplémentaires.

Pour faciliter l'encodage, il y a une synchro entre la liste de compte et le compte renseigné dans l'identité : de sorte que le compte de l'identité est toujours présent également dans la liste.



La clé d'unicité des `BankAccount` est le numéro IBAN (il ne peut pas y avoir deux comptes avec le même IBAN / deux Identity ne peuvent jamais avoir un compte identique).

Les comptes bancaires référencés dans le cadre des copropriétés sont des entités spécifiques :

* **CondominiumBankAccount** : associe une copropriété (`condo_id`) et un compte comptable du PCMN de l'ACP
* **SuppliershipBankAccount** : associe un fournisseur (`Suppliership`) et un compte bancaire spécifique (le compte bancaire à utiliser est susceptible de changer en fonction du type de contrat ou selon le compte bancaire détenu par la copropriété - pour minimiser les frais et les délais). Cette entité utilise une autre table, synchronisée avec les compes ciblés.

Quand on ajoute un fournisseur à une copropriété, par défaut, on ajoute le compte bancaire principal du fournisseur (`is_primary`) dans les `SuppliershipBankAccount`.
