// src/main.nr
// ZK Proof for Simplified Quadratic Funding Matching Calculation

use dep::std::hash::pedersen_hash;

// Assume a fixed number of contributions for this example to simplify array handling.
// Let NUM_CONTRIBUTIONS = 3 for this example.
// This would be defined by the array sizes in the function signature.

fn main(
    // === Private Inputs (Known to the Project Owner/Prover) ===
    // For each of the NUM_CONTRIBUTIONS:
    contributor_secrets: [Field; 3],          // Secrets identifying unique contributors (highly simplified uniqueness assumption)
    contribution_amounts: [Field; 3],       // Amount contributed by each
    contribution_sqrt_amounts: [Field; 3],  // Prover provides sqrt(contribution_amounts[i])
    contribution_blinding_factors: [Field; 3],// Blinding factors for each contribution commitment

    // === Public Inputs ===
    // Publicly known commitments for each contribution
    contribution_commitments: [pub Field; 3],

    // Project owner's claims to be verified
    claimed_total_direct_donations: pub Field,
    // For this simplified version, claimed_number_of_unique_contributors MUST equal NUM_CONTRIBUTIONS
    // as we assume each entry in contributor_secrets is unique.
    // A more complex circuit would handle actual uniqueness checks.
    claimed_number_of_unique_contributors: pub Field, 
    claimed_matched_funding: pub Field,

    // Overall QF round parameters
    matching_pool_budget: pub Field
) {
    let num_contributions = 3; // Should match array size

    // --- 1. Verify Contribution Commitments & Calculate Total Direct Donations ---
    let mut calculated_total_direct_donations = 0;
    for i in 0..num_contributions {
        // a. Verify commitment
        let computed_commitment = pedersen_hash([
            contributor_secrets[i],
            contribution_amounts[i],
            contribution_blinding_factors[i]
        ]);
        constrain computed_commitment == contribution_commitments[i];

        // b. Accumulate direct donations
        calculated_total_direct_donations = calculated_total_direct_donations + contribution_amounts[i];

        // c. Verify provided square root
        // Ensure contribution_sqrt_amounts[i] * contribution_sqrt_amounts[i] == contribution_amounts[i]
        // This also implies contribution_amounts[i] must be a perfect square if sqrt is integer.
        // For QF, amounts are usually small, so integer square roots (or fixed-point) are common.
        // We also need to ensure the remainder is 0 if we want perfect integer square roots.
        // A simple check:
        let sqrt_val = contribution_sqrt_amounts[i];
        constrain sqrt_val * sqrt_val == contribution_amounts[i]; 
        // To be more robust for general integers, one might need to prove:
        // sqrt_val * sqrt_val <= contribution_amounts[i] AND
        // (sqrt_val+1) * (sqrt_val+1) > contribution_amounts[i]
        // But for QF, often whole number contributions are assumed, making perfect squares easier.
        // We'll stick to the simpler perfect square check.
    }
    constrain calculated_total_direct_donations == claimed_total_direct_donations;

    // --- 2. Verify Number of Unique Contributors (Simplified) ---
    // In this simplified model, we assume each entry in contributor_secrets implies a unique contributor.
    // Therefore, the number of unique contributors must be equal to `num_contributions`.
    constrain num_contributions as Field == claimed_number_of_unique_contributors;


    // --- 3. Calculate Matched Funding based on QF formula ---
    // QF Match = ( sum(sqrt(contribution_amount_i)) )^2
    let mut sum_of_sqrt_contributions = 0;
    for i in 0..num_contributions {
        sum_of_sqrt_contributions = sum_of_sqrt_contributions + contribution_sqrt_amounts[i];
    }

    let calculated_matched_funding = sum_of_sqrt_contributions * sum_of_sqrt_contributions;
    constrain calculated_matched_funding == claimed_matched_funding;

    // --- 4. Verify Budget Constraint ---
    // The claimed matched funding must not exceed the available matching pool budget.
    constrain claimed_matched_funding <= matching_pool_budget;
    
    // println("Quadratic Funding matching proof validated.");
}