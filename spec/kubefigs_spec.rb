require_relative '../kubefigs'

RSpec.describe "./kubefigs.rb" do
  describe "kubefigs" do
    let(:fixtures_dir){ File.join(File.dirname(__FILE__), "fixtures") }

    let(:cats_dir){ File.join(fixtures_dir, "cats") }
    let(:dogs_dir){ File.join(fixtures_dir, "dogs") }
    let(:cats_config1_path){ File.join(cats_dir, "config1.yml") }
    let(:cats_config2_path){ File.join(cats_dir, "config2.yml") }
    let(:dogs_config1_path){ File.join(dogs_dir, "config1.yml") }
    let(:dogs_config2_path){ File.join(dogs_dir, "config2.yml") }
    let(:cats_config1){ File.open(cats_config1_path){|f| YAML.load f } }
    let(:cats_config2){ File.open(cats_config2_path){|f| YAML.load f } }
    let(:dogs_config1){ File.open(dogs_config1_path){|f| YAML.load f } }
    let(:dogs_config2){ File.open(dogs_config2_path){|f| YAML.load f } }

    after do
      FileUtils.rm_rf(cats_dir)
      FileUtils.rm_rf(dogs_dir)
    end

    context "when supplied a path" do
      before { kubefigs(fixtures_dir) }

      it "should create two directories" do
        expect(File.directory?(cats_dir)).to eq true
        expect(File.directory?(dogs_dir)).to eq true
      end

      it "should interpolate variables" do
        expect(cats_config1['config']['default_pet']).to eq "fluffy"
        expect(cats_config1['config']['my_pets']).to match_array %w[fluffy whiskers]
        expect(cats_config2['config']['whiskers']).to_not eq nil
        expect(dogs_config1['config']['default_pet']).to eq "collie"
        expect(dogs_config1['config']['my_pets']).to match_array %w[collie daschund]
        expect(dogs_config2['config']['daschund']).to_not eq nil
      end

      it "should only add those two files" do
        expect(Dir[File.join(cats_dir, '*')]).to match_array [cats_config1_path, cats_config2_path]
        expect(Dir[File.join(dogs_dir, '*')]).to match_array [dogs_config1_path, dogs_config2_path]
      end
    end

    context "when supplied a filename" do
      before { kubefigs(File.join(fixtures_dir, "config1.yml.tpl")) }

      it "should create two directories" do
        expect(File.directory?(cats_dir)).to eq true
        expect(File.directory?(dogs_dir)).to eq true
      end

      it "should interpolate variables" do
        expect(cats_config1['config']['default_pet']).to eq "fluffy"
        expect(cats_config1['config']['my_pets']).to match_array %w[fluffy whiskers]
        expect(dogs_config1['config']['default_pet']).to eq "collie"
        expect(dogs_config1['config']['my_pets']).to match_array %w[collie daschund]
      end

      it "should only add specified file" do
        expect(Dir[File.join(cats_dir, '*')]).to match_array [cats_config1_path]
        expect(Dir[File.join(dogs_dir, '*')]).to match_array [dogs_config1_path]
      end
    end
  end
end
