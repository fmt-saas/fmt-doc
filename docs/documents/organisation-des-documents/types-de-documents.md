### Types de documents

| `document_type`         | Dossier(s) cible(s) (`code`)                           | Libellé                            | Description / Usage                                          |
| ----------------------- | ------------------------------------------------------ | ---------------------------------- | ------------------------------------------------------------ |
| `invoice`               | `supplier_invoices`                                    | Facture fournisseur                | Document comptable à comptabiliser et réconcilier            |
| `credit_note`           | `supplier_invoices`                                    | Note de crédit fournisseur         | Note de crédit liée à une facture précédente                 |
| `quote`                 | `tender_documents`, `works_and_repairs`                | Devis                              | Proposition chiffrée, rattachable à un dossier travaux ou sinistre |
| `purchase_order`        | `works_and_repairs`                                    | Bon de commande                    | Validation d’engagement de dépenses                          |
| `delivery_note`         | `works_and_repairs`                                    | Bon de livraison                   | Justifie qu’un service ou une marchandise a été livré        |
| `incident_report`       | `works_and_repairs`, `legal_followup`                  | Rapports de sinistre               | Document décrivant un problème ou dégât                      |
| `maintenance_report`    | `maintenance_logs`                                     | Rapport d’entretien                | Suivi régulier, ex. extincteurs, ascenseurs                  |
| `contract`              | `contracts`, `insurance_contracts`, `syndic_contracts` | Contrat fournisseur                | Engagement contractuel formel (nettoyage, assurance, etc.)   |
| `certificate`           | `insurance_contracts`, `justifications`                | Attestation                        | Preuve de conformité, certificat de contrôle ou d’assurance  |
| `terms_and_conditions`  | `contracts`                                            | Conditions générales               | Pièce annexe souvent non pertinente                          |
| `reconciliation_report` | `operation_statements`                                 | Relevé de consommations            | Répartition ou données de consommation (eau, gaz…)           |
| `fund_request`          | `operation_statements`                                 | Appel de fonds *(hypothétique)*    | Document sollicitant un paiement d'avance ou une participation |
| `expense_statement`     | `operation_statements`                                 | État des dépenses *(hypothétique)* | Détail ou synthèse des charges engagées                      |
| `bank_statement`        | `bank_statements`                                      | Relevés bancaires                  | Mouvement sur compte bancaire de l’ACP                       |
| `legal_document`        | `legal_followup`                                       | Document juridique                 | Assignation, ordonnance, etc.                                |
| `correspondence`        | `legal_followup`, `council_minutes`, `internal_notes`  | Courrier                           | Message utile, libre ou informatif (sans pièce formelle)     |
| `supporting_document`   | `justifications`                                       | Pièce justificative                | RIB, Kbis, attestation URSSAF, etc.                          |
| `internal_memo`         | `internal_notes`                                       | PV                                 | Notes produites par l'application ou une personne de l'équipe |



### Sous-Types de documents

Certains documents nécessitent la présence d'un sous-type de document pour pouvoir identifier la manière de (RecordingRule) et de la labeliser (LabelingRule)

| `document_type` | document_subtype     | Description                         |
| --------------- | -------------------- | ----------------------------------- |
| `invoice`       |                      |                                     |
|                 | `advance_invoice`    | Factures d'acompte                  |
|                 | `adjustment_invoice` | Factures de régularisation          |
|                 | `off_contract`       | Factures de prestation hors-contrat |
| `credit_note`   |                      |                                     |

