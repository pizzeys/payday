require "fileutils"

# Usage: expect(renderer.render).to match_binary_asset('pdf/test.pdf')
RSpec::Matchers.define(:match_binary_asset) do |file_name|
  match do |actual_output|
    expected_path = File.join("spec/assets", file_name)
    expected_output = File.binread(expected_path)

    (actual_output == expected_output).tap do |result|
      unless result
        output_path = File.join("tmp/rendered_output", file_name)

        FileUtils.mkdir_p(File.dirname(output_path))
        File.open(output_path, "wb") { |f| f.write actual_output }
      end
    end
  end

  failure_message do |_actual_output|
    expected_output_path = File.join("spec/assets", file_name)
    actual_output_path = File.join("tmp/rendered_output", file_name)

    "expected output to match '#{expected_output_path}' "\
      "(see #{actual_output_path})"
  end
end
