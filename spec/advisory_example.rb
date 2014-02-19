load File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'yaml'

shared_examples_for 'Advisory' do |path|
  advisory = YAML.load_file(path)

  describe path do
    let(:gem) { File.basename(File.dirname(path)) }
    let(:filename_cve) do
      if File.basename(path).start_with?('CVE-')
        File.basename(path).gsub('CVE-','').chomp('.yml')
      else
        nil
      end
    end
    let(:filename_osvdb) do
      if File.basename(path).start_with?('OSVDB-')
        File.basename(path).gsub('OSVDB-','').chomp('.yml')
      else
        nil
      end
    end

    it "should have CVE or OSVDB" do
      (advisory['cve'] || advisory['osvdb']).should_not be_nil
    end

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

    describe "platform" do
      subject { advisory['platform'] }

      it "may be nil or a String" do
        [NilClass, String].should include(subject.class)
      end
    end

    describe "cve" do
      subject { advisory['cve'] }

      it "may be nil or a String" do
        [NilClass, String].should include(subject.class)
      end
      it "should be id in filename if filename is CVE-XXX" do
        if filename_cve
          should == filename_cve
        end
      end
    end

    describe "osvdb" do
      subject { advisory['osvdb'] }
      it "may be nil or a Fixnum" do
        [NilClass, Fixnum].should include(subject.class)
      end
       it "should be id in filename if filename is OSVDB-XXX" do
        if filename_osvdb
          should == filename_osvdb.to_i
        end
      end
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

    describe "date" do
      subject { advisory['date'] }

      it { should be_kind_of(Date) }
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

      it "may be nil or an Array" do
        [NilClass, Array].should include(subject.class)
      end

      describe "each patched version" do
        if advisory['patched_versions']
          advisory['patched_versions'].each do |version|
            describe version do
              subject { version.split(', ') }
              
              it "should contain valid RubyGem version requirements" do
                lambda {
                Gem::Requirement.new(*subject)
                }.should_not raise_error
              end
            end
          end
        end
      end
    end

    describe "unaffected_versions" do
      subject { advisory['unaffected_versions'] }

      it "may be nil or an Array" do
        [NilClass, Array].should include(subject.class)
      end

      case advisory['unaffected_versions']
      when Array
        advisory['unaffected_versions'].each do |version|
          describe version do
            subject { version.split(', ') }
            
            it "should contain valid RubyGem version requirements" do
              lambda {
                Gem::Requirement.new(*subject)
              }.should_not raise_error
            end
          end
        end
      end
    end
  end
end
