# Tree Shape Visualization

## Presentation
With this project we open-source key visualization modules from our 1.6 "tree shape" version.

![Alt text](/readme/pearltrees.png?raw=true "1.6 Tree Shape Visualization")

## Overview
This project details the key visualization modules from our 1.6 "tree shape" version:

* tree structure visualization
* animations
* nodes and trees interactions
* data model

#### Visualization
In this project, we implement a simple and ergonomic tree structure visualization. The
Ravis library is extended to create our customized tree representation and 
layout. Automatic organization algorithms are implemented to balance nodes around 
trees and reorganize them in order to have simple and appealing layouts. We also
use the tree-shape-visualization-assets-box project to shape our nodes. This allows us to give a unique 
representation for each type of node; trees, aliases, teams, pages,
notes, photos and documents have all their own mask and decoration.


#### Animations
In the Tree Shape Visualization, nodes manipulation is a key feature, and animations are necessary to
enhance the user experience. Animations have been implemented for many manipulations
among them:
* adding a new node
* opening a new tree
* either zooming in or zooming out
* flinging a node
* detaching a branch from a tree
* selecting several nodes and moving them around or positioning them in your dock
* etc...


#### Interactions
Interaction classes allow to dynamically edit, move, delete nodes and trees.
There are many interactors in the Tree Shape Visualization. Each interactor will handle specific gestures
on the user interface:

* PearlDetachmentInteractor handles the gesture of separating a node from another one
or from a tree.
* DraggingOnStringInteractor allows moving a node along a line
* DragIntoTreeInteractor allows to move dragged nodes into a tree
* EmptyTreeOpenerInteractor opens a tree while dragging nodes and placing them
long enough above an empty tree
* DropZoneInteractor allows to move nodes from and to the user's dock
* etc...

For each of these interactors, we also set rules to allow or forbid user interactions 
with nodes. For instance, dragging a node into a tree that has too many nodes is not
allowed.

#### Data Model
The data model used in Tree Shape Visualization is the skeleton of our tree representation. We distinguish two types
of nodes: the trees and the (simple) nodes ; and each one of these types has several subtypes. Nodes for
instance, can either be pages (website urls), notes, photos or files while trees can be trees
or aliases (which are links to other existing trees). In this project, we only provide the client-side
data model for the nodes (you can find it in the AssociationData, OwnerData, PearlData, TreeData, TreeEditoData
and UrlData classes). You can use this model to implement your own server that will communicate 
with the client and store data relative to your nodes. Following our data model, you could create for instance, 
a simplified "pearl" table in your SQL database with the following attributes: pearlId (id of the current node), 
treeId (id of the parent tree of the current node), title, urlID (id of the UrlData relative to your node) 
and ownerId (id of the user who owns the node).


## Requirements
This example requires:

* the Ravis library that can be found [here](https://code.google.com/p/birdeye/wiki/RaVis).
* the tree-shape-visualization-assets-box library that can be found [here] (https://github.com/pearltrees/tree-shape-visualization-assets-box)

## Setting up project and components

#### Library
This is a Flex 3.5 project and is compiled using playerglobal.swc for 10.1. You can
download it in the following [zip file](/readme/Playerglobal.10.1.zip) and replace the existing
file in {YOUR_FLASH_BUILDER_PATH}\sdks\3.5\frameworks\libs\player\10\playerglobal.swc

#### Ravis Project Import
Ravis is the library used for the visualization of our tree organization. You need to
import it as a separate project in your workspace. You can find it [here](https://code.google.com/p/birdeye/wiki/RaVis).

#### Tree Shape Visualization Assets Box Project Import
tree-shape-visualization-assets-box project is necessary to get the assets used in the layout of our nodes.
Therefore, you also need to import it as a separate project in your workspace. You
can find it [here] (https://github.com/pearltrees/tree-shape-visualization-assets-box).

#### Tree Shape Visualization
You finally need to import the tree-shape-visualization in your workspace and add the above
Ravis and tree-shape-visualization-assets-box projects in your Library Path. 

#### Tree Shape Example
tree-shape-example is a separate project that can be found [here](https://github.com/pearltrees/tree-shape-example), it is an example
code to easily draw a tree and its nodes. Here is an example output tree representation that
you can make with it:

![Alt text](/readme/pearlExample.png?raw=true "Example Basic Tree Shape Visualization")

## License

The MIT License (MIT)

Copyright (c) 2014, Broceliand SAS, Paris, France (company in charge of developing Pearltrees).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Contacts

You can contact us at contact@pearltrees.com
