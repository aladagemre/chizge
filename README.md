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

g = Chizge::Graph.new
g.add_path([1,2,3,4,5])
g.add_node(6)
g.add_edge(4, 6)
g.add_edge(4, 5, {"weight" => 10.0 as Chizge::Attr})
puts g.number_of_nodes
puts g.size
puts g.size(weight="weight")
g.degree([] of Chizge::Node, "weight") do |x|
    puts x
end
i = g.each
puts i.next
puts g.to_s
puts g.contains(1)
puts g.contains(1, 2)
puts g[1]
```

## Status

This project is on pre-alpha stage and there may be lots of pieces missing yet.

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
