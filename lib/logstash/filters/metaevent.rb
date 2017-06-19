# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"


class LogStash::Filters::Metaevent < LogStash::Filters::Base
  config_name "metaevent"

  # syntax: `followed_by_tags => [ "tag", "tag" ]`
  config :followed_by_tags, :validate => :array, :required => true

  # syntax: `period => 60`
  config :period, :validate => :number, :default => 5

  def register
    @logger.debug("registering")
    @metaevents = []
  end

  def filter(event)
    if filter?(event)
      start_period(event)
    elsif within_period(event)
      if followed_by_tags_match(event)
        trigger(event)
      else
        @logger.debug(["metaevent", @add_tag, "ignoring (tags don't match)", event])
      end
    else
      @logger.debug(["metaevent", @add_tag, "ignoring (not in period)", event])
    end
  end

  def flush
    return if @metaevents.empty?

    new_events = @metaevents
    @metaevents = []
    new_events
  end

  private

  def start_period(event)
    @logger.debug(["metaevent", @add_tag, "start_period", event])
    @start_event = event
  end

  def trigger(event)
    @logger.debug(["metaevent", @add_tag, "trigger", event])

    event = LogStash::Event.new
    event.set("source", Socket.gethostname)
    event.set("tags", [@add_tag])

    @metaevents << event
    @start_event = nil
  end

  def followed_by_tags_match(event)
    (event.get("tags") & @followed_by_tags).size == @followed_by_tags.size
  end

  def within_period(event)
    time_delta = event.get("@timestamp") - @start_event["@timestamp"]
    time_delta >= 0 && time_delta <= @period
  end
end
