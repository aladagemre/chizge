module Chizge::Algorithms::Coloring
  # Sorts nodes according to degree in descending order
  def self.sorted_edges(g : Chizge::Graph)
    n = g.node.size
    sorted_edge = {} of Node => NodeMap
    n.times do
      max = -1
      max_key = 0
      g.edge.each do |r|
        if g.edge[r].size > max
          max_key = r
          max = g.edge[r].size
        end
      end
      sorted_edge[max_key] = g.edge[max_key]
      g.edge.delete(max_key)
    end
    return sorted_edge
  end

  # Coloring the graph using with Welsh & Powell Algorithm:
  # 1. Sort nodes according to the degree of nodes in descending order
  # 2. Give the first color to top node and other nodes which is not connected to this node
  # 3. Choose the next node in the list which is not colored and give the second color to this node
  # 4. Keep repeat the third step until all nodes colored
  def self.welsh_powell(g : Chizge::Graph)
    colors = ["#1abc9c", "#f1c40f", "#2ecc71", "#e67e22", "#3498db", "#e74c3c",
              "#9b59b6", "#34495e", "#95a5a6", "#16a085", "#f39c12", "#27ae60",
              "#d35400", "#2980b9", "#c0392b", "#8e44ad", "#bdc3c7", "#7f8c8d"]

    edges = sorted_edges(g)

    colored_nodes = {} of String => String
    keys = edges.keys
    keys_size = keys.size

    i = 0
    while colored_nodes.size < keys_size
      unless colored_nodes.has_key?([keys[i]])
        colored_nodes[keys[i].to_s] = colors[i]
        j = i + 1
        while j < keys.size
          unless edges[keys[i]].has_key?(keys[j])
            color_hash = colored_nodes.select { |k, v| v == colors[i] }
            temp = 0
            color_hash.each do |r|
              unless edges[r].has_key?(keys[j])
                temp += 1
              end
            end
            if temp == color_hash.size
              colored_nodes[keys[j].to_s] = colors[i]
              keys.delete_at(j)
            end
          end
          j += 1
        end
      end
      i += 1
    end
    return colored_nodes
  end
end
