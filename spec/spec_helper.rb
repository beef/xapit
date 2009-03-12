require 'rubygems'
require 'spec'
require 'active_support'
require 'fileutils'
require File.dirname(__FILE__) + '/../lib/xapit.rb'

Spec::Runner.configure do |config|
  config.mock_with :rr
end

class XapitMember
  include Xapit::Membership
  
  attr_reader :id
  
  def self.each(&block)
    @@records.each(&block) if @@records
  end
  
  def self.delete_all
    @@records = []
  end
  
  def self.find(id)
    @@records.detect { |r| r.id == id.to_i }
  end
  
  def initialize(attributes = {})
    @@records ||= []
    @id = @@records.size + 1
    @attributes = attributes
    @@records << self
  end
  
  def method_missing(name, *args)
    if @attributes.has_key? name
      @attributes[name]
    else
      super
    end
  end
end
