// Dim all the circles (Tweets) to 30% opacity
function dimAll() {
    var circles = d3.selectAll("circle")
        .style("opacity",.03)
        .transition().duration(1000); 
};

// Return Tweet-circles to 60% opacity
function showAll() {
    var elements = d3.selectAll("circle")
        .style("opacity", 0.2)
        .transition().duration(1000);
};