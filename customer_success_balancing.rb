require 'minitest/autorun'
require 'timeout'

class CustomerSuccessBalancing
	def initialize(customer_success, customers, away_customer_success)
		@customer_success = customer_success
		@customers = customers
		@away_customer_success = away_customer_success
	end
	# Returns the ID of the customer success with most customers
	def execute
		# Write your solution here

		customer_success_with_most_clients = -1
		highest_client_quantity = 0

		active_customer_success = @customer_success.reject {|cs| @away_customer_success.include? cs[:id]}

		active_customer_success_ordered_by_minimun_score = active_customer_success.sort {|a,b| a[:score] -  b[:score]}


		active_customer_success_ordered_by_minimun_score.each do |current_customer_success| 
			client_quantity = 0

			@customers.each do |customer| 
				is_cs_matches_customer_score = customer[:score] <= current_customer_success[:score]
				is_customer_not_assigned = !customer[:assigned]

				if is_cs_matches_customer_score && is_customer_not_assigned
					client_quantity = client_quantity + 1
					customer[:assigned] = true
				end
			end

			if client_quantity > highest_client_quantity
				highest_client_quantity = client_quantity
				customer_success_with_most_clients = current_customer_success[:id]

			elsif  client_quantity === highest_client_quantity
				customer_success_with_most_clients = 0
			end
		end
    
		return customer_success_with_most_clients
	end
end


class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 6, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
