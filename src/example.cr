require "./chizge/*"

G = Chizge::Graph.new
G.add_path([1,2,3,4,5])
G.add_node(6)
G.add_edge(4, 6)
G.add_edge(4, 5, {"weight" => 10.0 as Chizge::Attr})
puts G.number_of_nodes
puts G.size
puts G.size(weight="weight")
G.degree([] of Chizge::Node, "weight") do |x|
    puts x
end
