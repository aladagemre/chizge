require "./chizge/*"

g = Chizge::Graph.new
g.add_path([1, 2, 3, 4, 5])
g.add_node(6)
g.add_edge(4, 6)
g.add_edge(4, 5, {"weight" => 10.0 as Chizge::Attr})
puts g.get_edge_data(4, 10, -1)
puts g.number_of_nodes
puts g.size
puts g.size(weight = "weight")
g.degree([] of Chizge::Node, "weight") do |x|
  puts x
end
# i = g.each
# puts i.next
puts g.to_s
puts g.contains?(1)
puts g.contains?(1, 2)
puts g[1]
g.adjacency.each do |u|
  puts "#{u[0]} : #{u[1]}"
end
puts g.number_of_edges
g.remove_edges_from([{1, 2}, {2, 3}])
# g.remove_edge(1,9)
puts g.number_of_edges
puts g.number_of_edges(4, 5)
