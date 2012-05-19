module NavelGazer
  class ApplicationController < ActionController::Base
    include FilterHelper
    before_filter :load_hbs_helpers

    def load_hbs_helpers
      NavelGazer::HandlebarsConfig.register_partials
    end
  end
end
