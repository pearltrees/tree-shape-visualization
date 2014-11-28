package com.broceliand.ui.pearlTree
{
   import com.broceliand.graphLayout.controller.IPearlTreeEditionController;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.ui.interactors.IActive;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   
   import mx.core.IFlexDisplayObject;
   
   public interface IPearlTreeViewer extends IFlexDisplayObject, IActive
   {

      function get vgraph ():IPTVisualGraph;		
      function get pearlTreeEditionController():IPearlTreeEditionController;
      function get interactorManager():InteractorManager;
      function get pearlRendererStateManager():PearlRendererStateManager;
      function init():void;

      function refresh():void;
      
   }
}