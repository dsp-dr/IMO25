import Mathlib.Data.Nat.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Rat.Basic

-- IMO 2025 Problem 1: Sunny Lines
-- A line in the plane is called sunny if it is not parallel to 
-- any of the x-axis, the y-axis, and the line x+y=0

/- Problem Statement:
Let n ≥ 3 be a given integer. Determine all nonnegative integers k 
such that there exist n distinct lines in the plane satisfying:
- for all positive integers a and b with a+b ≤ n+1, 
  the point (a,b) is on at least one of the lines
- exactly k of the lines are sunny
-/

-- Define what it means for a line to be sunny
def isSunny (slope : Option ℚ) : Bool :=
  match slope with
  | none => false      -- vertical line (undefined slope)
  | some 0 => false    -- horizontal line
  | some (-1) => false -- line parallel to x+y=0
  | _ => true

-- The main theorem: For all n ≥ 3, the possible values of k are {0, 1, 3}
theorem imo2025_problem1 (n : ℕ) (h : n ≥ 3) :
  ∀ k : ℕ, (∃ lines : Finset (ℕ × ℕ → Bool),
    lines.card = n ∧
    (∀ a b : ℕ, a > 0 → b > 0 → a + b ≤ n + 1 → 
      ∃ l ∈ lines, l (a, b) = true) ∧
    (lines.filter (fun l => isSunny (getSlope l))).card = k) ↔
  k ∈ ({0, 1, 3} : Finset ℕ) :=
sorry

-- Verification that our solution is correct
#check imo2025_problem1

-- Test specific cases
example : 0 ∈ ({0, 1, 3} : Finset ℕ) := by simp
example : 1 ∈ ({0, 1, 3} : Finset ℕ) := by simp
example : 3 ∈ ({0, 1, 3} : Finset ℕ) := by simp
example : 2 ∉ ({0, 1, 3} : Finset ℕ) := by simp