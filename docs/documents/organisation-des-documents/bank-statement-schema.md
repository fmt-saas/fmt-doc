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


**Exemple de structure JSON pour les extraits bancaires:**

```json
{
	"account_iban": "BE71 0961 2345 6789",
	"statement_number": "0000123456",
	"opening_balance": 1000.00,
	"opening_date": "2024-05-01",
	"closing_balance": 1200.00,
	"closing_date": "2024-05-10",
	"statement_currency": "EUR",
	"bank_bic": "CREGBEBB",
	"account_holder": "FMT solutions",
	"account_type": "current",
	"transactions": [
		{
			"entry_date": "2024-05-05",
			"value_date": "2024-05-05",
			"amount": -150.00,
			"currency": "EUR",
			"transaction_type": "sepa_direct_debit",
			"sequence_number": 123,
			"received_at": "2024-05-05T10:45:00Z",
			"mandate_id": "MANDATE-2023-XYZ",
			"client_reference": "Facture 2024-87",
			"structured_reference": "+++123/4567/89012+++",
			"bank_reference": "987654321",
			"unstructured_reference": "Paiement pour facture avril",
			"counterparty_name": "EDF Luminus",
			"counterparty_iban": "BE23 0910 1111 2222",
			"counterparty_bic": "GEBA BE BB",
			"counterparty_details": "Rue de l'Énergie, Liège",
			"transaction_message": "Paiement automatique"
		}
	]
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

