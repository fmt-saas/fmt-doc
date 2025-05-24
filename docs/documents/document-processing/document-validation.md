### Document Validation

Trois niveaux de validation sont appliqués :

#### 1. Validation de schéma (basée sur JSON)

- Contrôle du format, des types de champs, de la présence des données attendues

#### 2. Validation métier

- Basée sur les entités `ValidationRule` et `ValidationRuleLine`
- Une `ValidationRule` est associée à chaque `DocumentType`
- Chaque ligne pointe vers un contrôleur dédié (ex : `acct_document_validity.installation_check`)
- Le contrôleur retourne `{ valid: bool, message: string }`

#### 3. Conversion comptable

- Si toutes les validations sont satisfaites, le document peut être converti en une ou plusieurs entités de l’ERP
- Exemple : `invoice.energy` → 2 écritures comptables + 1 liaison fournisseur