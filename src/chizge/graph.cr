module Chizge
  alias Attr = String | Int64 | Int32 | Float64
  alias Node = String | Int64 | Int32
  alias Edge = Tuple(Node, Node)
  alias StringMap = Hash(String, Attr)
  alias NodeMap = Hash(Node, StringMap)

  class Graph
    # Returns the hash containing nodes and their attributes.
    getter node
    # Returns the hash containing nodes and their adjacency lists (w/attributes).
    getter edge
    # Returns the name of graph.
    getter name

    def initialize(@name = "Graph")
      # Node attributes
      @node = Hash(Node, StringMap).new
      # Adjacency list
      @edge = @adj = Hash(Node, NodeMap).new
      # Graph attributes
      @graph = Hash(String, Attr).new
    end

    # Returns the edges of the given node.
    # ```
    # g = Chizge::Graph.new
    # g.add_path([1, 2, 3, 4, 5])
    # g[3]
    # ```
    def [](n : Node)
      @adj[n]
    end

    # Returns the string representation of the graph
    # Graph (10 nodes): [original hash]
    def to_s
      name = @name
      num_nodes = number_of_nodes
      sign = super.to_s
      "#{name} (#{num_nodes} nodes): #{sign}"
    end

    # Returns an iterator over nodes.
    def each
      @node.each
    end

    # Returns if the graph contains a given node.
    def contains?(n : Node)
      @node.has_key?(n)
    end

    # Returns if the graph contains a given edge.
    def contains?(u : Node, v : Node)
      @edge.has_key?(u) && @edge[u].has_key?(v)
    end

    # Adds a single node n and updates node attributes.
    # ```
    # g = Chizge::Graph.new
    # g.add_node(1)
    # g.number_of_nodes
    # # => 1
    # ```
    def add_node(n : Node, attrs = Hash(String, Attr).new)
      unless @node.has_key? n
        @adj[n] = Hash(Node, StringMap).new
        @node[n] = attrs
      else
        if attrs
          @node[n] = @node[n].merge(attrs)
        end
      end
    end

    # Adds nodes in the given node array to the graph.
    #
    # ```
    # g = Chizge::Graph.new
    # g.add_nodes_from([1, 2, 3, 4, 5])
    # puts g.node.keys
    # # => [1, 2, 3, 4, 5]
    # ```
    def add_nodes_from(nodes : Array(Node), attrs = Hash(String, Attr).new)
      i = -1
      while (i += 1) < nodes.size
        add_node(nodes[i])
      end
    end

    # Returns node data for the given node.
    def get_node_data(node : Node)
      @node[node]
    end

    # Removes the given node (together with its edges) from the graph.
    def remove_node(n : Node)
      if @node[n]?
        if @adj[n]?
          nbrs = @adj[n].keys
          nbrs.map { |v| @adj[v].delete(n) }
        end
        @adj.delete(n)
        @node.delete(n)
      end
    end

    # Removes the given nodes (together with their edges) from the graph.
    def remove_nodes_from(nodes : Array(Node))
      i = -1
      while (i += 1) < nodes.size
        remove_node(nodes[i])
      end
    end

    # Returns an iterator over the nodes
    # If data is true, node data will be appended to the response.
    # ```
    # g.nodes do |node|
    #   puts node
    # end
    # ```
    def nodes(data = false)
      if data
        @node.keys.each do |key|
          yield Tuple.new(key, @node[key])
        end
      else
        @node.keys.each do |key|
          yield key
        end
      end
    end

    # Returns the number of nodes in the graph.
    #
    # ```
    # g = Chizge::Graph.new
    # g.add_path([0, 1, 2])
    # puts g.number_of_nodes
    # # => 3
    # ```
    def number_of_nodes
      @node.size
    end

    # Returns the number of nodes in the graph.
    # Identical to number_of_nodes
    def order
      @node.size
    end

    # Returns true if the graph contains the node n.
    def has_node?(n : Node)
      @node.has_key?(n)
    end

    # =========== EDGES ================

    # Creates node u if it does not exist.
    #     - Creates an empty hash for its node attributes
    #    - Creates an empty hash for its edges
    # ```
    # create_ine(1)
    # # =>
    # @node
    # # => {1 => {}}
    # @edge
    # # => {1 => {}}
    # ```
    def create_ine(u)
      unless @node[u]?
        @adj[u] = Hash(Node, StringMap).new
        @node[u] = Hash(String, Attr).new
      end
    end

    # Adds edge between two nodes: (u, v)
    #
    # ```
    # g.add_edge(1, 2)
    # # =>
    # g.node
    # # => {1 => {}, 2=> {}}
    # g.edge
    # # => {1 => {2 => {}}, 2 => {1 => {}}}
    # g.add_edge(1, 2, {"weight": 32.2 as Chizge::Attr})
    # # =>
    # g.edge
    # # => {1 => {2 => {"weight" => 32.2}}, 2 => {1 => {"weight" => 32.2}}}
    # ```
    def add_edge(u : Node, v : Node, attrs = Hash(String, Attr).new)
      # Create node and its (empty) edges if node doesn't exist
      create_ine(u)
      create_ine(v)

      # Get the edge data if it already exists
      datadict = @adj[u][v]? ? @adj[u][v] : Hash(String, Attr).new

      # Update the edge data with given attributes
      datadict = datadict.merge(attrs)

      # Assign edge data to edge of each directions.
      @adj[u][v] = datadict
      @adj[v][u] = datadict
    end

    # Adds the edges in the given array to the graph with given general  atributes for all
    def add_edges_from(ebunch : Array(Tuple(Node, Node)), attrs = Hash(String, Attr).new)
      ebunch.map { |e|
        u, v = e
        add_edge(u, v, attrs)
      }
    end

    # Adds the edges in the given array to the graph with given specific and general atributes for all
    def add_edges_from(ebunch : Array(Tuple(Node, Node, Hash(String, Attr))), attrs = Hash(String, Attr).new)
      ebunch.map { |e|
        u, v, dd = e
        add_edge(u, v, attrs.merge(dd))
      }
    end

    # Adds the weighted edges in the given array to the graph using field "weight"
    def add_weighted_edges_from(ebunch : Array(Tuple(Node, Node, Attr)), weight = "weight")
      ebunch.map { |e|
        u, v, d = e
        add_edge(u, v, {weight => d})
      }
    end

    # Removes the edge between u and v
    # Raises EdgeNotFoundException if the given edge is not in the graph.
    #
    # ```
    # g = Chizge::Graph.new
    # g.add_path([0, 1, 2, 3])
    # g.remove_edge(0, 1)
    # ```
    def remove_edge(u : Node, v : Node)
      unless @adj[u][v]?
        raise Chizge::EdgeNotFoundException.new("Edge (#{u}, #{v}) not found in the graph.")
      end
      @adj[u].delete(v)
      if u != v
        @adj[v].delete(u)
      end
    end

    # Removes the given edges from the graph.
    def remove_edges_from(ebunch : Array(Tuple(Node, Node)))
      i = -1
      while (i += 1) < ebunch.size
        remove_edge(ebunch[i][0], ebunch[i][1])
      end
    end

    # Returns if the graph contains the given edge.
    def has_edge?(u : Node, v : Node)
      @edge.has_key?(u) && @edge[u].has_key?(v)
    end

    # Returns an array containing all neighbors of node n.
    def neighbors(n : Node)
      if @edge.has_key?(n)
        @edge[n].keys
      else
        [] of Node
      end
    end

    # Returns an iterator over all neighbors of node n
    def neighbors_iter(n : Node)
      if @edge.has_key?(n)
        @edge[n].keys.each do |neighbor|
          yield neighbor
        end
      end
    end

    # Returns an iterator over the edges.
    # Edges are returned as tuples with optional data.
    def edges(nbunch = [] of Tuple(Node, Node), data = false, default = nil)
      # TODO: implement this.
      @edge
    end

    # Returns the attribute hash associated with edge (u,v).
    # Returns the value of "default" if no such edge is found
    def get_edge_data(u : Node, v : Node, default = nil)
      val = @adj[u]? && @adj[u][v]?
      val ? val : default
    end

    # Returns an iterator over (node, adjacency hash) tuples for all nodes
    #
    # ```
    # g.adjacency.each do |u|
    #   puts "#{u[0]} : #{u[1]}"
    # end
    # ```
    def adjacency
      @edge.each
    end

    # ========== OTHER =======

    # Returns the degrees of the nodes given
    # If empty node list is given, returns the degrees of the all nodes.
    # If weight field is provided, weights are summed on that field.
    #
    # ```
    # g = Chizge::Graph.new
    # g.add_path([1, 2, 3, 4, 5, 6], {"weight" => 2.0})
    # g.degree { |r| puts r }
    # # =>
    # {1, 1}
    # {2, 2}
    # {3, 2}
    # {4, 2}
    # {5, 2}
    # {6, 1}
    #
    # g.degree(nbunch = [1, 2]) { |r| puts r }
    # # =>
    # {1, 1}
    # {2, 2}
    # ```
    #
    def degree(nbunch = [] of Node, weight = nil)
      # TODO: Not finished yet.

      if nbunch.size == 0
        nodelist = @node.keys
      else
        nodelist = nbunch
      end

      nodelist.each do |u|
        unless weight
          d = @edge[u].keys.size
        else
          dgs = 0.0_f64
          @edge[u].each do |v|
            if @edge[u][v].has_key?(weight)
              dgs += @edge[u][v][weight].to_f64
            else
              dgs += 1.0
            end
          end
          d = dgs
        end
        yield Tuple.new(u, d as Attr)
      end
    end

    # Removes all nodes and edges from the graph.
    # Sets the graph name to Graph.
    def clear
      @name = "Graph"
      @adj.clear
      @node.clear
      @graph.clear
    end

    # Returns a copy of the graph object.
    def copy
    end

    # Checks if the graph is a multigraph.
    def is_multigraph?
      false
    end

    # Checks if the graph is directed.
    def is_directed?
      false
    end

    # Converts the graph to undirected.
    def to_undirected
    end

    # Returns the subgraph containing the nodes in *nbunch*.
    def subgraph(nbunch : Array(Node))
    end

    # Returns the array of nodes that has self-loops.
    def nodes_with_selfloops
    end

    def selfloop_edges(data = false, default = nil)
    end

    # If weight field is not provided, returns the number of edges
    # If weight field is provided, sum of weights are returned.
    #
    # ```
    # g = Chizge::Graph.new
    # g.add_path([1, 2, 3, 4, 5, 6], {"weight" => 2.0})
    # puts g.size
    # # => 10
    # puts g.size(weight = "weight")
    # # => 20
    # ```
    #
    def size(weight = nil)
      total = weight ? 0.0 : 0
      w = weight
      f = degree([] of Node, w) do |r|
        dg = r[1].to_f64
        total += dg
      end
      total
    end

    # Returns the number of edges between two nodes.
    # If u, v provided, returns the number of edges between u and v.
    # Otherwise, returns the total number of all edges.
    def number_of_edges(u : Node = nil, v : Node = nil)
      unless u
        total = 0
        nodes do |u|
          total += @adj[u].size
        end
        is_directed? ? total : total/2
      else
        u && v && @adj[u][v]? ? 1 : 0
      end
    end

    def add_star(nodes : Array(Node))
    end

    # Adds a path using given nodes.
    #
    # ```
    # g = Chizge::Graph.new
    # g.add_path([0, 1, 2, 3])
    # g.add_path([10, 11, 12], {"weight" => 7})
    # puts g.edge
    # # => {0 => {1 => {}}, 1 => {0 => {}, 2 => {}}, 2 => {1 => {}, 3 => {}}, 3 => {2 => {}}, 10 => {11 => {"weight" => 7}}, 11 => {10 => {"weight" => 7}, 12 => {"weight" => 7}}, 12 => {11 => {"weight" => 7}}}
    # ```
    def add_path(nodes : Array(Node), attrs = Hash(String, Attr).new)
      bunch1 = nodes[0...nodes.size - 1]
      bunch2 = nodes[1..nodes.size - 1]
      edges = bunch1.zip(bunch2)
      add_edges_from(edges, attrs)
    end

    # Adds a cyclic path using given nodes.
    #
    # ```
    # g = Chizge::Graph.new
    # g.add_cycle([0, 1, 2, 3])
    # g.add_cycle([10, 11, 12], {"weight" => 7})
    # puts g.edge
    # # => {0 => {1 => {}, 3 => {}}, 1 => {0 => {}, 2 => {}}, 2 => {1 => {}, 3 => {}}, 3 => {2 => {}, 0 => {}}, 10 => {11 => {"weight" => 7}, 12 => {"weight" => 7}}, 11 => {10 => {"weight" => 7}, 12 => {"weight" => 7}}, 12 => {11 => {"weight" => 7}, 10 => {"weight" => 7}}}
    # ```
    def add_cycle(nodes : Array(Node), attrs = Hash(String, Attr).new)
      edges = nodes.zip(nodes.rotate)
      add_edges_from(edges, attrs)
    end

    # Adds a complete path using given nodes.
    #
    # ```
    # g = Chizge::Graph.new
    # g.add_complete([0, 1, 2, 3])
    # puts g.edge
    # # => {0 => {1 => {}, 3 => {}, 2 => {}}, 1 => {0 => {}, 2 => {}, 3 => {}}, 2 => {1 => {}, 3 => {}, 0 => {}}, 3 => {2 => {}, 0 => {}, 1 => {}}}
    def add_complete(nodes : Array(Node), attrs = Hash(String, Attr).new)
      temp = nodes.size - 3
      edges = nodes.zip(nodes.rotate)
      count = 2
      temp.times do
        edges += nodes.zip(nodes.rotate(count))
        count += 1
      end
      add_edges_from(edges, attrs)
    end

    def nbunch_iter(nbunch = [] of Node)
    end

    # If it is cycle graph returns true
    # All of the nodes's degree must be 2
    def is_cycle_graph?
      temp = 0
      @edge.each do |r|
        if @edge[r].size == 2
          temp += 1
        end
      end
      return temp == @node.size
    end

    # If it is complete graph returns true
    # All of the nodes's degree must be total number of nodes minus 1
    def is_complete_graph?
      temp = 0
      @edge.each do |r|
        if @edge[r].size == @node.size - 1
          temp += 1
        end
      end
      return temp == @node.size
    end

    # If it is path graph returns true
    # First and last node's degree must be 1, others must be 2
    def is_path_graph?
      temp = 0
      count = 0
      first_node_degree = 0
      last_node_degree = 0
      @edge.each do |r|
        if count == 0 && @edge[r].size == 1
          first_node_degree = 1
        elsif count == @node.size - 1 && @edge[r].size == 1
          last_node_degree = 1
        elsif @edge[r].size == 2
          temp += 1
        end
        count += 1
      end
      return first_node_degree == 1 && last_node_degree == 1 && temp == @node.size - 2
    end
  end
end
