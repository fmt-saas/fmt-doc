## Document Processing

Le processus d'importation d'un document dans FMT suit un flux complet allant du téléversement (**upload**), en passant par l'**analyse**, la **validation**, jusqu'à son **intégration** dans la comptabilité.

Ce fonctionnement repose principalement sur les entités `Document`, `DocumentProcess` et `DocumentType`, avec le support de services modulaires de validation et de transformation.


### Étapes du workflow

| Étape | Nom            | Description                                              | Automatisée |
| ----- | -------------- | -------------------------------------------------------- | ----------- |
| 1     | Upload         | Téléversement via `widgetUpload` avec déclenchement auto | ✅           |
| 2     | Analyse        | Reconnaissance du format, OCR / parsing si applicable    | ✅           |
| 3     | Résolution     | Association aux entités connues (ex : fournisseur)       | ✅           |
| 4     | Complétion     | Enrichissement manuel ou automatique des champs requis   | ❌           |
| 5     | Validation     | Contrôle métier par un gestionnaire                      | ❌           |
| 6     | Enregistrement | Génération d’écritures comptables en brouillon           | ✅           |
| 7     | Confirmation   | Approbation finale (direction, juridique, etc.)          | ❌           |
| 8     | Intégration    | Document intégré dans les processus opérationnels        | ✅           |

### Entités principales

#### `Document`

Représente un fichier physique ou numérique importé dans le système. Il contient à la fois des métadonnées structurelles (fichier, type, sous-type) et des champs métiers enrichis.

**Champs clés :**

- `id`, `document_type`, `document_subtype`
- `file`, `status`, `metadata`
- Divers champs métiers selon le type (ex : `account_code`, `amount`, etc.)

Les règles de complétude et de validation dépendent du type et sous-type du document.


#### `DocumentProcess`

Assure le suivi du cycle de vie technique et logique d’un document, en particulier dans le cadre d’un traitement d’importation.

**Champs clés :**

- `id`, `document_id`, `type = "import"`
- `status` : `pending`, `processing`, `success`, `error`
- `has_warning`, `has_error`
- `format` : format interprété du fichier
- `report_html` : rapport détaillé (WYSIWYG) de l’extraction et de la validation


#### `DocumentType` & `DocumentSubType`

Définissent la classification fonctionnelle du document. 

Chaque sous-type permet de retrouver :

- les champs attendus (ex : `account_code`, `vat_rate`, etc.)
- les règles de validation associées
- la stratégie de conversion (ex : vers des écritures comptables)
