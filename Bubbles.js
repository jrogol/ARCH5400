function drawBubbles(){
    bubbles = d3.select('#focusTweets')
      .append('svg')
      .attr('class', 'focus')
      .attr('id','bubbles')
      .attr('width', widthF)
      .attr('height', heightF)
      .append('g')
        .attr('id','circles')
        .attr('transform', 'translate(' + margin.left + ', ' + margin.top + ')');
    
    
    // Sets the y- Scale (total tweets)
    yF = d3.scaleLinear()
      .domain([0, maxTweet2])
      .range([heightF - margin.top - margin.bottom, 0]);
    yAxisF =d3.axisLeft(yF)
      .ticks(20)
      .tickPadding(8);
    
    // Append y-Axis
    bubbles.append('g').attr('class','axis axis--y').call(yAxisF);
    
    // EVERYTHING ABOVE WORKS

    //this works! FINALLY!
    bubbles.selectAll('circle')
        .data(data)
        .enter().append('circle')
        .attr('cx',function(d){return +x(new Date(d.cst))})
        .attr('cy', function(d){return y2(+d.tweets)})
//        .attr('cy', function(d){return heightF - 40 - y(+d.tweets)})
        .attr('r',function(d){return +d.tpu*1500})
        // Strip the spaces with RegEx, add "tweet" class
        .attr('class', function(d){return "tweet " + d["lang.topic"].replace(/\s/g, '')})
        .attr('id', function(d){return "z" + d.cst})
        .attr('transform','translate(0,'+(heightF-250)+')')
    .on("mouseover", function(d){
                        dimAll();
                        addStory(this.id);
                        d3.select(this)
                          .style("opacity",1);
                        div.transition()        
                            .duration(200)      
                            .style("opacity", .9);      
                        div.html('<H5>'+d['lang.topic'] + '</H5><br>' + 'Tweets: ' + +d.tweets + '<br>'
                        + 'TPU: ' + (+d["tpu"]).toFixed(4))
                        .style("left", (d3.event.pageX) + "px")     
                        .style("top", (d3.event.pageY - 28) + "px"); })
    .on("mouseout", function(d){
        showAll();
        div.transition()        
           .duration(500)      
           .style("opacity", 0);
    });

    //Append x-Axis
    bubbles.append('g').attr('class', 'axis axis--x')
          .attr('transform', 'translate(0, ' + (heightF - margin.top - margin.bottom) + ')')
          .call(xAxis);
}