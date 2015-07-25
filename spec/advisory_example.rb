load File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'yaml'

shared_examples_for 'Advisory' do |path|
  advisory = YAML.load_file(path)

  describe path do
    let(:filename_cve) do
      if File.basename(path).start_with?('CVE-')
        File.basename(path).gsub('CVE-','').chomp('.yml')
      end
    end

    let(:filename_osvdb) do
      if File.basename(path).start_with?('OSVDB-')
        File.basename(path).gsub('OSVDB-','').chomp('.yml')
      end
    end

    it "should have CVE or OSVDB" do
      expect(advisory['cve'] || advisory['osvdb']).not_to be_nil
    end

   
    describe "framework" do
      subject { advisory['framework'] }

      it "may be nil or a String" do
        expect(subject).to be_kind_of(String).or(be_nil)
      end
    end

    describe "platform" do
      subject { advisory['platform'] }

      it "may be nil or a String" do
        expect(subject).to be_kind_of(String).or(be_nil)
      end
    end

    describe "cve" do
      subject { advisory['cve'] }

      it "may be nil or a String" do
        expect(subject).to be_kind_of(String).or(be_nil)
      end
      it "should be id in filename if filename is CVE-XXX" do
        if filename_cve
          is_expected.to eq(filename_cve)
        end
      end
    end

    describe "osvdb" do
      subject { advisory['osvdb'] }

      it "may be nil or a Fixnum" do
        expect(subject).to be_kind_of(Fixnum).or(be_nil)
      end

       it "should be id in filename if filename is OSVDB-XXX" do
        if filename_osvdb
          is_expected.to eq(filename_osvdb.to_i)
        end
      end
    end

    describe "url" do
      subject { advisory['url'] }

      it { is_expected.to be_kind_of(String) }
      it { is_expected.not_to be_empty }
    end

    describe "title" do
      subject { advisory['title'] }

      it { is_expected.to be_kind_of(String) }
      it { is_expected.not_to be_empty }
    end

    describe "date" do
      subject { advisory['date'] }

      it { is_expected.to be_kind_of(Date) }
    end

    describe "description" do
      subject { advisory['description'] }

      it { is_expected.to be_kind_of(String) }
      it { is_expected.not_to be_empty }
    end

    describe "cvss_v2" do
      subject { advisory['cvss_v2'] }

      it "may be nil or a Float" do
        expect(subject).to be_kind_of(Float).or(be_nil)
      end

      case advisory['cvss_v2']
      when Float
        context "when a Float" do
          it { expect((0.0)..(10.0)).to include(subject) }
        end
      end
    end

    describe "patched_versions" do
      subject { advisory['patched_versions'] }

      it "may be nil or an Array" do
        expect(subject).to be_kind_of(Array).or(be_nil)
      end

      describe "each patched version" do
        if advisory['patched_versions']
          advisory['patched_versions'].each do |version|
            describe version do
              subject { version.split(', ') }
              
              it "should contain valid RubyGem version requirements" do
                expect {
                Gem::Requirement.new(*subject)
                }.not_to raise_error
              end
            end
          end
        end
      end
    end

    describe "unaffected_versions" do
      subject { advisory['unaffected_versions'] }

      it "may be nil or an Array" do
        expect(subject).to be_kind_of(Array).or(be_nil)
      end

      case advisory['unaffected_versions']
      when Array
        advisory['unaffected_versions'].each do |version|
          describe version do
            subject { version.split(', ') }
            
            it "should contain valid RubyGem version requirements" do
              expect {
                Gem::Requirement.new(*subject)
              }.not_to raise_error
            end
          end
        end
      end
    end
  end
end
