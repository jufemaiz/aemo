class AEMO::Market
  extend HTTParty
  
  def is_valid_state?(state)
    %w(ACT NSW QLD SA TAS VIC).include?(state)
  end
  
  def current_dispath(state)
    if is_valid_state?(state)
      "http://www.nemweb.com.au/mms.GRAPHS/GRAPHS/GRAPH_5#{state}1.csv"
    end
  end
  
  def current_trading(state)
    if is_valid_state?(state)
      "http://www.nemweb.com.au/mms.GRAPHS/GRAPHS/GRAPH_30#{state}1.csv"
    end
  end
  
  def aggregated_price_and_demand
  end
  
end
