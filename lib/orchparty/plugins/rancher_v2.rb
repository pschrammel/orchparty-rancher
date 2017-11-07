module Orchparty
  class RancherBuilder < HashBuilder
    def scale(num)
      @hash ||= AST.hash
      @hash[:scale]=num
    end
    def upgrade_strategy(&block)
      @hash ||= AST.hash
      @hash[:upgrade_strategy]=HashBuilder.build(block)
    end
    def health_check(&block)
      @hash ||= AST.hash
      @hash[:health_check]=HashBuilder.build(block)
    end
  end

  class ServiceBuilder
    def rancher(&block)
      @node.rancher = RancherBuilder.build(block)
      self
    end
  end
end


module Orchparty
  module Plugin
    module RancherV2
      def self.desc
        "generate rancher-compose.yml v2 file"
      end

      def self.define_flags(c)
        c.flag [:docker_compose,:d], :desc => 'Set the output file'
        c.flag [:rancher_compose,:r], :desc => 'Set the output file'
      end

      def self.generate(ast, options)
        output = rancher_output(ast)
        File.write(options[:rancher_compose], output)
        output = docker_output(ast)
        File.write(options[:docker_compose], output)
      end

      def self.transform_to_yaml(hash)
        hash = hash.deep_transform_values{|v| v.is_a?(Hash) ? v.to_h : v }
        HashUtils.deep_stringify_keys(hash)
      end

      def self.rancher_output(application)
        output_hash = {
          "version" => "2",
           "services" =>
           application.services.map do |name,service|
             service = service.to_h
             rancher= ( service['rancher'] || service[:rancher] || { scale: 1 } ) # some dummy placeholder
             [service.delete(:name), HashUtils.deep_stringify_keys(rancher)]
           end.to_h,
        }
        output_hash.to_yaml(line_width: -1)
      end

      def self.docker_output(application)
        output_hash = {"version" => "2",
                       "services" =>
                       application.services.map do |name,service|
                         service = service.to_h
                         #p service.keys
                         service.delete('rancher')
                         service.delete(:rancher)
                         [service.delete(:name), HashUtils.deep_stringify_keys(service.to_h)]
                       end.to_h,
                      }
        output_hash["volumes"] = transform_to_yaml(application.volumes) if application.volumes && !application.volumes.empty?
        output_hash["networks"] = transform_to_yaml(application.networks) if application.networks && !application.networks.empty?
        output_hash.to_yaml(line_width: -1)
      end

    end
  end
end

Orchparty::Plugin.register_plugin(:rancher_v2, Orchparty::Plugin::RancherV2)
