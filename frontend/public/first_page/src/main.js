
function start_program(){
    var design_speed = document.getElementById("design_speed").value;
    var min_curvature_radius = document.getElementById("min_curvature_radius").value;
    var max_fall = document.getElementById("max_fall").value;
    var road_width = document.getElementById("road_width").value;

    location.href = location.origin + '/index.html';
  // location.href=window.location.href + 'map?designSpeed=' + design_speed +
  // '&minCurvatureRadius=' + min_curvature_radius +
  // '&maxFall=' + max_fall +
  // '&roadWidth=' + road_width;
}

