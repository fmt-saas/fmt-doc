## Organisation des documents 

Les documents peuvent être regroupés par "noeuds" similaires à des dossiers de filesystem, permettant de regrouper les documents de manière hiérarchisée.

Il existe une arborescence par défaut qui est utiliée comme modèle.

A la création d'un Condominium, les dossiers corrspondants sont créés.
Dans le cas où il s'agit d'un transfert, les documents appartenant au Condominium sont automatiquement importés.

Le modèle d'arborescence associe également, pour chaque noeud, un code spécifique, qui permet, au niveau programmatique, d'identifier le rôle d'un dossier.

Lors de la génération des documents, ceux-ci sont automatiquement rattachés à un dossier (noeud) de l'arborescence selon leur nature.

Les documents sont identifiés de manière unique avec un UUID. C'est cet identifiant qui est utilisé pour envoyer les requêtes API au EDMS.
