import Mathlib.Data.Real.Basic
import Mathlib.Data.Real.Sqrt
import Mathlib.Tactic

-- IMO 2025 Problem 5: The Inekoalaty Game

/- Problem Statement:
Alice and Bazza are playing the inekoalaty game, a two-player game whose rules depend on 
a positive real number λ which is known to both players. On the n-th turn of the game 
(starting with n=1) the following happens:
- If n is odd, Alice chooses a nonnegative real number xₙ such that
  x₁ + x₂ + ⋯ + xₙ ≤ λn
- If n is even, Bazza chooses a nonnegative real number xₙ such that
  x₁² + x₂² + ⋯ + xₙ² ≤ n

If a player cannot choose a suitable number xₙ, the game ends and the other player wins.
If the game goes forever, neither player wins. All chosen numbers are known to both players.

Determine all values of λ for which Alice has a winning strategy and all those for which 
Bazza has a winning strategy.
-/

-- Game state: sequence of moves and current turn
structure GameState where
  moves : List ℝ
  turn : ℕ
  deriving Inhabited

-- Sum of moves
def sumMoves (moves : List ℝ) : ℝ := moves.sum

-- Sum of squares of moves
def sumSquares (moves : List ℝ) : ℝ := (moves.map (· ^ 2)).sum

-- Valid move for Alice (odd turns)
def validAliceMove (λ : ℝ) (state : GameState) (x : ℝ) : Prop :=
  Odd state.turn ∧ x ≥ 0 ∧ 
  sumMoves state.moves + x ≤ λ * state.turn

-- Valid move for Bazza (even turns)
def validBazzaMove (state : GameState) (x : ℝ) : Prop :=
  Even state.turn ∧ x ≥ 0 ∧
  sumSquares state.moves + x^2 ≤ state.turn

-- Player has a legal move
def hasLegalMove (λ : ℝ) (state : GameState) : Prop :=
  if Odd state.turn then
    ∃ x : ℝ, validAliceMove λ state x
  else
    ∃ x : ℝ, validBazzaMove state x

-- Winning strategy definitions
def AliceWins (λ : ℝ) : Prop :=
  ∃ (strategy : GameState → ℝ),
    ∀ (game : ℕ → GameState),
      (∀ n : ℕ, Odd n → validAliceMove λ (game n) (strategy (game n))) →
      (∃ m : ℕ, Even m ∧ ¬hasLegalMove λ (game m))

def BazzaWins (λ : ℝ) : Prop :=
  ∃ (strategy : GameState → ℝ),
    ∀ (game : ℕ → GameState),
      (∀ n : ℕ, Even n → validBazzaMove (game n) (strategy (game n))) →
      (∃ m : ℕ, Odd m ∧ ¬hasLegalMove λ (game m))

-- The critical threshold value
noncomputable def λ_critical : ℝ := Real.sqrt 2 / 2

-- Main theorem: Alice wins if λ > √2/2, Bazza wins if λ < √2/2
theorem imo2025_problem5 :
  (∀ λ : ℝ, λ > 0 → λ > λ_critical → AliceWins λ) ∧
  (∀ λ : ℝ, λ > 0 → λ < λ_critical → BazzaWins λ) ∧
  (∀ λ : ℝ, λ = λ_critical → ¬AliceWins λ ∧ ¬BazzaWins λ) :=
sorry

-- Key lemmas from the solution

-- Under optimal play, after m pairs of turns: S_{2m} = m√2 and Q_{2m} = 2m
lemma optimal_trajectory (λ : ℝ) (m : ℕ) :
  ∃ (moves : List ℝ),
    moves.length = 2*m ∧
    sumMoves moves = m * Real.sqrt 2 ∧
    sumSquares moves = 2*m :=
sorry

-- Alice's optimal defensive move minimizes sum increase
lemma alice_defensive_move (x : ℝ) (h : 0 ≤ x ∧ x ≤ Real.sqrt 2) :
  x + Real.sqrt (2 - x^2) ≥ Real.sqrt 2 :=
sorry

-- The minimum is achieved at x = 0 or x = √2
lemma alice_optimal_choices :
  ∀ x : ℝ, 0 ≤ x ∧ x ≤ Real.sqrt 2 →
    x + Real.sqrt (2 - x^2) = Real.sqrt 2 ↔ (x = 0 ∨ x = Real.sqrt 2) :=
sorry

-- Bazza's optimal strategy
lemma bazza_optimal_move (Q_prev : ℝ) (m : ℕ) (h : Q_prev ≤ 2*m) :
  ∃ x : ℝ, x = Real.sqrt (2*m - Q_prev) ∧ x ≥ 0 :=
sorry

-- Alice can win by playing x > √2 when budget allows
lemma alice_winning_move (λ : ℝ) (m : ℕ) :
  λ > m * Real.sqrt 2 / (2*m - 1) →
  ∃ x : ℝ, x > Real.sqrt 2 ∧ 
    (m - 1) * Real.sqrt 2 + x ≤ λ * (2*m - 1) :=
sorry

#check imo2025_problem5