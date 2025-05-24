## Bank Statement Schema

Cette page décrit la **Structure de transaction bancaire unifiée** ainsi que le schéma JSON correspondant aux relevés bancaires utilisés dans FMT.

### Structure de transaction bancaire unifiée

| Champ | Type | Description |
| ----- | ---- | ----------- |
| `transaction_id` | string | Identifiant unique de la transaction |
| `date` | date-time | Date de l'opération |
| `value_date` | date-time | Date de valeur si différente de `date` |
| `amount` | number | Montant débité ou crédité |
| `currency` | string | Devise (ISO 4217) |
| `balance` | number | Solde du compte après la transaction |
| `counterparty` | string | Tiers associé à l'opération |
| `counterparty_account` | string | IBAN du tiers |
| `counterparty_bic` | string | BIC du tiers |
| `communication` | string | Communication libre ou structurée |
| `reference` | string | Référence de paiement ou de virement |

### Schéma JSON

```json
{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "urn:fmt:json-schema:finance:bank-statement",
    "title": "Unified Bank Statement",
    "type": "object",
    "required": [
        "account",
        "currency",
        "start_balance",
        "end_balance",
        "transactions"
    ],
    "properties": {
        "account": {
            "type": "string"
        },
        "currency": {
            "type": "string",
            "pattern": "^[A-Z]{3}$"
        },
        "start_balance": {
            "type": "number"
        },
        "end_balance": {
            "type": "number"
        },
        "transactions": {
            "type": "array",
            "items": {
                "type": "object",
                "required": [
                    "transaction_id",
                    "date",
                    "amount",
                    "balance"
                ],
                "properties": {
                    "transaction_id": {
                        "type": "string"
                    },
                    "date": {
                        "type": "string",
                        "format": "date-time"
                    },
                    "value_date": {
                        "type": "string",
                        "format": "date-time"
                    },
                    "amount": {
                        "type": "number"
                    },
                    "currency": {
                        "type": "string",
                        "pattern": "^[A-Z]{3}$"
                    },
                    "balance": {
                        "type": "number"
                    },
                    "counterparty": {
                        "type": "string"
                    },
                    "counterparty_account": {
                        "type": "string"
                    },
                    "counterparty_bic": {
                        "type": "string"
                    },
                    "communication": {
                        "type": "string"
                    },
                    "reference": {
                        "type": "string"
                    }
                }
            }
        }
    },
    "additionalProperties": false
}
```
