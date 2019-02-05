module Payday
  class PrawnTtfDocument < Prawn::Document

    def initialize(*args)
      super
      font_setup
    end

    def font_setup
      self.font_families.update("OpenSans" => {
       :normal => File.join("lib/assets/fonts/OpenSans-Regular.ttf"),
       :italic => File.join("lib/assets/fonts/OpenSans-Italic.ttf"),
       :bold => File.join("lib/assets/fonts/OpenSans-Bold.ttf"),
       :bold_italic => File.join("lib/assets/fonts/OpenSans-Bold-Italic.ttf")
      })
      self.font("OpenSans")
    end
  end
end


