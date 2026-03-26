require "yaml"

RSpec.describe "Check Advisory indentation formatting" do
  Dir.glob("gems/**/**/*.yml").each do |file|
    context file do
      let(:lines) { File.readlines(file) }

      it "does not contain lines starting with '- '" do
        bad = lines.select { |l| l.match?(/^- /) }
        expect(bad).to be_empty, "Found lines starting with '- ':\n#{bad.join}"
      end

      it "does not contain lines starting with '  - http'" do
        bad = lines.select { |l| l.match?(/^  - http/) }
        expect(bad).to be_empty, "Found lines starting with '  - http':\n#{bad.join}"
      end
    end
  end

  Dir.glob("rubies/**/**/*.yml").each do |file|
    context file do
      let(:lines) { File.readlines(file) }

      it "does not contain lines starting with '- '" do
        bad = lines.select { |l| l.match?(/^- /) }
        expect(bad).to be_empty, "Found lines starting with '- ':\n#{bad.join}"
      end

      it "does not contain lines starting with '  - http'" do
        bad = lines.select { |l| l.match?(/^  - http/) }
        expect(bad).to be_empty, "Found lines starting with '  - http':\n#{bad.join}"
      end
    end
  end
end
