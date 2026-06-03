require 'spec_helper'

require 'json_schemer'
require 'yaml'

SCHEMAS_DIR = File.join(ROOT, 'spec', 'schemas')

def schemer_for(schema_path)
  JSONSchemer.schema(
    JSON.parse(File.read(schema_path)),
    meta_schema: 'https://json-schema.org/draft/2020-12/schema'
  )
end

def normalize_for_json(value)
  case value
  when Hash
    value.transform_values { |v| normalize_for_json(v) }
  when Array
    value.map { |v| normalize_for_json(v) }
  when Date
    value.iso8601
  else
    value
  end
end

def raw_yaml_field_checks(data)
  errors = []

  if data.key?('date') && !data['date'].is_a?(Date)
    errors << {
      'data_pointer' => '/date',
      'error' => 'value must be a YAML date'
    }
  end

  %w[cvss_v2 cvss_v3 cvss_v4].each do |field|
    next unless data.key?(field)

    value = data[field]
    next if value.is_a?(Float)

    errors << {
      'data_pointer' => "/#{field}",
      'error' => 'value must be a float'
    }
  end

  errors
end

def format_errors(errors)
  errors.map do |e|
    pointer = e['data_pointer'].to_s.empty? ? '<root>' : e['data_pointer']

    "↳ #{pointer}: #{e['error']}"
  end.join("\n")
end

GEM_SCHEMER  = schemer_for(File.join(SCHEMAS_DIR, 'gem.json'))
RUBY_SCHEMER = schemer_for(File.join(SCHEMAS_DIR, 'ruby.json'))

shared_examples 'conforming schema' do |glob:, schemer:|
  Dir.glob(File.join(ROOT, glob)).sort.each do |path|
    filename = path.split('/')[-2..].join('/')

    it "#{filename} conforms to schema" do
      raw_data = YAML.safe_load_file(path, permitted_classes: [Date])
      data = normalize_for_json(raw_data)
      errors = raw_yaml_field_checks(raw_data) + schemer.validate(data).to_a

      expect(errors).to be_empty, lambda {
        "#{filename}\n#{format_errors(errors)}"
      }
    end
  end
end

describe 'JSON Schema validation' do
  describe 'for gems' do
    include_examples 'conforming schema',
                     glob: 'gems/*/*.yml',
                     schemer: GEM_SCHEMER
  end

  describe 'for rubies' do
    include_examples 'conforming schema',
                     glob: 'rubies/*/*.yml',
                     schemer: RUBY_SCHEMER
  end
end
