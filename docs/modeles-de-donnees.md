# Modèles de données

Cette page présente une vue d'ensemble des modèles de données partagés au sein de l'application. Chaque entité importante dispose d'un champ `status` pour suivre son état tout au long de son cycle de vie.

```yaml
'status' => [
    'type' => 'string',
    'selection' => ['pending', 'validated'],
    'default' => 'pending'
]
```

En utilisant ce champ commun, il devient possible de gérer toutes les entités selon un même flux : création en attente puis validation définitive. Ce mécanisme évite la duplication d'enregistrements pour les comptes comptables, les comptes bancaires, les fonds et toute entité similaire. On sait immédiatement quelle action entreprendre en fonction de l'état de l'entité : rester en attente ou passer à la validation.
