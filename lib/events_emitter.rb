module EventsEmitter

  # Returns an array with the callbacks listening on a specific event.
  def listeners(event)
    (@listeners ||= Hash.new{|h, k| h[k] = []})[event]
  end

  # Adds a new listener to the corresponding event.
  def on(event, &block)
    listeners(event) << block
    self
  end

  # Will call each listener for an event in the order they where added
  def emit(event, *args)
     raise ArgumentError.new("Attempted to emit undefined event #{event}") if listeners(event).empty?

    listeners(event).each do |blk|
      blk.call(*args)
    end
  end
end
