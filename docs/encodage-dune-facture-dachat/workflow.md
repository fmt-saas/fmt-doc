## workflow

Une facture d'achat suit le workflow standard pour les factures : `proforma`, `invoice`, `cancelled`

Il est possible d’enregistrer une facture en tant que pro forma (statut proforma) dans un premier temps, afin de compléter ou corriger les informations avant validation finale.



A la validation (passage de 'proforma' à 'invoice')

* Une vérification de la conformité est réalisée (total déclaré et la somme des lignes, +autres contraintes).
* On assigne un numéro de cachet : invoice number (distinction `supplier_invoice_number`)
* On génère les écritures écritures immédiates
* On planifie les écritures pour chaque début de période à venir
