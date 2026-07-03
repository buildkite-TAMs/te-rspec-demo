# A tiny library "under test". Deliberately trivial — the point of this repo is
# the Test Engine wiring, not the business logic.
class Calculator
  def add(a, b) = a + b
  def subtract(a, b) = a - b
  def multiply(a, b) = a * b

  def divide(a, b)
    raise ArgumentError, "cannot divide by zero" if b.zero?

    a.to_f / b
  end
end
