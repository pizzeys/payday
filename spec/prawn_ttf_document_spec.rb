require "spec_helper"

module Payday
  RSpec.describe PrawnTtfDocument do
      context 'with language - specific characters' do
        it 'does not raise error' do
          pdf = PrawnTtfDocument.new
          expect{
            pdf.text ('Master HA 하선생')
            pdf.render
          }.not_to raise_error
        end
      end
  end
end
