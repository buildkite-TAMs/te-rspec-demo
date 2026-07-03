RSpec.describe Calculator do
  subject(:calc) { described_class.new }

  describe "#add" do
    it "adds two positive numbers" do
      expect(calc.add(2, 3)).to eq(5)
    end

    it "adds a negative and a positive number" do
      expect(calc.add(-4, 10)).to eq(6)
    end
  end

  describe "#subtract" do
    it "subtracts the second number from the first" do
      expect(calc.subtract(10, 4)).to eq(6)
    end
  end

  describe "#multiply" do
    it "multiplies two numbers" do
      expect(calc.multiply(6, 7)).to eq(42)
    end
  end

  describe "#divide" do
    it "divides two numbers and returns a float" do
      expect(calc.divide(9, 2)).to eq(4.5)
    end

    it "raises ArgumentError when dividing by zero" do
      expect { calc.divide(1, 0) }.to raise_error(ArgumentError, /divide by zero/)
    end
  end
end
