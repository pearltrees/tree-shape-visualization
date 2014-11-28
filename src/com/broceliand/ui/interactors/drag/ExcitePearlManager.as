package com.broceliand.ui.interactors.drag
{
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   
   public class ExcitePearlManager
   {
      
      protected var _pearlRendererStateManager:PearlRendererStateManager= null;
      
      private var _excitedPearl:IUIPearl;
      
      public function ExcitePearlManager(pearlRendererStateManager:PearlRendererStateManager) {
         _pearlRendererStateManager = pearlRendererStateManager;
      }
      internal function excitePearl(pearl:IUIPearl, showButtons:Boolean = true):void  {
         if (_excitedPearl != pearl) {
            relaxPearl(_excitedPearl);
         }
         _excitedPearl = pearl;
         _pearlRendererStateManager.excitePearlRenderer(pearl, false, showButtons);
         
      }
      internal function relaxPearl(pearl:IUIPearl):void {
         if (_excitedPearl == pearl) {
            _excitedPearl = null;
         }
         if (pearl) {
            _pearlRendererStateManager.relaxPearlRenderer(pearl);
         }
      }
      internal function relaxAllPearls():void {
         relaxPearl(_excitedPearl);
      }
      
   }
}