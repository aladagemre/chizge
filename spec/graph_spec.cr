require "./spec_helper"

it Chizge::Graph do
  it "works" do
    g = Chizge::Graph.new
    g.name.should eq("Graph")
  end

  it "#[]" do
    g = Chizge::Graph.new
    g.add_cycle([1, 2, 3, 4])
    g[2].keys.should eq [1, 3]
    g[4].keys.should eq [3, 1]
  end

  it "#to_s" do
    g = Chizge::Graph.new
    g.add_cycle([1, 2, 3, 4])
    g.to_s.should contain "Graph (4 nodes): "
  end

  it "#contains?" do
    g = Chizge::Graph.new
    g.add_cycle([1, 2, 3, 4])

    # Node
    [1, 2, 3, 4].map { |x| g.contains?(x).should be_true }
    g.contains?(5).should be_false
    # Edge
    g.contains?(1, 2).should be_true
    g.contains?(4, 1).should be_true
    g.contains?(1, 4).should be_true
    g.contains?(1, 5).should be_false
    g.contains?(6, 7).should be_false
  end

  it "#add_node" do
    g = Chizge::Graph.new
    g.add_node(0)
    g.add_cycle([1, 2, 3, 4])
    g.number_of_nodes.should eq 5
    g.get_node_data(4).size.should eq 0
    g.add_node(4, {"weight" => 13.3 as Chizge::Attr})
    g.get_node_data(4).size.should eq 1
    g.get_node_data(4)["weight"].should eq 13.3
    g.add_node(4, {"weight" => 9 as Chizge::Attr})
    g.get_node_data(4)["weight"].should eq 9
    g.number_of_nodes.should eq 5
  end

  it "#size" do
    g = Chizge::Graph.new
    g.size.should eq(0)
    g.add_path([1, 2, 3, 4])
    g.add_cycle([4, 5, 6, 7, 1])
    g.size.should eq(16)
  end
end
