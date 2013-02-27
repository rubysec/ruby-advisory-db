require 'spec_helper'
require 'yaml'

shared_examples_for 'Advisory' do |path|
  advisory = YAML.load_file(path)

  describe path do
    let(:gem) { File.basename(File.dirname(path)) }
    let(:cve) { File.basename(path).chomp('.yml') }

    describe "gem" do
      subject { advisory['gem'] }

      it { should be_kind_of(String) }
      it { should == gem }
    end

    describe "framework" do
      subject { advisory['framework'] }

      it "may be nil or a String" do
        [NilClass, String].should include(subject.class)
      end
    end

    describe "cve" do
      subject { advisory['cve'] }

      it { should be_kind_of(String) }
      it { should == cve }
    end

    describe "url" do
      subject { advisory['url'] }

      it { should be_kind_of(String) }
      it { should_not be_empty }
    end

    describe "title" do
      subject { advisory['title'] }

      it { should be_kind_of(String) }
      it { should_not be_empty }
    end

    describe "description" do
      subject { advisory['description'] }

      it { should be_kind_of(String) }
      it { should_not be_empty }
    end

    describe "cvss_v2" do
      subject { advisory['cvss_v2'] }

      it "may be nil or a Float" do
        [NilClass, Float].should include(subject.class)
      end

      case advisory['cvss_v2']
      when Float
        context "when a Float" do
          it { ((0.0)..(10.0)).should include(subject) }
        end
      end
    end

    describe "patched_versions" do
      subject { advisory['patched_versions'] }

      it { should be_kind_of(Array) }
      it { should_not be_empty }

      advisory['patched_versions'].each do |version|
        describe version do
          subject { version.split(', ') }

          it "should contain valid RubyGem version requirements" do
            lambda {
              Gem::Requirement.new(version)
            }.should_not raise_error(ArgumentError)
          end
        end
      end
    end

    describe "unaffected_versions" do
      subject { advisory['unaffected_versions'] }

      it "may be nil or a Array" do
        [NilClass, Array].should include(subject.class)
      end

      case advisory['unaffected_versions']
      when Array
        advisory['unaffected_versions'].each do |version|
          describe version do
            subject { version.split(', ') }
            
            it "should contain valid RubyGem version requirements" do
              lambda {
                Gem::Requirement.new(version)
              }.should_not raise_error(ArgumentError)
            end
          end
        end
      end
    end
  end
end
