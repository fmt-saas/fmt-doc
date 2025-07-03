## Gestion des mutations / transferts de propriété

La mutation d'un lot au sein d'une copropriété correspond au transfert de propriété d'un vendeur vers un acquéreur. L'application prend en charge ce processus en respectant les exigences légales belges et en distinguant deux volets complémentaires :

1. **La gestion administrative** des échanges avec le notaire via un dossier de mutation.
2. **La comptabilisation** effective de la mutation dans la gestion des charges et des fonds.

### 1. Gestion administrative : Dossier de mutation

Chaque mutation est matérialisée par un dossier regroupant toutes les informations et documents envoyés au notaire. Le dossier évolue selon un *workflow*, notamment :

- une étape **brouillon** pour la préparation des données ;
- une étape **prêt à l'envoi** lorsque tout est complet.

La transmission d'informations au notaire se fait en deux temps conformément à l'article 577‑11 du Code civil :

- **Avant le compromis de vente** (première demande, délai légal de 15 jours)
  - État des appels de fonds
  - Litiges en cours
  - Documents d'identification
  - Derniers PV d'assemblée générale
  - Décomptes des charges
- **Après le compromis de vente** (seconde demande, délai légal de 30 jours)
  - Montant des charges et budget
  - Travaux approuvés par l'AG
  - Frais liés à l'acquisition de parties communes
  - État des litiges judiciaires
  - Solde du vendeur auprès de la copropriété

Chaque envoi est enregistré via les champs `is_sent_summary`, `is_sent_documentation` ainsi que les dates `date_sent_summary` et `date_sent_settlement` afin de garder une trace précise du respect des délais.

### 2. Comptabilisation de la mutation

Quand la vente est confirmée par l'acte notarié, la mutation devient opposable et peut être intégrée en comptabilité. Le système repose sur la `transfer_date` et permet, si nécessaire, de forcer l'exécution sans validation du notaire.

Le traitement comptable se décompose en deux parties.

#### 2.1. Fonds de roulement

Le fonds de roulement est appelé via des appels de fonds périodiques. Lors d'une mutation :

1. Le système calcule la **quote-part représentée** par les lots vendus.
2. Il détermine la **période de transition** entre le début de l'exercice courant et la `transfer_date`.
3. Il identifie les **écritures passées** (`FundRequestExecution`) liées au compte `working_fund`.

**Pour le vendeur**
- Remboursement au prorata temporis des montants payés pour la période antérieure à la mutation.
- Création d'une écriture d'OD et d'un objet `Funding` correspondant.

**Pour l'acheteur**
- Appel de fonds exceptionnel couvrant la période de la mutation jusqu'à la prochaine échéance d'appel.
- Intégration du nouveau copropriétaire dans les exécutions planifiées futures.

**Ajustements**
- Si les lots vendus représentent l'entièreté de la quote-part, les lignes d'appel prévues sont supprimées.
- Sinon, elles sont recalculées selon le nouveau ratio.

L'opération doit rester équilibrée : les montants remboursés doivent correspondre à ceux réclamés.

#### 2.2. Charges courantes

Les charges de fonctionnement sont également réparties au prorata temporis. Un changement de propriétaire peut être pris en compte à partir d'une date donnée grâce à la propriété `effective_from` sur les droits de propriété (`Ownership`).

### Indications de suivi

- L'état des charges indique « Mutation en cours » tant que la mutation n'est pas finalisée.
- Une alerte s'affiche lors de la création d'un nouveau Funding si une mutation est active.
