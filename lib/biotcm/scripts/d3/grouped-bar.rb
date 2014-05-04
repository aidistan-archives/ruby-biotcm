# encoding: UTF-8

class BioTCM::Scripts::D3
  # Draw bar chart
  # @param data [Table, String] a two column table or a String can be to_table
  # @param y_ticks [Fixnum]
  # @param y_tick_unit [String] can be '%'
  # @return [self]
  def grouped_bar(data:nil, title:'', y_ticks:10, y_tick_unit:nil)
    data = data.to_table unless data.is_a?(BioTCM::Table)

    content = <<-END_OF_DOC
<style>
body { font: 10px sans-serif; }
.bar { fill: steelblue; }
.axis path, .axis line { fill: none; stroke: #000; shape-rendering: crispEdges; }
.x.axis path { display: none; }
</style>

<script>

var margin = {top: 30, right: 30, bottom: 40, left: 50},
    width = $(window).width() - margin.left - margin.right,
    height = $(window).height() - margin.top - margin.bottom;

var x0 = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);

var x1 = d3.scale.ordinal();

var y = d3.scale.linear()
    .range([height, 0]);

var color = d3.scale.ordinal()
    .range(#{%w{#00aeef #ea428a #eed500 #f5a70d #8bcb30 #9962c1 #999}.inspect});

var xAxis = d3.svg.axis()
    .scale(x0)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left")
    .tickFormat(d3.format(".2s"));

var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.tsv("data.tsv", function(error, data) {
  var colNames = d3.keys(data[0]).filter(function(key) { return key !== "#{data.primary_key}"; });

  data.forEach(function(d) {
    d.cols = colNames.map(function(name) { return {name: name, value: +d[name]}; });
    console.log(d)
  });

  x0.domain(data.map(function(d) { return d['#{data.primary_key}']; }));
  x1.domain(colNames).rangeRoundBands([0, x0.rangeBand()]);
  y.domain([0, d3.max(data, function(d) { return d3.max(d.cols, function(d) { return d.value; }); })]);

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
      .text("Population");

  var state = svg.selectAll(".state")
      .data(data)
    .enter().append("g")
      .attr("class", "g")
      .attr("transform", function(d) { return "translate(" + x0(d['#{data.primary_key}']) + ",0)"; });

  state.selectAll("rect")
      .data(function(d) { return d.cols; })
    .enter().append("rect")
      .attr("width", x1.rangeBand())
      .attr("x", function(d) { return x1(d.name); })
      .attr("y", function(d) { return y(d.value); })
      .attr("height", function(d) { return height - y(d.value); })
      .style("fill", function(d) { return color(d.name); });

  var legend = svg.selectAll(".legend")
      .data(colNames.slice().reverse())
    .enter().append("g")
      .attr("class", "legend")
      .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

  legend.append("rect")
      .attr("x", width - 18)
      .attr("width", 18)
      .attr("height", 18)
      .style("fill", color);

  legend.append("text")
      .attr("x", width - 24)
      .attr("y", 9)
      .attr("dy", ".35em")
      .style("text-anchor", "end")
      .text(function(d) { return d; });

});

</script>
    END_OF_DOC

    # Publish
    publish('data.tsv', data)
    publish(title, content, index:true)
    return self
  end
  # @private
  # Demo for grouped bar
  def demo_grouped_bar
    data = <<-END_OF_DOC
State\tUnder 5 Years\t5 to 13 Years\t14 to 17 Years\t18 to 24 Years\t25 to 44 Years\t45 to 64 Years\t65 Years and Over
CA\t2704659\t4499890\t2159981\t3853788\t10604510\t8819342\t4114496
TX\t2027307\t3277946\t1420518\t2454721\t7017731\t5656528\t2472223
NY\t1208495\t2141490\t1058031\t1999120\t5355235\t5120254\t2607672
FL\t1140516\t1938695\t925060\t1607297\t4782119\t4746856\t3187797
IL\t894368\t1558919\t725973\t1311479\t3596343\t3239173\t1575308
PA\t737462\t1345341\t679201\t1203944\t3157759\t3414001\t1910571
    END_OF_DOC
    grouped_bar(title:'Demo - D3.bar', data:data)
    return self
  end
end
