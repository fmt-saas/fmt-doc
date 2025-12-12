# Documents

Dans le logiciel, un **document** ne doit pas être compris comme un simple fichier stocké dans un dossier, mais comme un **artefact métier structuré**, porteur de sens, de règles et de liens avec les entités du système.

Cette distinction est fondamentale pour comprendre l’organisation, le traitement et la recherche des documents dans l’application.

---

## Terminologie

Les termes suivants sont utilisés de manière cohérente dans la documentation et dans le logiciel :

* **Pièces comptables** → *Accounting documents*
* **Documents juridiques** → *Legal documents*
* **Documents administratifs** → *Administrative documents*
* **Pièces jointes / annexes** → *Attachments*

Ces catégories reflètent des **finalités d’usage**, pas des différences techniques de stockage.

---

## Document ≠ fichier ≠ dossier

Un **Document** n’est pas équivalent à un fichier, ni à un dossier.

* Le **fichier** correspond aux **données binaires** (PDF, image, etc.).
* Le **Document** est une entité applicative qui :

  * référence ces données binaires,
  * porte des métadonnées métier,
  * est reliée à une ou plusieurs entités du système.
* Les **dossiers** sont une organisation secondaire, destinée à l’utilisateur, et **ne constituent jamais une source de vérité fonctionnelle**.

👉 Un document peut donc être retrouvé, traité ou analysé **indépendamment de son emplacement physique**.

---

## Rôle de l’entité `Document`

L’entité `Document` est utilisée pour :

* stocker et référencer les données binaires,
* qualifier ces données via un `document_type_id`,
* servir de **point d’ancrage** entre les fichiers et les objets métier.

Les données binaires associées à un `Document` représentent une **trace documentaire** d’une information traitée dans le logiciel, qu’elle soit :

* importée depuis l’extérieur,
* générée automatiquement,
* ajoutée ultérieurement comme pièce jointe.

---

## Documents et entités métier

Les documents sont toujours **rattachés à des entités cibles** (ex. : facture, extrait bancaire, procès-verbal, virement, etc.).

La logique de recherche et d’exploitation des documents repose sur ce principe fondamental :

> **On part toujours des entités métier, puis on retrouve les documents qui leur sont liés.**

Cela permet notamment :

* de retrouver automatiquement le dernier document pertinent (ex. : dernier PV d’AG),
* d’accéder à l’historique documentaire d’un objet,
* de raisonner en termes métier plutôt qu’en termes de fichiers.

---

## Documents d’origine et documents annexes

Pour certaines entités, notamment les **pièces comptables**, la présence de documents obéit à des règles précises.

### Documents d’origine

Pour toute pièce comptable, il existe **au minimum un document d’origine** (`is_origin = true`) :

* soit un document **importé**, à l’origine de la création de la pièce (`is_source = true`),
* soit un document **généré automatiquement** suite à un encodage manuel (`is_source = false`), comme une facture d’achat ou un extrait bancaire.

Ces documents constituent la **référence principale** de la pièce.

### Documents annexes

Il est également possible de rattacher, de manière arbitraire, des documents supplémentaires à une entité :

* pièces jointes,
* justificatifs complémentaires,
* annexes diverses.

Ces documents ne sont pas considérés comme des documents d’origine (`is_origin = false`), mais enrichissent le contexte documentaire de l’objet.

---

## Métadonnées métier et datation des documents

La date de création technique d’un document ne constitue pas une information fiable du point de vue métier, notamment parce que :

* les documents peuvent être générés de manière asynchrone,
* leur création peut intervenir après coup.

La **datation fonctionnelle** d’un document repose donc sur les **métadonnées portées par l’entité cible**, telles que :

* `fiscal_year_id`
* `fiscal_period_id`

Ces informations permettent :

* de situer un document dans le temps métier,
* de retrouver des documents pertinents sur une période donnée,
* d’effectuer des recherches programmatiques fiables.

---

## DocumentType et descripteur de données

Chaque document est associé à un **type de document** (`DocumentType`), qui définit sa finalité et son contexte d’utilisation.

Pour chaque fichier associé à une entité métier, un **descripteur JSON** est également présent.
Ce descripteur respecte un schéma correspondant au `document_type_id` et permet :

* de structurer les informations spécifiques au document,
* de supporter les mécanismes de validation, d’étiquetage ou d’intégration,
* d’assurer une cohérence entre les documents, leurs usages et les règles applicables.

Le rôle central des `DocumentType` et des règles associées est détaillé dans la section dédiée à l’organisation des documents.

---

## En résumé

* Un **Document** est un objet métier, pas un simple fichier.
* Les documents sont **toujours interprétés via les entités auxquelles ils sont liés**.
* Les dossiers ne sont qu’un moyen de présentation, jamais un mécanisme fonctionnel.
* La datation et la recherche des documents reposent sur des **métadonnées métier**, pas sur des timestamps techniques.
* Les `DocumentType` constituent le **pivot** entre documents, règles et usages.

