# Impact Ledger Smart Contract

## Overview

Impact Ledger is a Clarity smart contract for managing NGOs, donations, and ownership on the Stacks blockchain. It enables transparent registration, donation tracking, and administrative controls for impact-driven organizations.

## Features

- **NGO Registration:**  
  NGOs can register with a name, purpose, website, and wallet address.

- **Donation Tracking:**  
  Donors can send STX to registered NGOs. All donations are tracked per donor and NGO.

- **Ownership Management:**  
  Contract ownership can be transferred securely.

- **NGO Deactivation:**  
  Owners can deactivate NGOs to prevent further donations.

## Key Functions

- `register-ngo(name, purpose, website)`  
  Register a new NGO.

- `donate(ngo)`  
  Donate STX to a registered NGO.

- `deactivate-ngo(ngo)`  
  Deactivate an NGO (owner only).

- `transfer-ownership(new-owner)`  
  Transfer contract ownership.

- `get-owner()`  
  Get the current contract owner.

## Data Structures

- **NGO List:**  
  Stores up to 200 registered NGO principals.

- **NGO Map:**  
  Maps principal addresses to NGO details.

- **Donations Map:**  
  Tracks donation amounts per donor and NGO.

## Error Codes

- `ERR-NGO-ALREADY-REGISTERED`  
- `ERR-NGO-NOT-FOUND`  
- `ERR-NOT-AUTHORIZED`  
- `ERR-NGO-LIST-FULL`  
- `ERR-OVERFLOW`  

## Usage

Deploy the contract on the Stacks blockchain using the Clarity language. Interact with the contract using the provided public functions.

