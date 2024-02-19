# B-spline editor
Simple educational tool in which you can edit a B-spline evaluated with the De Boor - Cox algorithm.

## Overview
The spline is highly customizable. You can edit the degree and resolution, as well as the position of control points, and see the changes to the curve in real time.
There are several knot generators you may use. Clamped ones guarantee the curve to pass through the first and last control points.
You can even edit the knot vector without worrying about breaking anything. You can type into the vector and new values will get sorted automatically.
The knots highlighted in blue define the extremes of the evaluation range.
The control points are fixed to ten due to the demo's purpose.
## Controls
  * Left mouse button to drag control points around and to interact with the UI.
  * Right mouse button, or left mouse button while keeping ctrl pressed, to pan the viewport around.
