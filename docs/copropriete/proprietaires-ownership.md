## Propriétaires (`Ownership`)

A la création d'un propriétaire, on créée des comptes comptables spécifiques dans le plan comptable 

|type de fonds|identifiant|compte|
|--|--|--|
|fonds de réserve|co_owners_reserve_fund|4100xxxxx|
|fonds de roulement|co_owners_working_fund|4101xxxxx|


Ces comptes sont retrouvés via la codes "operation_assignment" co_owners_reserve_fund et co_owners_working_fund

### Communications avec les propriétaires

* Un **représentant** est toujours défini pour chaque `Ownership`.
  * Pour un `Ownership` **unique**, le propriétaire unique est automatiquement désigné représentant.
  * Pour un `Ownership` **joint** (indivision), le premier propriétaire encodé est représentant par défaut, mais ce choix peut être modifié manuellement.
* Les **préférences de communication** sont attachées à l’`Ownership` dans son ensemble et peuvent être ajustées par le propriétaire désigné comme représentant.
* Pour les envois **par courrier**, l’adresse utilisée est choisie parmi celles du `representative owner`.
