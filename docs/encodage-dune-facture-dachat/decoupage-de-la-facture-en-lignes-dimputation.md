## Découpage de la facture en lignes d’imputation (`InvoiceLine`)

Lors de l’encodage d’une facture d’achat, le montant total de la facture n’est pas utilisée comme référence : ce sont les lignes de détail qui font foi pour l’imputation comptable.

Il est possible de définir une série de **lignes d’imputation**, chaque ligne permettant d'assigner des montants à des **comptes de charges** spécifiques. Ce découpage ne doit pas nécessairement à correspondre aux lignes présentes sur la facture d'origine : une facture peut être répartie différemment en fonction des critères comptables de la copropriété.

Une suggestion automatique est proposée sur base de la reconnaissance OCR, mais elle doit être validée ou corrigée par le gestionnaire.


Chaque ligne est associée à plusieurs éléments :

- **Un compte de charge** (généralement de type `61xx` ou autre catégorie spécifique).
- **Une clé de répartition**, définissant la manière dont les montants doivent être affectés.
- **Un ratio PROP / LOC**, utilisé pour répartir la charge entre les copropriétaires (ou autres entités concernées).

Ces informations sont copiées de la configuration du compte, mais peuvent être ajustées manuellement pour tenir compte de particularités ou d’exception de gestion.

Une assignation auto (compte, clé, part Prop/Loc) peut être faite via la sélection d'une "nature de dépense".

Les lignes de factures sont modélisées avec l'entité `InvoiceLine`.


Contraintes :

* il ne peut y avoir qu'une seule ligne pour un même compte de charge (dans le cas contraire, on ne peut pas retrouver à quel ligne correspond une imputation comptable)


#### Utilisation du fonds de roulement
Lorsque ce n'est pas précisé autrement, les charges sont considérées comme des charges communes qui devront être réparties entre les copropriétaires sur base de clés de répartitions.

Dans les autres situations, la part du paiement imputée au fonds de roulement correspond à la différence entre le montant total de la facture, la part éventuellement couverte par le ou les fonds de réserve, et les éventuelles parties privatives.

Pour chaque utilisation de fonds, il faut préciser le compte de réserve 160X utilisé.
Sur base du fonds sélectionné, le compte de charge correspondant (libellé « Appels ») est utilisé, par exemple 680010.
(Les informations de compte comptable et de clé de répartition ne peuvent pas être modifiées ; le ratio PROP / LOC n’est pas pertinent dans ce contexte.)


#### Frais privatifs

Certaines dépenses peuvent être considérées comme frais privatifs, c’est-à-dire applicables uniquement à un copropriétaire ou un lot spécifique, et non réparties entre l’ensemble des copropriétaires.

Dans ce cas, l’imputation se fait obligatoirement sur le compte 643 – Frais privatifs.

Les frais privatifs sont exclus des répartitions collectives et doivent faire l’objet d’un suivi individuel pour refacturation ou régularisation ultérieure.


#### Utilisation de fonds de réserve

Une partie ou la totalité d'une facture peut être payée via l'utilisation d'un ou plusieurs fonds de réserve.

**Le fonds de réserve est toujours utilisé avec la même clé de répartition que celle utilisée pour son appel.**
Cela garantit la traçabilité et l’équité dans la répartition entre copropriétaires (La clé de répartition ne peut pas être modifiée lors de l’utilisation du fonds.)
