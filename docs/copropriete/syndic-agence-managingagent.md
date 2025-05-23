## Syndic / Agence (`ManagingAgent`)

Le managing agent est :

* soit l'organisation [1] pour les instances LOCALES
(dans ce cas les données doivent être synchronisées en cas de modification entre Organisation et ManagingAgent)

* soit un des managing agent référencés, pour l'instance MASTER
  (dans ce cas, synchro entre ManagingAgent et l'identité liée)

=> il faut un param de config pour savoir de quel type d'instance il s'agit
