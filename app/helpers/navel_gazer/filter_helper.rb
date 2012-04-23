module NavelGazer
  module FilterHelper  

    # Make sure exceptions get logged instead of swallowed up into a generic 
    # 500 error about incomplete headers
    def catch_exceptions
      yield
    rescue => exception
      logger.error "[FilterHelper#catch_exceptions] #{exception}"
      exception.backtrace.each { |b| logger.error b }
      raise
    end
  
  end
end