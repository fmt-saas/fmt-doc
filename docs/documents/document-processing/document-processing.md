# Document Processing



Dans le logiciel, un **document** représente une **pièce comptable ou administrative**, et est décorrélé de toute donnée binaire liée à un format spécifique (comme un fichier PDF ou une image).  
Le format de fichier (content-type) et les éventuelles données binaires sont traités de manière distincte.

Les pièces peuvent être générées selon deux modalités :

1. **Par import**, via l’**upload** d’un fichier (reçu ou numérisé) ;
2. **Par création manuelle**, à partir d’une saisie utilisateur, sans fichier source.

Toutes les valeurs exploitées par le logiciel sont stockées dans le champ **`document_json`**, qui suit un **schéma de validation** propre au type de document (ex. : extrait bancaire, facture d'achat). Ce schéma garantit la **structure et la complétude des données**, qui sont considérées comme la **source de vérité** pour le traitement du document. Ce contrôle de validité est effectué automatiquement à l'import.

Lorsqu’une pièce est encodée manuellement (par exemple une facture ou un extrait), un **document vide** est initialisé : il ne contient pas encore de `data` ni de fichier, seul le `document_json` est utilisé comme support de saisie.

Pour l’**impression** d’un document, le système utilise en priorité le champ `data` s’il contient une ressource binaire exploitable (avec un content-type imprimable). En l’absence de donnée imprimable, un PDF est **généré dynamiquement** à partir du `document_json`, en s’appuyant sur un **rendu spécifique** au type de document.



## Import

Le processus d'importation d'un document suit un flux complet allant du téléversement (**upload**), en passant par la **complétude**, la **validation**, jusqu'à son **intégration** dans la comptabilité.

Ce fonctionnement repose principalement sur les entités `Document`, `DocumentProcess` et `DocumentType`, avec le support de services modulaires de validation et de transformation.


La plupart des pièces liées à des opérations comptables — qu’elles soient directes ou indirectes — utilisent le statut **`proforma`**, par analogie avec les factures de vente. Une pièce en `proforma` est publiée à titre informatif, mais n’a aucun effet réel en comptabilité. Elle peut néanmoins être visualisée, relue ou vérifiée par une personne autre que celle à l’origine de sa création, en vue d’une future validation.

Lorsqu’un document nécessite un encodage plus complexe, pouvant impliquer plusieurs étapes ou plusieurs personnes (comme des extraits bancaires à réconcilier, ou des factures multisites), il peut être conservé temporairement avec le statut **`draft`**. Ce statut permet une édition plus libre, sans contrainte immédiate de complétude ou de validation.

Une fois qu’un élément est considéré comme prêt — c’est-à-dire qu’il a été vérifié, complété et, le cas échéant, réconcilié — il peut être soumis et passe alors au statut **`posted`**. À ce stade, il est rattaché aux entités cibles (par exemple, des écritures comptables ou des paiements), sans pour autant que ces entités soient validées indépendamment. Ce principe permet de centraliser la logique de validation uniquement au niveau de la pièce comptable, et non des objets dérivés.



### Étapes du workflow

| Étape | Nom            | Description                                                  | Automatisable |
| ----- | -------------- | ------------------------------------------------------------ | ------------- |
| 1     | `Upload`       | Téléversement via `widgetUpload` avec déclenchement auto, récupération d métadonnées | ❌             |
| 2     | `Completion`   | Enrichissement manuel ou automatique des champs requis       | ✅             |
| 3     | `Validation`   | Contrôle métier par un gestionnaire                          | ✅             |
| 4     | `Recording`    | Génération d’écritures comptables en brouillon               | ✅             |
| 5     | `Confirmation` | Approbation finale (direction, juridique, etc.)              | ❌             |
| 6     | `Intégration`  | Document intégré dans les processus opérationnels            | ✅             |



L'étape **`Completion`** se décompte en 3 parties:

| Étape            | Objectif principal                                           |
| ---------------- | ------------------------------------------------------------ |
| [`identification`](document-identification.md) | Déterminer la **nature fonctionnelle** du document (type/subtype) |
| [`extraction`](document-analysis.md)     | Extraire les **valeurs brutes** exploitables : reconnaissance via OCR / parsing si applicable |
| [`matching`](document-analysis.md)       | Associer à des **entités internes** connues (fournisseur, copropriété, copropriétaire…) |
| [`drafting`](document-analysis.md)       | Générer un **document temporaire** (proforma) à partir des données collectées (sans incidence comptable) |



**Note pour le lien entre Facture fournisseur et Supplier(ship):** 
Un fournisseur peut avoir plusieurs comptes bancaires. Si un numéro de compte est trouvé sur la facture, et s'il correspond à un compte bancaire du fournisseur : on utilise celui-là. S'il n'est pas retrouvé automatiquement,  l'utilisateur peut sélectionner le compte (iban) à utiliser pour le paiement.



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

### Lien avec la comptabilité

Pour comprendre comment un `DocumentProcess` aboutit à la création d’une pièce et comment le JSON est synchronisé lors des modifications, se reporter à [Intégration comptable](document-integration.md).
