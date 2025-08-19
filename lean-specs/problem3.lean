import Mathlib.Data.Nat.Basic
import Mathlib.Data.Real.Basic
import Mathlib.NumberTheory.Divisors

-- IMO 2025 Problem 3: Bonza Functions
-- A function f:ℕ→ℕ is "bonza" if f(a) divides b^a - f(b)^f(a) for all positive integers a and b

/- Problem Statement:
Let ℕ denote the set of positive integers. A function f:ℕ→ℕ is said to be bonza if 
f(a) divides b^a - f(b)^f(a) for all positive integers a and b.

Determine the smallest real constant c such that f(n) ≤ cn for all bonza functions f 
and all positive integers n.
-/

-- Define what it means to be a bonza function
def isBonza (f : ℕ → ℕ) : Prop :=
  ∀ a b : ℕ, a > 0 → b > 0 → (f a) ∣ (b^a - (f b)^(f a))

-- Key property: For any bonza function f, f(a) divides a^a
lemma bonza_divides_power (f : ℕ → ℕ) (h : isBonza f) :
  ∀ a : ℕ, a > 0 → (f a) ∣ a^a :=
sorry

-- The identity function is bonza
def identity_bonza : isBonza id :=
sorry

-- The constant function f(n) = 1 is bonza
def constant_one_bonza : isBonza (fun _ => 1) :=
sorry

-- Main theorem: The smallest constant c is 1
theorem imo2025_problem3 :
  (∃ c : ℝ, c > 0 ∧
    (∀ f : ℕ → ℕ, isBonza f → ∀ n : ℕ, n > 0 → (f n : ℝ) ≤ c * n) ∧
    (∀ c' : ℝ, c' > 0 → 
      (∀ f : ℕ → ℕ, isBonza f → ∀ n : ℕ, n > 0 → (f n : ℝ) ≤ c' * n) → 
      c ≤ c')) ∧
  (∀ c : ℝ, (c > 0 ∧
    (∀ f : ℕ → ℕ, isBonza f → ∀ n : ℕ, n > 0 → (f n : ℝ) ≤ c * n) ∧
    (∀ c' : ℝ, c' > 0 → 
      (∀ f : ℕ → ℕ, isBonza f → ∀ n : ℕ, n > 0 → (f n : ℝ) ≤ c' * n) → 
      c ≤ c')) → c = 1) :=
sorry

-- Characterization: There are exactly two bonza functions (claimed, but with gap in proof)
-- Note: The proof in the solution has a critical error for the case where S is finite non-empty
conjecture bonza_characterization :
  ∀ f : ℕ → ℕ, isBonza f → (f = id ∨ f = fun _ => 1) :=
sorry

#check imo2025_problem3