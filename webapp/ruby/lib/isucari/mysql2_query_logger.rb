require 'logger'
require 'json'

module Mysql2QueryLogger
  class Logger
    def initialize(file:, root_dir:, ignore_fast_query:)
      @root_dir = root_dir
      @ignore_fast_query = ignore_fast_query
      @logger = ::Logger.new(file)
      @logger.formatter = proc { |severity, datetime, progname, message|
        message + "\n"
      }
    end

    def log(duration, sql, callers)
      if type(duration) == :fast && @ignore_fast_query
        return
      end
      message = "#{process_duration(duration)} #{sql} #{process_caller(callers)}"
      @logger.info(message)
    end

    private

    def type(duration)
      case
      when duration < 0.01
        :fast
      when duration < 0.1
        :warning
      else
        :slow
      end
    end

    def process_duration(duration)
      color = case type(duration)
        when :fast    then; :green
        when :warning then; :yellow
        when :slow    then; :red
      end
      colorize(color, "(#{(duration * 1000).round(1)}ms)")
    end

    def process_caller(callers)
      line = callers[1..-1].find {|c| c.match?('/gems/') === false }
      if line && /^(.+?):(\d+)/ =~ line
        file = $1
        line_num = $2
        if @root_dir
          file.sub!("#{@root_dir}/", "")
        end
        colorize(:gray, "#{file}:#{line_num}")
      else
        colorize(:gray, "unknown")
      end
    end

    def colorize(color, str)
      case color
      when :red
        "\e[31m#{str}\e[0m"
      when :green
        "\e[32m#{str}\e[0m"
      when :yellow
        "\e[33m#{str}\e[0m"
      when :gray
        "\e[90m#{str}\e[0m"
      end
    end
  end

  def self.enable!(file: STDOUT, root_dir: nil, ignore_fast_query: false)
    Mysql2::Client.prepend(Mysql2QueryLogger::ClientMethods)
    Mysql2::Statement.prepend(Mysql2QueryLogger::StatementMethods)
    @logger = Mysql2QueryLogger::Logger.new(file: file, root_dir: root_dir, ignore_fast_query: ignore_fast_query)
  end

  def self.execute(sql)
    start = Time.now
    result = yield
    duration = Time.now - start

    @logger.log(duration, sql, caller)

    result
  end

  module ClientMethods
    def prepare(sql)
      super.tap { |stmt| stmt.instance_variable_set(:@_sql, sql) }
    end

    def query(sql, options = {})
      Mysql2QueryLogger.execute(sql) { super }
    end
  end

  module StatementMethods
    def execute(*args)
      Mysql2QueryLogger.execute(@_sql) { super }
    end
  end
end
