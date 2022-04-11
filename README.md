# tree-growth
tree-growth is a simple program for simulating the growth of branches. Branches are line segments that grow progressively longer over time before randomly branching into new line segments that grow in different directions. When branches collide, they stop growing. Branch growth appears as shown below:

<img src="https://github.com/r-franks/tree-growth/blob/main/branches.png" height=75% width=75%>

## The User-Interface
Branches can be created by clicking the left or right mouse button somewhere on the active screen. All branches can be deleted from the screen by pressing <code>backspace</code>. The fidelity/crispness of the rendered branches can be improved by tapping the <code>space bar</code>, and is not done automatically for the sake of optimization.

## Efficiency Optimizations
### Fast Rendering
Unlike many canvas/drawing frameworks, <code>processing.js</code> will persist the appearance of a rendered frame to the following frame unless overwritten. Therefore, tree branches that have stopped growing and appear as permanent fixtures on the canvas (either because they have collided with another branch or randomly split into new branches) can simply be persisted to the next frame without being re-rendered. This radically reduces the number of objects that need to be rendered per frame and substantially accelerates performance.

However, one drawback of persisting the images drawn on previous frames to new frames is that growing branches (which still need to be updated) will be redrawn over images of themselves. The new renderings interact with their previous renderings due to aliasing of line-segments, creating a somewhat rough/fuzzy appearance. This can be fixed by pressing <code>space-bar</code>, which clears the Canvas and redraws all branches from scratch so there are no interactions. Note that <code>space-bar</code> can be pressed as branches are growing, which can result in an interesting effect where non-growing branches mostly look crisp but a perimeter of growing branches looks rough.

### Collision Handling via Binning
When a branch is growing, it must check to see if its new growth will collide with another branch before proceeding. If it collides, it must stop growing. The naive way to do this collision handling is to check whether each new growth intersects with any other branch (which has quadratic complexity in number of branches). However, these new growths are extremely tiny as branches only grow a few pixels in length each frame. This makes them extremely unlikely to interact with the vast majority of other branches.

Thus a binning strategy has been implemented instead. The two-dimensional space is split-up into many tiny squares which each retain a list of every branch that passes through it. To check whether a new growth collides with other branches, one can just determine which bins the new growth passes through and check collisions between the new growth and all other branches in the associated bins. Because the new growth is so small, it usually occupies very few bins.

Furthermore, the bin-updating strategy is also efficient. As a branch grows, it is progressively added to more bins as its new growth passes through them. Checking whether a new growth passes through a bin is done using a variant of the <a href="http://eugen.dedu.free.fr/projects/bresenham/">Bresenham-based supercover line algorithm</a> since the new growth defines a line and the bins define a two-dimensional grid.
