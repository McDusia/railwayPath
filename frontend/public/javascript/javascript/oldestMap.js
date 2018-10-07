require(["esri/Map", "esri/views/MapView", "esri/views/2d/draw/Draw", "esri/Graphic", "esri/geometry/geometryEngine"], function (Map, MapView, Draw, Graphic, geometryEngine) {
  const map = new Map({
    basemap: "gray"
  });

  const view = new MapView({
    container: "viewDiv",
    map: map,
    zoom: 16,
    center: [18.06, 59.34]
  });

  // add the button for the draw tool
  view.ui.add("line-button", "top-left");

  const draw = new Draw({
    view: view
  });

  // draw polyline button
  document.getElementById("line-button").onclick = function () {
    view.graphics.removeAll();

    // creates and returns an instance of PolyLineDrawAction
    const action = draw.create("polyline");

    // focus the view to activate keyboard shortcuts for sketching
    view.focus();

    // listen polylineDrawAction events to give immediate visual feedback
    // to users as the line is being drawn on the view.
    action.on("vertex-add", updateVertices);
    action.on("vertex-remove", updateVertices);
    action.on("cursor-update", updateVertices);
    action.on("redo", updateVertices);
    action.on("undo", updateVertices);
    action.on("draw-complete", updateVertices);
  };

  // Checks if the last vertex is making the line intersect itself.
  function updateVertices(event) {
    // create a polyline from returned vertices
    const result = createGraphic(event);

    // if the last vertex is making the line intersects itself,
    // prevent the events from firing
    if (result.selfIntersects) {
      event.preventDefault();
    }
  }

  // create a new graphic presenting the polyline that is being drawn on the view
  function createGraphic(event) {
    const vertices = event.vertices;
    view.graphics.removeAll();

    // a graphic representing the polyline that is being drawn
    const graphic = new Graphic({
      geometry: {
        type: "polyline",
        paths: vertices,
        spatialReference: view.spatialReference
      },
      symbol: {
        type: "simple-line", // autocasts as new SimpleFillSymbol
        color: [4, 90, 141],
        width: 4,
        cap: "round",
        join: "round"
      }
    });

    // check if the polyline intersects itself.
    const intersectingSegment = getIntersectingSegment(graphic.geometry);

    // Add a new graphic for the intersecting segment.
    if (intersectingSegment) {
      view.graphics.addMany([graphic, intersectingSegment]);
    }
    // Just add the graphic representing the polyline if no intersection
    else {
        view.graphics.add(graphic);
      }

    // return intersectingSegment
    return {
      selfIntersects: intersectingSegment
    };
  }

  // function that checks if the line intersects itself
  function isSelfIntersecting(polyline) {
    if (polyline.paths[0].length < 3) {
      return false;
    }
    const line = polyline.clone();

    //get the last segment from the polyline that is being drawn
    const lastSegment = getLastSegment(polyline);
    line.removePoint(0, line.paths[0].length - 1);

    // returns true if the line intersects itself, false otherwise
    return geometryEngine.crosses(lastSegment, line);
  }

  // Checks if the line intersects itself. If yes, change the last
  // segment's symbol giving a visual feedback to the user.
  function getIntersectingSegment(polyline) {
    if (isSelfIntersecting(polyline)) {
      return new Graphic({
        geometry: getLastSegment(polyline),
        symbol: {
          type: "simple-line", // autocasts as new SimpleLineSymbol
          style: "short-dot",
          width: 3.5,
          color: "yellow"
        }
      });
    }
    return null;
  }

  // Get the last segment of the polyline that is being drawn
  function getLastSegment(polyline) {
    const line = polyline.clone();
    const lastXYPoint = line.removePoint(0, line.paths[0].length - 1);
    const existingLineFinalPoint = line.getPoint(0, line.paths[0].length - 1);

    return {
      type: "polyline",
      spatialReference: view.spatialReference,
      hasZ: false,
      paths: [[[existingLineFinalPoint.x, existingLineFinalPoint.y], [lastXYPoint.x, lastXYPoint.y]]]
    };
  }
});