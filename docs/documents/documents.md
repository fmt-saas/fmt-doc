# Documents

Terminologies utilisées : 
    * Pièces comptables → Accounting documents
    * Documents juridiques → Legal documents
    * Documents administratifs → Administrative documents
    * Pièces jointes / Annexes → Attachments


L'entité `Document`est utilisée pour stocker les données binaires et référencer les pièces comptables associées à ces données. Ces données binaires sont une représentation de l'information traitée au sein du logiciel.  


Il est possible d'ajouter des documents (pièces jointes) a posteriori, sur des pièces comptables déjà encodées manuellement (exemple: extraits bancaires).  


Pour toutes les pièces comptables, il y a toujours au minium un document (is_origin=true). 
    * Soit il s'agit d'un document importé qui est à l'origine de la création de la pièce. (is_source=true)
    * Soit il s'agit d'un document généré automatiquement suite à un encodage manuel (is_source=false ; facture d'achat, extrait bancaire) 

Et il est également possible de joindre à une pièce comptable des documents de manière arbitraire (is_origin=false).  

Pour chaque fichier associé à une pièce comptable, un descripteur JSON est également présent, utilisant schéma un corresondant au type (`document_type_id`) de pièce comptable associée. 

## EDMS

Les documents sont consultables sur les instances Locales, mais sont physiquement stockés sur lune instance EDMS distincte.

L'échange de données se fait via le réseau privé, entre les instances Locales et le serveur EDMS.

