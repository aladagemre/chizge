# Chizge (Çizge)

A Network (Graph) Analysis library for Crystal Language, inspired by NetworkX.

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  chizge:
    github: aladagemre/chizge
```


## Usage


```crystal
require "chizge"

G = Chizge::Graph.new
G.add_path([1,2,3,4,5])
G.add_node(6)
G.add_edge(4, 6)
G.add_edge(4, 5, {"weight" => 10 as Chizge::Attr})
puts G.number_of_nodes
puts G.size
puts G.size(weight="weight")
G.degree([] of Chizge::Node, "weight") do |x|
    puts x
end
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/aladagemre/chizge/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [aladagemre](https://github.com/aladagemre) Ahmet Emre Aladağ - creator, maintainer
