# Tickethos Event Ticketing Smart Contract

## Overview

**Tickethos** is a decentralized event ticketing system built on Clarity. It issues, sells, and manages non-fungible tokens (NFTs) that represent event tickets. The contract ensures fair ticket distribution, secure payments in STX, and transparent ticket ownership transfers.

## Features

* **Ticket Issuance**: Only the contract owner can create new tickets, with a hard cap of 1,000 tickets.
* **Ticket Sales**: Buyers can purchase tickets using STX at a fixed price.
* **NFT Ticketing**: Each ticket is minted as an NFT, ensuring uniqueness and verifiable ownership.
* **Transfers**: Ticket holders can transfer their NFTs to others.
* **Tracking**: Keeps records of tickets issued, sold, and owned by each participant.

## Data Structures

* **total-tickets**: Number of tickets issued for the event.
* **tickets-sold**: Number of tickets sold so far.
* **tickets-owned**: Maps each principal to the number of tickets they own.
* **ticket-nft**: NFT representing each ticket, identified by ticket ID.

## Constants

* **CONTRACT\_OWNER**: The deployer of the contract.
* **TICKET\_PRICE**: 100 microSTX per ticket.
* **MAX\_TICKETS**: Maximum of 1,000 tickets allowed.

## Error Codes

* `u100`: Unauthorized (only owner can perform this action).
* `u101`: Tickets sold out.
* `u102`: Insufficient funds to buy ticket.
* `u103`: Invalid ticket ID or not owned by sender.
* `u104`: Ticket transfer failed.
* `u105`: Ticket minting failed.

## Functions

### Public

* `issue-tickets (amount)`: Owner issues a new batch of tickets, respecting the maximum supply.
* `buy-ticket`: Allows a participant to purchase a ticket, transferring STX to the owner and minting an NFT.
* `transfer-ticket (to ticket-id)`: Enables ticket holders to transfer ownership of a ticket NFT.

### Read-only

* `get-total-tickets`: Returns the total tickets issued.
* `get-tickets-sold`: Returns the number of tickets sold.
* `get-tickets-owned (owner)`: Returns the number of tickets a given principal owns.
* `get-ticket-owner (ticket-id)`: Returns the owner of a specific ticket NFT.

## Usage

1. **Owner**: Issues tickets before sales begin.
2. **Participants**: Purchase tickets with STX, receiving NFTs as proof of ownership.
3. **Transfers**: Ticket holders can securely transfer tickets to others.
4. **Verification**: Anyone can check ownership or ticket counts via read-only functions.

Tickethos provides a transparent, secure, and scalable way to manage event ticketing on-chain.
