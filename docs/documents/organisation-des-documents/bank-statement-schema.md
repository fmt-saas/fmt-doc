## Bank Statement Schema

Cette page décrit la **Structure de transaction bancaire unifiée** ainsi que le schéma JSON correspondant aux relevés bancaires utilisés dans FMT.

### Formats d'import supportés

Les relevés bancaires peuvent être importés dans différents formats.
Les **imports Isabel** constituent le premier cas pris en charge :

- CODA
- CAMT.053
- XLSX *(Isabel uniquement)*
- MT940

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

### Formats d'import supportés

#### Isabel

Voici les colonnes présentes lors d'un import **XLS Isabel** :

- Account
- Account holder
- Bank
- Account type
- Bic
- Type of account information
- Statement number
- Statement currency
- Opening balance date
- Opening balance
- Closing balance date
- Closing balance
- Closing available balance
- Entry date
- Value date
- Transaction amount
- Transaction currency
- Transaction type
- Client reference
- Structured Reference
- Unstructured Reference
- Bank reference
- Counterparty name
- Counterparty account
- Counterparty bank BIC
- Counterparty data
- Transaction message
- Sequence number
- Reception Date/Time
- stFreeMessage
