## Organisation des documents 

Les documents peuvent être regroupés par "noeuds" similaires à des dossiers de filesystem, permettant de regrouper les documents de manière hiérarchisée.

Il existe une arborescence par défaut qui est utiliée comme modèle.

A la création d'un Condominium, les dossiers corrspondants sont créés.
Dans le cas où il s'agit d'un transfert, les documents appartenant au Condominium sont automatiquement importés.

Le modèle d'arborescence associe également, pour chaque noeud, un code spécifique, qui permet, au niveau programmatique, d'identifier le rôle d'un dossier.

Lors de la génération des documents, ceux-ci sont automatiquement rattachés à un dossier (noeud) de l'arborescence selon leur nature.

Les documents sont identifiés de manière unique avec un UUID. C'est cet identifiant qui est utilisé pour envoyer les requêtes API au EDMS.






### Arborescence des dossiers (par copropriété)

| Code dossier           | Nom du dossier                                    | Description / Contenu attendu                                |
| ---------------------- | ------------------------------------------------- | ------------------------------------------------------------ |
| `general_meetings`     | Assemblées Générales                              | Convocations, procès-verbaux, listes de présence             |
| `tender_documents`     | Bordereaux / Devis fournisseurs                   | Appels d’offres, devis, consultation d’entreprises           |
| `maintenance_logs`     | Carnets d'entretien                               | Rapports d’entretien périodiques (ex. extincteurs, chaudière, etc.) |
| `council_minutes`      | Conseil de copropriété / Comptes rendus           | Comptes rendus des réunions du conseil                       |
| `legal_followup`       | Contentieux / relance                             | Courriers de relance, procédures judiciaires, assignations   |
| `insurance_contracts`  | Contrats d’assurance                              | Contrats d’assurance, attestations associées                 |
| `syndic_contracts`     | Contrats de syndic                                | Contrat désignant le syndic en cours                         |
| `works_and_repairs`    | Interventions - Travaux                           | Bons d’intervention, rapports de travaux, plans techniques   |
| `sepa_mandates`        | Mandats de prélèvement                            | Mandats SEPA signés                                          |
| `regulations`          | Règlement de copropriété                          | Règlement, modificatifs, état descriptif de division, règlements intérieurs |
| `operation_statements` | Relevés des charges et produits                   | Relevés de dépenses, répartitions, appels de fonds           |
| `bank_statements`      | Relevés bancaires                                 | Relevés bancaires liés au compte de la copropriété           |
| `contracts`            | Contrats fournisseurs *(hors syndic & assurance)* | Contrats de prestation (nettoyage, maintenance, etc.)        |
| `justifications`       | Pièces justificatives                             | RIB, Kbis, attestations URSSAF, etc.                         |
| `internal_notes`       | Notes internes                                    | Notes internes, PV produits par l'app ou l’équipe            |
| `supplier_invoices`    | Factures et Notes de crédit fournisseurs          | Factures reçues ou à comptabiliser                           |
