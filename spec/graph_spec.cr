require "./spec_helper"
include Chizge
include Chizge::Exceptions

alias G = Graph

describe G do
  it "works" do
    g = G.new
    g.name.should eq("Graph")
  end

  it "#[]" do
    g = G.new
    g.add_cycle([1, 2, 3, 4])
    g[2].keys.should eq [1, 3]
    g[4].keys.should eq [3, 1]
  end

  it "#to_s" do
    g = G.new
    g.add_cycle([1, 2, 3, 4])
    g.to_s.should contain "Graph (4 nodes): "
  end

  it "#contains?" do
    g = G.new
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
    g = G.new
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
    g = G.new
    g.size.should eq(0)
    g.add_path([1, 2, 3, 4])
    g.add_cycle([4, 5, 6, 7, 1])
    g.size.should eq(16)
  end

  it "#is_path_graph?" do
    g = G.new
    g.add_path([1, 2, 3, 4])
    g.is_path_graph?.should eq(true)
    g.is_cycle_graph?.should eq(false)
  end

  it "#is_cycle_graph?" do
    g = G.new
    g.add_cycle([1, 2, 3, 4])
    g.is_cycle_graph?.should eq(true)
    g.is_path_graph?.should eq(false)
  end

  it "#is_complete_graph?" do
    g = G.new
    g.add_complete([1, 2, 3, 4])
    g.is_complete_graph?.should eq(true)
    g.is_cycle_graph?.should eq(false)
  end

  it "#is_regular_graph?" do
    g = G.new
    g.add_cycle([1, 2, 3, 4])
    g.is_regular_graph?.should eq(true)
    g.clear
    g.add_path([1, 2, 3, 4])
    g.is_regular_graph?.should eq(false)
  end

  it "#nbunch_iter" do
    # TODO: not exactly the same as networkx.
    g = G.new
    g.add_edges_from([{0, 1}, {0, 2}, {1, 2}])
    g.nbunch_iter.to_a.should eq g.node.keys
    g.nbunch_iter(0).to_a.should eq [0]
    g.nbunch_iter([0 as N, 1 as N]).to_a.should eq [0, 1]
    g.nbunch_iter([-1 as N]).to_a.should eq [] of NodeArray
    expect_raises(NodeNotFoundException) { g.nbunch_iter("foo") }
    expect_raises(NodeNotFoundException) { g.nbunch_iter(-1) }
  end
end
