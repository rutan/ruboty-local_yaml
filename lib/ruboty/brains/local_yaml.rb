require 'yaml'

module Ruboty
  module Brains
    class LocalYAML < Base
      env :LOCAL_YAML_PATH, 'Yaml path', optional: true
      env :LOCAL_YAML_SAVE_INTERVAL, 'Interval time to write', optional: true

      def initialize
        super
        @thread = Thread.new { sync }
        @thread.abort_on_exception = true
      end

      def data
        @data ||= pull || {}
      end

      private

      def push
        yaml = data.to_yaml
        return if yaml == @old_yaml
        File.open(file_path, 'w') { |f| f.write yaml }
        @old_yaml = yaml
      end

      def pull
        return nil unless File.exist?(file_path)
        YAML.load File.read(file_path)
      end

      def sync
        loop do
          wait
          push
        end
      end

      def wait
        sleep(interval)
      end

      def file_path
        (ENV['LOCAL_YAML_PATH'] || './ruboty.yml')
      end

      def interval
        (ENV['LOCAL_YAML_SAVE_INTERVAL'] || 5).to_i
      end
    end
  end
end
