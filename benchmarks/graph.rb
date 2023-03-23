# frozen_string_literal: true

class GraphGenerator
  def initialize(iterations, data)
    @iterations = iterations
    @data = data
  end

  def generate_ips
    g = graph
    g.title = 'IPS by records'
    g.write('./benchmarks/ips.png')
  end

  def generate_memory
    g = graph
    g.title = 'Memory by records'
    g.write('./benchmarks/memory.png')
  end

  private

  def graph
    g = ::Gruff::Line.new
    g.labels = @iterations.each_with_index.map { |i, index| [index, i] }.to_h
    @data.each do |label, ips|
      g.data label, ips
    end
    g
  end
end
