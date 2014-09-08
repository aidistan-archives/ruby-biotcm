class BioTCM::Scripts::D3
  # Draw bar chart
  # @param data [Table, String] a two column table or a String can be to_table
  # @param y_ticks [Fixnum]
  # @param y_tick_unit [String] can be '%'
  # @return [self]
  def bar(data:nil, title:'', y_ticks:10, y_tick_unit:nil)
    data = data.to_table unless data.is_a?(BioTCM::Table)
    col_key = data.primary_key
    col_val = data.col_keys[0]

    content = <<-END_OF_DOC
<style>
.bar { fill: steelblue; }
.bar:hover { fill: brown; }

.axis { font: 10px sans-serif; }
.axis path, .axis line { fill: none; stroke: #000; shape-rendering: crispEdges; }

.x.axis path { display: none; }
</style>

<script>

var margin = {top: 30, right: 30, bottom: 40, left: 50},
    width = $(window).width() - margin.left - margin.right,
    height = $(window).height() - margin.top - margin.bottom;

var x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);

var y = d3.scale.linear()
    .range([height, 0]);

var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left")
    .ticks(#{y_ticks.to_s}#{y_tick_unit ? ', "' + y_tick_unit : ''});

var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.tsv("data.tsv", type, function(error, data) {
  x.domain(data.map(function(d) { return d['#{col_key}']; }));
  y.domain([0, d3.max(data, function(d) { return d['#{col_val}']; })]);

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("#{col_val}");

  svg.selectAll(".bar")
      .data(data)
    .enter().append("rect")
      .attr("class", "bar")
      .attr("x", function(d) { return x(d['#{col_key}']); })
      .attr("width", x.rangeBand())
      .attr("y", function(d) { return y(d['#{col_val}']); })
      .attr("height", function(d) { return height - y(d['#{col_val}']); });

});

function type(d) {
  d['#{col_val}'] = +d['#{col_val}'];
  return d;
}

</script>
    END_OF_DOC

    # Publish
    publish('data.tsv', data)
    publish(title, content, index:true)
    return self
  end
  # @private
  # Demo for bar
  def demo_bar
    data = <<-END_OF_DOC
letter\tfrequency
A\t.08167
B\t.01492
C\t.02782
D\t.04253
E\t.12702
F\t.02288
G\t.02015
H\t.06094
I\t.06966
J\t.00153
K\t.00772
L\t.04025
M\t.02406
N\t.06749
O\t.07507
P\t.01929
Q\t.00095
R\t.05987
S\t.06327
T\t.09056
U\t.02758
V\t.00978
W\t.02360
X\t.00150
Y\t.01974
Z\t.00074
    END_OF_DOC
    bar(title:'Demo - D3.bar', data:data)
    return self
  end
end
