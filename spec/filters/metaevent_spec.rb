require "logstash/devutils/rspec/spec_helper"
require 'logstash/filters/metaevent'

describe LogStash::Filters::Metaevent do
  it 'tries to register the plugin' do
    expect(LogStash::Filters::Metaevent.new({ "followed_by_tags" => "abc" }).register).to eq([])
  end
end
