# Noir ZK Proof for Simplified Quadratic Funding Matching

This project demonstrates a Zero-Knowledge proof using Noir for verifying the matching calculation in a simplified Quadratic Funding (QF) round. The goal is for a project owner to prove they correctly aggregated direct donations, identified unique contributors (in a simplified manner), calculated the QF matched amount based on the formula `(sum(sqrt(donation_i)))^2`, and adhered to the matching pool budget, all without revealing individual contributor secrets or exact donation amounts linked to specific secrets (only commitments are public).

## Core Concept

In Quadratic Funding, small contributions from many unique individuals can be significantly amplified by a matching pool, favoring projects with broad community support. This ZK circuit allows a project owner (prover) to attest to:

1.  **Integrity of Contributions**: Each claimed contribution commitment corresponds to actual (private) contribution data known to the prover.
2.  **Correct Direct Donation Sum**: The total sum of direct donations is correctly calculated.
3.  **Unique Contributor Count (Simplified)**: The claimed number of unique contributors is consistent with the number of processed contributions (this example simplifies uniqueness by assuming each provided contribution entry is from a unique secret).
4.  **Correct QF Match Calculation**: The matched funding amount is correctly derived using the sum of the square roots of individual contributions, squared. The prover supplies the square roots, and the circuit verifies their correctness (`sqrt * sqrt == amount`).
5.  **Budget Adherence**: The calculated matched funding does not exceed the available `matching_pool_budget`.

## Project Structure

(Standard Noir project structure)

## Circuit Logic (`src/main.nr`)

The Noir circuit takes:
*   **Private Inputs**: Arrays for `contributor_secrets`, `contribution_amounts`, `contribution_sqrt_amounts` (integer square roots of amounts), and `contribution_blinding_factors` for a fixed number of contributions.
*   **Public Inputs**: An array of `contribution_commitments`, and claimed values for `total_direct_donations`, `number_of_unique_contributors`, `matched_funding`, plus the `matching_pool_budget`.

It constrains:
1.  Each `contribution_commitment` matches `hash(secret, amount, blinding_factor)`.
2.  Each `contribution_sqrt_amount` squared equals `contribution_amount`.
3.  The sum of `contribution_amounts` equals `claimed_total_direct_donations`.
4.  `claimed_number_of_unique_contributors` equals the fixed number of contributions processed (simplified uniqueness).
5.  `(sum(contribution_sqrt_amounts))^2` equals `claimed_matched_funding`.
6.  `claimed_matched_funding` is less than or equal to `matching_pool_budget`.

## Prerequisites

*   **Nargo**: Noir's package manager. Install from [official documentation](https://noir-lang.org/docs/getting_started/installation/).

## How to Run

1.  **Setup Project**: Create files and structure as outlined.
2.  **Crucial: Update Hash Placeholders**: The `contribution_commitments` array in `Prover.toml` and `Verifier.toml` contains **placeholders**. Recompute these using the private inputs in `Prover.toml` and the `pedersen_hash` logic. Ensure `contribution_amounts` are perfect squares for the `contribution_sqrt_amounts` to be integers.
3.  **Compile**: `nargo compile`
4.  **Generate Proof**: `nargo prove`
5.  **Verify Proof**: `nargo verify`

## Limitations & Simplifications

*   **Fixed Number of Contributions**: Processes a fixed number (3) of contributions.
*   **Simplified Uniqueness**: Assumes each input contribution entry is from a unique secret. Real QF needs robust Sybil resistance (e.g., via identity systems or more complex ZK proofs for uniqueness).
*   **Integer Square Roots**: Assumes contribution amounts are perfect squares for simple integer square root verification. Real QF might use fixed-point arithmetic or more complex sqrt proofs.
*   **QF Formula**: Uses a very basic QF formula.

This project explores how ZK proofs can bring transparency and verifiability to complex funding mechanisms like QF while preserving aspects of donor privacy.