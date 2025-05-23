## Email Digestor

L'**email digestor** est destiné à importer les documents reçus via une boite email.

Chaque copropriété dispose d’une adresse email dédiée, configurée pour être accessible en lecture via le protocole IMAP. Le digestor interroge régulièrement ces boîtes pour récupérer les nouveaux messages. À la réception d’un email, le système enregistre son contenu (expéditeur, destinataires, sujet, date de réception, corps du message) ainsi que les pièces jointes.

Chaque pièce jointe est convertie en entité `Document`, associée à l’email source via un champ `email_id`. 

Ces documents sont classés selon leur type (`invoice`, `quote`, `report`, etc.), soit automatiquement (sur base du contenu, du nom de fichier ou de règles heuristiques), soit manuellement via l’interface utilisateur.

Un document peut également être rattaché à un **dossier de gestion** (`CaseFile`), représentant un sinistre, une demande de devis, une inspection ou tout autre suivi structuré. Cette liaison permet de regrouper tous les documents, échanges et informations liés à une même problématique.

Chaque document possède un statut (`pending`, `processed`, `ignored`) qui détermine s’il a été pris en charge ou non. L’email source est automatiquement marqué comme **traité** (`processed`) dès que tous ses documents associés ont été eux-mêmes traités.



Ce mécanisme permet :

- une centralisation des documents entrants sans manipulation manuelle,
- un archivage des échanges par email,
- une interface claire pour le traitement et la classification des documents,
- et une intégration directe aux processus métiers (comptabilité, sinistres, prestations…).

Le digestor peut fonctionner en mode passif (consultation des boîtes existantes) ou actif (création et gestion d’adresses email spécifiques par ACP), selon les préférences et contraintes de l’organisation.
