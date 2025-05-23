## Informations à renseigner

Lors de l'encodage, les informations suivantes doivent être complétées :

| Champ                 | Description                                                  |
| --------------------- | ------------------------------------------------------------ |
| **Fournisseur**       | Identifié automatiquement sur base du numéro de TVA          |
| **Date de facture**   | Date indiquée sur le document reçu                           |
| **Numéro de facture** | Numéro du document transmis par le fournisseur               |
| **VCS**               | Référence fournisseur (ex. n° client interne ou code de suivi fournisseur) |
| **Période couverte**  | Facultative – utile si le fournisseur découpe par période ; champs : `date_from` (début) et `date_to` (fin), issus de `<cac:InvoicePeriod>` |
| **Date d’échéance**   | Champ `<cbc:PaymentDueDate>`, indiqué sur la facture         |
| **Pièces jointes**    | Documents PDF, images ou annexes liées à la facture (`docs_ids`) |
| **Numéro de cachet**  | Assigné automatiquement à la validation (statut = `invoice`) ; non modifiable après validation |
