import Mathlib.Data.Nat.Basic
import Mathlib.Data.Nat.Prime
import Mathlib.NumberTheory.Divisors
import Mathlib.Algebra.Parity

-- IMO 2025 Problem 4: Infinite Sequences with Divisor Sum Rule

/- Problem Statement:
Let f be the function from positive integers to positive integers satisfying f(N) equals 
the sum of the three largest proper divisors of N. (We say that d is a proper divisor of N 
if 1 ≤ d < N and d|N.)

Let a₁ be a positive integer such that successive applications of f never yield a term 
with three or fewer divisors. Set aₙ₊₁ = f(aₙ) for n ≥ 1, so that (aₙ)ₙ≥₁ forms an 
infinite sequence.

Determine all possible values of a₁.
-/

-- Count of divisors function
notation "τ" => Nat.divisors

-- Define the function f that returns sum of three largest proper divisors
noncomputable def f (N : ℕ) : ℕ :=
  if h : N > 1 ∧ (τ N).card ≥ 4 then
    let divs := (τ N).toList.sorted (·≤·)
    let k := divs.length
    (divs.get! (k-2)) + (divs.get! (k-3)) + (divs.get! (k-4))
  else 0

-- Define what it means for a sequence to be valid (infinite with τ(aₙ) ≥ 4)
def validSequence (a : ℕ → ℕ) : Prop :=
  (∀ n : ℕ, n ≥ 1 → a (n+1) = f (a n)) ∧
  (∀ n : ℕ, n ≥ 1 → (τ (a n)).card ≥ 4)

-- Helper: 2-adic valuation
def v₂ (n : ℕ) : ℕ := (n.factorization 2)

-- Helper: 3-adic valuation  
def v₃ (n : ℕ) : ℕ := (n.factorization 3)

-- State F: Fixed point state
def isStateF (n : ℕ) : Prop :=
  v₂ n = 1 ∧ v₃ n ≥ 1 ∧ ¬(5 ∣ n)

-- State G: Growth state
def isStateG (n : ℕ) : Prop :=
  v₂ n ≥ 2 ∧ v₃ n ≥ 1 ∧ ¬(5 ∣ n)

-- Main theorem: Characterization of valid starting values
theorem imo2025_problem4_characterization :
  ∀ a₁ : ℕ, a₁ > 0 →
    (∃ a : ℕ → ℕ, a 1 = a₁ ∧ validSequence a) ↔
    (-- Case 1: Already in State F
     (∃ j m : ℕ, j ≥ 1 ∧ m ≥ 1 ∧ 
      a₁ = 2 * 3^j * m ∧
      (∀ p : ℕ, Nat.Prime p → p ∣ m → p ≥ 7)) ∨
     -- Case 2: Can evolve to State F
     (∃ k j m : ℕ, k ≥ 3 ∧ Odd k ∧ j ≥ (k+1)/2 ∧ m ≥ 1 ∧
      a₁ = 2^k * 3^j * m ∧
      (∀ p : ℕ, Nat.Prime p → p ∣ m → p ≥ 7))) :=
sorry

-- Key lemmas from the solution

-- Lemma 1: Every term in an infinite sequence must be even
lemma infinite_sequence_even (a : ℕ → ℕ) (h : validSequence a) :
  ∀ n : ℕ, n ≥ 1 → Even (a n) :=
sorry

-- Lemma 2: Every term in an infinite sequence must be divisible by 3
lemma infinite_sequence_div3 (a : ℕ → ℕ) (h : validSequence a) :
  ∀ n : ℕ, n ≥ 1 → 3 ∣ (a n) :=
sorry

-- Lemma 3: No term in an infinite sequence can be divisible by 5
lemma infinite_sequence_not_div5 (a : ℕ → ℕ) (h : validSequence a) :
  ∀ n : ℕ, n ≥ 1 → ¬(5 ∣ (a n)) :=
sorry

-- Lemma 4: 2-adic valuation cannot be even ≥ 2 in infinite sequence
lemma v2_not_even_ge2 (a : ℕ → ℕ) (h : validSequence a) :
  ∀ n : ℕ, n ≥ 1 → ¬(∃ s : ℕ, s ≥ 1 ∧ v₂ (a n) = 2*s) :=
sorry

-- Fixed point property
lemma state_f_fixed_point (n : ℕ) (h : isStateF n) :
  f n = n :=
sorry

-- Growth property
lemma state_g_growth (n : ℕ) (h : isStateG n) :
  f n = (13 * n) / 12 :=
sorry

#check imo2025_problem4_characterization