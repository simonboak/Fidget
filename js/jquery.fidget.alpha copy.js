(function($) {
	
	$.fn.fidget = function(options) {
		
		// Cancel if no object was supplied
		if (!this) return false;
		
		
		// Defaults
		var defaults = {
			swipe: null
		}
		
		
		if (options)
			$.extend(defaults, options);
		
		
		// Fidget Object Properties
		
		
		
		
		
		
		function fidgetStart() {
			
			// Attach swipe start
			//if (options.swipe)
			//	swipeStart();
			
		}
		
		
		
		
		
		
		
		
		
		/* =============== Swipe Functions ==================== */
		
		function swipeStart() {
			
			
			
		}
		
		
		
		
		
		// Add gestures to all swipable areas if supported
		try {
			this.addEventListener("touchstart", fidgetStart, false);
			this.addEventListener("touchmove", fidgethMove, false);
			this.addEventListener("touchend", fidgetEnd, false);
			this.addEventListener("touchcancel", fidgetCancel, false);
		}
		catch(e) {
			// Touch not supported
		}
	
	}

})(jQuery);