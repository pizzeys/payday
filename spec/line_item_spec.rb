require "spec_helper"

module Payday
  describe LineItem do
    it "should be able to be initilized with a price" do
      li = LineItem.new(price: BigDecimal("20"))
      expect(li.price).to eq(BigDecimal("20"))
    end

    it "should be able to be initialized with a quantity" do
      li = LineItem.new(quantity: 30)
      expect(li.quantity).to eq(BigDecimal("30"))
    end

    it "should be able to be initlialized with a description" do
      li = LineItem.new(description: "12 Pairs of Pants")
      expect(li.description).to eq("12 Pairs of Pants")
    end

    it "should return the correct amount" do
      li = LineItem.new(price: 10, quantity: 12)
      expect(li.amount).to eq(BigDecimal("120"))
    end
  end
end
