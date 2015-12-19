module Chizge
    alias Attr = String | Int64 | Int32 | Float64
    alias Node = String | Int64 | Int32 | Nil
    alias Edge = Tuple(Node, Node)
    alias StringMap = typeof({} of String => Attr) | Nil
    alias NodeMap = typeof({} of Node => StringMap) | Nil


    class Graph
        getter node
        getter edge
        getter name

        def initialize(@name="Graph")
            # Node attributes
            @node = {} of Node => StringMap
            # Adjacency list
            @edge = @adj = {} of Node => NodeMap
            # Graph attributes
            @graph = {} of String => Attr
        end

        def [](n : Node)
            @adj[n]
        end

        def to_s
            name = @name
            num_nodes = number_of_nodes
            sign = super.to_s
            "#{name} (#{num_nodes} nodes): #{sign}"
        end

        def each
            @node.each
        end

        def contains(n : Node)
            @node.has_key?(n)
        end

        def contains(u : Node, v : Node)
            @edge.has_key?(u) && @edge[u].has_key?(v)
        end

        # Adds a single node n and updates node attributes.
        # ```
        # g = Chizge::Graph.new
        # g.add_node(1)
        # g.number_of_nodes
        # #=> 1
        # ```

        def add_node(n : Node, attrs = {} of String => Attr)
            unless @node.has_key? n
                @adj[n] = {} of Node => StringMap
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
        # #=> [1, 2, 3, 4, 5]
        # ```
        def add_nodes_from(nodes : Array(Node), attrs = {} of String => Attr)
            i = -1
            while (i += 1) < nodes.size
                add_node(nodes[i])
            end
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
        # g.nodes do | node |
        #     puts node
        # end
        # ```
        def nodes(data=false)
            if data
                @node.keys.each do | key |
                    yield Tuple.new(key, @node[key])
                end
            else
                @node.keys.each do | key |
                    yield key
                end
            end
        end

        # Returns the number of nodes in the graph.
        #
        # ```
        # g = Chizge::Graph.new
        # g.add_path([0,1,2])
        # puts g.number_of_nodes
        # #=> 3
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
        #    - Creates an empty hash for its node attributes
        #    - Creates an empty hash for its edges
        # ```
        # create_ine(1)
        # #=>
        # @node
        # #=> {1 => {}}
        # @edge
        # #=> {1 => {}}
        # ```
        def create_ine(u)
            unless @node[u]?
                @adj[u] = {} of Node => StringMap
                @node[u] = {} of String => Attr
            end
        end

        # Adds edge between two nodes: (u, v)
        #
        # ```
        # g.add_edge(1, 2)
        # #=>
        # g.node
        # #=> {1 => {}, 2=> {}}
        # g.edge
        # #=> {1 => {2 => {}}, 2 => {1 => {}}}
        # g.add_edge(1, 2, {"weight": 32.2 as Chizge::Attr})
        # #=>
        # g.edge
        # #=> {1 => {2 => {"weight" => 32.2}}, 2 => {1 => {"weight" => 32.2}}}
        # ```
        def add_edge(u : Node, v : Node, attrs = {} of String => Attr)
            # Create node and its (empty) edges if node doesn't exist
            create_ine(u)
            create_ine(v)

            # Get the edge data if it already exists
            datadict = @adj[u][v]? ? @adj[u][v] : {} of String => Attr

            # Update the edge data with given attributes
            datadict = datadict.merge(attrs)

            # Assign edge data to edge of each directions.
            @adj[u][v] = datadict
            @adj[v][u] = datadict
        end

        def add_edges_from(ebunch : Array(Tuple(Node, Node)), attrs = {} of String => Attr)
            ebunch.map { |e|
                u, v = e
                add_edge(u, v, attrs)
            }
        end
        def add_edges_from(ebunch : Array(Tuple(Node, Node, typeof({} of String => String | Int64 | Int32 | Float64) )), attrs = {} of String => Attr)
            ebunch.map { |e|
                u, v, dd = e
                add_edge(u, v, attrs.merge(dd))
            }
        end

        def add_weighted_edges_from(ebunch : Array(Tuple(Node, Node, String | Int64 | Int32 | Float64)), weight="weight")
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
        # g.add_path([0,1,2,3])
        # g.remove_edge(0,1)
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
                @edge[n].keys.each do | neighbor |
                    yield neighbor
                end
            end
        end

        # Returns an iterator over the edges.
        # Edges are returned as tuples with optional data.
        def edges(nbunch = [] of Tuple(Node, Node), data=false, default=nil)
            # TODO: implement this.
            @edge
        end

        def get_edge_data(u : Node, v : Node, default=nil)
        end

        # Returns an iterator over (node, adjacency hash) tuples for all nodes
        #
        # ```
        # g.adjacency.each do |u|
        #    puts "#{u[0]} : #{u[1]}"
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
        # g.add_path([1,2,3,4,5,6], {"weight" => 2.0})
        # g.degree { |r| puts r }
        # #=>
        #  {1, 1}
        #  {2, 2}
        #  {3, 2}
        #  {4, 2}
        #  {5, 2}
        #  {6, 1}
        #
        # g.degree(nbunch=[1,2]) { |r| puts r }
        # #=>
        #  {1, 1}
        #  {2, 2}
        #

        # ```
        def degree(nbunch=[] of Node, weight=nil)
            # TODO: Not finished yet.

            if nbunch.size == 0
                nodelist = @node.keys
            else
                nodelist = nbunch
            end

            nodelist.each do | u |
                unless weight
                    d = @edge[u].keys.size
                else
                    dgs = 0.0_f64
                    @edge[u].each do | v |
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

        def copy
        end

        def is_multigraph?
            false
        end

        def is_directed?
            false
        end

        def to_undirected
        end

        def subgraph(nbunch : Array(Node))
        end

        def nodes_with_selfloops
        end

        def selfloop_edges(data=false, default=nil)
        end

        # If weight field is not provided, returns the number of edges
        # If weight field is provided, sum of weights are returned.
        #
        # ```
        # g = Chizge::Graph.new
        # g.add_path([1,2,3,4,5,6], {"weight" => 2.0})
        # puts g.size()
        # #=> 10
        # puts g.size(weight="weight")
        # #=> 20
        # ```
        def size(weight=nil)
            total = weight ? 0.0 : 0
            w = weight
            f = degree([] of Node, w) do | r |
                dg = r[1].to_f64
                total += dg
            end
            total
        end

        # Returns the number of edges between two nodes.
        # If u, v provided, returns the number of edges between u and v.
        # Otherwise, returns the total number of all edges.
        def number_of_edges(u = nil : Node, v = nil : Node)
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
        # g.add_path([0,1,2,3])
        # g.add_path([10,11,12], {"weight" => 7})
        # puts g.edge
        # #=> {0 => {1 => {}}, 1 => {0 => {}, 2 => {}}, 2 => {1 => {}, 3 => {}}, 3 => {2 => {}}, 10 => {11 => {"weight" => 7}}, 11 => {10 => {"weight" => 7}, 12 => {"weight" => 7}}, 12 => {11 => {"weight" => 7}}}
        # ```
        def add_path(nodes : Array(Node), attrs = {} of String => Attr)
            bunch1 = nodes[0 ... nodes.size - 1]
            bunch2 = nodes[1 .. nodes.size - 1]
            edges = bunch1.zip(bunch2)
            add_edges_from(edges, attrs)
        end

        # Adds a cyclic path using given nodes.
        #
        # ```
        # g = Chizge::Graph.new
        # g.add_cycle([0,1,2,3])
        # g.add_cycle([10,11,12], {"weight" => 7})
        # puts g.edge
        # #=> {0 => {1 => {}, 3 => {}}, 1 => {0 => {}, 2 => {}}, 2 => {1 => {}, 3 => {}}, 3 => {2 => {}, 0 => {}}, 10 => {11 => {"weight" => 7}, 12 => {"weight" => 7}}, 11 => {10 => {"weight" => 7}, 12 => {"weight" => 7}}, 12 => {11 => {"weight" => 7}, 10 => {"weight" => 7}}}
        # ```
        def add_cycle(nodes : Array(Node), attrs = {} of String => Attr)
            bunch1 = nodes[1 .. nodes.size - 1]
            bunch2 = nodes[0 ... 1]
            edges = nodes.zip(bunch1 + bunch2)
            add_edges_from(edges, attrs)
        end

        def nbunch_iter(nbunch=[] of Node)
        end


    end
end
