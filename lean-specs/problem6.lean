import Mathlib.Data.Real.Basic
import Mathlib.Data.Nat.Basic
import Mathlib.Combinatorics.SimpleGraph.Basic
import Mathlib.Data.Finset.Basic

-- IMO 2025 Problem 6: Fair Dice Graph Coloring

/- Problem Statement:
A pair of fair n-sided dice are displayed in a store as part of a larger display of dice.
For each die displayed, the shopkeeper chooses n positive integers to place on its faces,
each face has a distinct number. Bob visits the store and wishes to buy a pair of dice
such that his chances of rolling different numbers with each die is exactly (n²-1)/n².

Can Bob select his desired pair from the store display if:
(a) n = 6?
(b) n = 7?
-/

-- Define a die as a collection of n distinct positive integers
structure Die (n : ℕ) where
  faces : Finset ℕ
  card_eq : faces.card = n
  positive : ∀ x ∈ faces, x > 0
  deriving Inhabited

-- Probability of rolling different numbers with two dice
def prob_different (n : ℕ) (d1 d2 : Die n) : ℚ :=
  let pairs_different := (d1.faces ×ˢ d2.faces).filter (fun p => p.1 ≠ p.2)
  (pairs_different.card : ℚ) / (n * n : ℚ)

-- Bob's desired probability
def bob_prob (n : ℕ) : ℚ := (n * n - 1 : ℚ) / (n * n : ℚ)

-- Two dice satisfy Bob's requirement
def satisfies_bob (n : ℕ) (d1 d2 : Die n) : Prop :=
  prob_different n d1 d2 = bob_prob n

-- Graph where vertices are dice and edges connect dice that satisfy Bob's requirement
def dice_graph (n : ℕ) (dice : Finset (Die n)) : SimpleGraph (Die n) where
  Adj := fun d1 d2 => d1 ∈ dice ∧ d2 ∈ dice ∧ d1 ≠ d2 ∧ satisfies_bob n d1 d2
  symm := sorry
  loopless := sorry

-- A set of dice is Bob-selectable if some pair satisfies his requirement
def bob_selectable (n : ℕ) (dice : Finset (Die n)) : Prop :=
  ∃ d1 d2 : Die n, d1 ∈ dice ∧ d2 ∈ dice ∧ d1 ≠ d2 ∧ satisfies_bob n d1 d2

-- Main theorems
theorem problem6_part_a :
  ∃ dice : Finset (Die 6), 
    dice.card > 0 ∧ ¬bob_selectable 6 dice :=
sorry

theorem problem6_part_b :
  ∀ dice : Finset (Die 7),
    dice.card > 0 → bob_selectable 7 dice :=
sorry

-- Key insight: Two dice satisfy Bob's requirement iff they share exactly one common value
lemma bob_condition_iff_one_common (n : ℕ) (d1 d2 : Die n) :
  satisfies_bob n d1 d2 ↔ (d1.faces ∩ d2.faces).card = 1 :=
sorry

-- For n=6: Construction of counterexample using bipartite graph
-- Dice can be 2-colored such that dice of same color share 0 or ≥2 values
lemma exists_bipartite_coloring_n6 :
  ∃ (color : Die 6 → Fin 2),
    ∀ d1 d2 : Die 6, color d1 = color d2 → 
      (d1.faces ∩ d2.faces).card ≠ 1 :=
sorry

-- For n=7: Proof that Bob can always find a suitable pair
-- Uses counting argument and pigeonhole principle
lemma always_exists_pair_n7 (dice : Finset (Die 7)) (h : dice.card ≥ 2) :
  bob_selectable 7 dice :=
sorry

-- Helper: Number of die pairs that share exactly k values
def pairs_with_k_common (n k : ℕ) (dice : Finset (Die n)) : ℕ :=
  (dice ×ˢ dice).filter (fun p => 
    p.1 ≠ p.2 ∧ (p.1.faces ∩ p.2.faces).card = k).card

-- For n=7, the distribution of intersection sizes forces existence of size-1 intersection
lemma intersection_sizes_n7 (dice : Finset (Die 7)) (h : dice.card ≥ 2) :
  ∃ d1 d2 : Die 7, d1 ∈ dice ∧ d2 ∈ dice ∧ d1 ≠ d2 ∧ 
    (d1.faces ∩ d2.faces).card = 1 :=
sorry

#check problem6_part_a
#check problem6_part_b