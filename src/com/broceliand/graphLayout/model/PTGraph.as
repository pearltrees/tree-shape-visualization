/* 
* The MIT License
*
* Copyright (c) 2014 , Broceliand SAS, Paris, France (company in charge of developing Pearltrees)
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

/* 
* The MIT License
*
* Copyright (c) 2007 The SixDegrees Project Team
* (Jason Bellone, Juan Rodriguez, Segolene de Basquiat, Daniel Lang).
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

package com.broceliand.graphLayout.model
{
   import com.broceliand.pearlTree.model.BroCoeditDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroCoeditLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.util.Assert;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.Edge;
   import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   import org.un.cava.birdeye.ravis.graphLayout.data.Node;
   
   public class PTGraph extends Graph implements IPTGraph {
      
      private static const TRACE_DEBUG:Boolean = false;
      
      public function PTGraph(id:String, directional:Boolean = false, xmlsource:XML = null):void {
         super(id, directional, xmlsource);
      }

      override public function createNode(sid:String = "", o:Object = null):INode {
         
         /* we allow to pass a string id, e.g. it can originate
         * from the XML file.*/
         
         var myid:int = ++_currentNodeId;
         var mysid:String = sid;
         var myNode:Node;
         var myaltid:int = myid;
         
         if(mysid == "") {
            mysid = myid.toString();
         }
         
         /* avoid using a duplicate string id */
         while(_nodesByStringId.hasOwnProperty(mysid)) {
            if(TRACE_DEBUG) trace("sid: "+mysid+" already in use, trying alternative");
            mysid = (++myaltid).toString();
         }
         
         /* 
         * see below when we link nodes, we cannot yet 
         * set the visual counterpart, but we have setter/getters
         * for the attribute, have to consider which
         * component must be created first
         * consider also to just pass it to the abstract graph
         * but more likely, we initialise the abstract graph
         * from a graphML XML file, when it is there, then we build
         * all the visual objects 
         */
         
         if (o is BroPearlTree) {
            myNode = new EndNode(myid,mysid,null, o as BroPearlTree);
         } else if((o is BroPTRootNode) || 
            (o is BroLocalTreeRefNode) || 
            (o is BroCoeditLocalTreeRefNode)) {
            myNode = new PTRootNode(myid,mysid,null, o as BroPTNode);
         } else if (o is BroPageNode){
            myNode = new PageNode(myid,mysid,null,o as BroPageNode);
         }else if(o is BroDistantTreeRefNode){
            myNode = new DistantTreeRefNode(myid,mysid,null,o as BroDistantTreeRefNode);
         }
         _nodes.unshift(myNode);
         _nodesByStringId[mysid] = myNode;
         _nodesById[myid] = myNode;
         ++_numberOfNodes;
         
         /* a new node means all potentially existing
         * trees in the treemap need to be invalidated */
         purgeTrees()
         
         return myNode;
      }
      
      public function linkAtIndex(node1:IPTNode, node2:IPTNode, index:int,  o:Object = null):IEdge {
         
         var retEdge:IEdge;
         
         if(node1 == null) {
            throw Error("link: node1 was null");
         }
         if(node2 == null) {
            throw Error("link: node2 was null");
         }
         
         /* check if a link already exists */
         if(node1.successors.indexOf(node2) != -1) {
            /* we should give an error message, but
            * there is no need to abort the script
            * we should just do nothing */
            trace("Link between nodes:"+node1.id+" and "+
               node2.id+" already exists, returning existing edge");
            
            /* oh in fact, we should return the edge that was found 
            * this was more complicated than I thought and I am
            * not tooo happy with this way...
            * also it might not always find the edge if graph is non-directional
            * as most graphs are. The edge found could be the other way round.
            * Have to use the "othernode()" method here.
            */
            var outedges:Array = node1.outEdges;
            for each (var edge:IEdge in outedges) {
               if(edge.othernode(node1) == node2) {
                  retEdge = edge;
                  break;
               }
            }
            if(retEdge == null) {
               throw Error("We did not find the edge although it should be there");
            }
         } else {
            
            var newEid:int = ++_currentEdgeId;
            /* not sure where we will be able to set the visual edge
            * as it must exist first, for now we pass null 
            * since the attribute has also a setter */
            var newEdge:Edge = new Edge(this,null,newEid,node1,node2,o);
            _edges.unshift(newEdge);
            ++_numberOfEdges;
            
            /* now register the edge with its nodes */
            node1.addOutEdgeAtIndex(newEdge, index);
            node2.addInEdge(newEdge);
            
            /* if we are a NON directional graph we would have
            * to add another edge also vice versa (in the other
            * direction), but that leaves us with the question
            * which of the edges to return.... maybe it can be
            * handled using the same edge, if the in the directional
            * case, the edge returns always the other node */
            
            if(!_directional) {
               node1.addInEdge(newEdge);
               node2.addOutEdge(newEdge);

            }
            retEdge = newEdge;
         }
         purgeTrees()
         return retEdge;
         
      }
      
   }
   
}