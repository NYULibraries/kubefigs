#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

def set_source_path(source_path)
  @source_path = source_path
end

def get_source_path
  @source_path
end

def set_variables_path(variables_path)
  @variables_path = variables_path
end

def get_variables_path
  @variables_path ||= File.join(directory, "_variables.yml")
end

def get_template_paths
  raise "File or directory '#{source_path}' does not exist" unless File.exist?(get_source_path)

  if File.file?(get_source_path)
    [get_source_path]
  else
    template_paths = Dir[File.join(get_source_path, "*.tpl")]
    raise "Directory '#{source_path}' has no template files (*.tpl)" if template_paths.empty?
    template_paths
  end
end

def template_paths
  @template_paths ||= get_template_paths
end

def directory
  @directory ||= File.dirname(template_paths[0])
end

def get_templates
  template_paths.map do
    |path| [path, File.open(path){|f| f.read }]
  end.to_h
end

def templates
  @templates ||= get_templates
end

def get_variables
  variables_path = ARGV[1] || get_variables_path
  File.open(variables_path){|f| YAML.load f }
end

def variables
  @variables ||= get_variables
end

def get_environment_dir(parent_dir, environment)
  env_dir = File.join(parent_dir, environment)
  FileUtils.mkdir(env_dir) unless File.directory?(env_dir)
  env_dir
end

def environment_template_path(environment_dir, source_template_path)
  basename = File.basename(source_template_path).gsub(/\.tpl\z/, '')
  File.join(environment_dir, basename)
end

def inject_variables(template, vars_hash)
  vars_hash.inject(template) do |result, (variable, value)|
    result.gsub("${#{variable}}", value || "")
  end
end

def kubefigs(source_path, variables_path=nil, verbose: false)
  set_source_path(source_path)
  set_variables_path(variables_path)

  variables.each do |environment, vars_hash|
    env_dir = get_environment_dir(directory, environment)

    templates.each do |source_path, template|
      output_path = environment_template_path(env_dir, source_path)
      output = inject_variables(template, vars_hash)

      File.open(output_path, 'w'){|f| f.write(output) }

      puts "Wrote: #{output_path}" if verbose
    end
  end
end

if $0 == __FILE__
  raise "Usage: #{$0} <file_or_directory_path>" unless ARGV[0]
  kubefigs(ARGV[0], ARGV[1], verbose: true)
end
