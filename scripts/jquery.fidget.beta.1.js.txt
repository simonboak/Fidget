/**********************************************************************

Fidget - Add multi-touch gestures to your mobile site or webapp

Public Beta 1 - 20 Dec 2011

Copyright (c) 2011 Simon Boak, http://www.simonboak.co.uk/fidget/

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
**********************************************************************/


(function($) {
	$.fn.extend({
		fidget: function(options) {
			
			// If no object is given then exit
			if (!this) return false;
			
			// Get the default properties and update with set properties
			var defaults = {
				swipe: null,
				dragThis: false,
				pinch: null,
				zoomThis: false,
				threshold: 20,
				tap: null,
				doubleTap: null
			};
			options = $.extend(defaults, options);
			
			
			
			// Make the fidget object
			var fidget;
			resetFidget(); // Applies the defaults
			
			
			
			// Internal
			var startTime, dx, dy, top, left;

			
			
			
			return this.each(function() {
				var $this = $(this); // Not sure if I need this line? What's it do?
				
				// Attach the event handlers for each item
				this.addEventListener("touchstart", fidgetStart, false);
				this.addEventListener("touchmove", fidgetMove, false);
				this.addEventListener("touchend", fidgetEnd, false);
				this.addEventListener("touchcancel", fidgetCancel, false);
				
				
				
				
				
				
				// Trigger for touchstart
				function fidgetStart(event) {
					event.preventDefault();
					
					// Set the start fingers from the event
					// We have to clone the object as event is always a reference to the touch object
					// Answer from: http://stackoverflow.com/questions/122102/what-is-the-most-efficient-way-to-clone-a-javascript-object
					fidget.startFingers = jQuery.extend(true, {}, event.touches);
					
					
					// Call swipe with status start regardless of the number of fingers
					fidget.swipe.status = 'start';
					callSwipeHandler();
					
					
					// If 2 or more fingers then consider a pinch
					if (event.touches.length > 1) {
						fidget.pinch.status = 'start';
						fidget.pinch.startDistance = calculateDistance();
						fidget.pinch.distance = calculateDistance();
						callPinchHandler();
					}
					
					
					// Call the tap event
					fidget.tap.status = 'down';
					fidget.tap.target = event.changedTouches[0].target;
					callTapHandler();
					
					
					// Set the gesture start time
					startTime = new Date().getTime();
				}
				
				
				
				
				
				// Trigger for touch move
				function fidgetMove(event) {
					event.preventDefault();
					
					// Change the swipe event status
					fidget.swipe.status = 'move';				
					fidget.swipe.distance = calculateSwipeDistance();
					
					
					// Change the pinch event status, but only if there are 2+ fingers
					if (event.touches.length > 1) {
						fidget.pinch.status = 'move';
						fidget.pinch.distance = calculateDistance();
						
						if (fidget.pinch.distance > fidget.pinch.startDistance)
							fidget.pinch.direction = 'out';
						if (fidget.pinch.distance < fidget.pinch.startDistance)
							fidget.pinch.direction = 'in';
						
						fidget.pinch.angle = calculateAngle();
						
						
						callPinchHandler();
					}
					
					// Set the generic properties	
					fidget.duration = calculateDuration();	
					
					// Call the swipe handler
					callSwipeHandler();
				}
				
				
				
				
				
				// Trigger for touch end
				function fidgetEnd(event) {
					event.preventDefault();
					
					// Change the swipe event status
					fidget.swipe.status = 'end';
					
					// Change the pinch event status
					if ((fidget.pinch.status == 'start') || (fidget.pinch.status == 'move')) {
						fidget.pinch.status = 'end';
						callPinchHandler();
					}
					
					// Check if the swipe should have momemtum
					// If the time since last move was less than 0.1s
					if ((fidget.duration - new Date().getTime()) < 300 ) {
						fidget.swipe.shouldHaveMomentum = true;
					}
					
					callSwipeHandler();
					
					
					
					// Call the tap event
					// Only a true tap if the finger is still over the same element
					if (fidget.tap.target == event.changedTouches[0].target) {
						fidget.tap.status = 'up';
					} else {
						fidget.tap.status = 'cancel'
					}
					callTapHandler();
					
					
					
					//resetFidget();
				}
				
				
				
				
				
				// Trigger for touch cancel
				function fidgetCancel(event) {
					event.preventDefault();
					
					// Change the event status
					fidget.swipe.status = 'cancel';
					fidget.pinch.status = 'cancel';
					
					callSwipeHandler();
					callPinchHandler();
					//resetFidget();
				}
				
				
				
				
				
				
				
				
				// Controls the calling of set event handlers (i.e. not null)
				function callSwipeHandler() {
					fidget.swipe.direction = 'up';
										
					// If dragThis is true, then automatically move the element around.
					if (fidget.swipe.status == 'start') {
						fidget.startPosition = {
							x: parseInt($this.css('left'), 10),
							y: parseInt($this.css('top'), 10)
						}
					}
					
					if (defaults.dragThis && (fidget.swipe.status == 'move')) {

						
						dx = event.touches[0].pageX - fidget.startFingers[0].pageX;
						dy = event.touches[0].pageY - fidget.startFingers[0].pageY;
						
						
						top = fidget.startPosition.y + dy + 'px';
						left = fidget.startPosition.x + dx + 'px';
						
						
						$this.css('top', top);
						$this.css('left', left);
						
					}
					
					// Then call the function
					if (defaults.swipe)
						defaults.swipe.call($this, event, fidget);
				}
				
				
				function callPinchHandler() {
					if (defaults.pinch) {
						if (defaults.zoomThis) {
							var zoomFactor = calculateDistance() / fidget.pinch.startDistance;
							//console.log(fidget.pinch.distance + ' ' + calculateDistance());
							$this.css('webkitTransform', 'scale(' + zoomFactor + ')');
						}
						defaults.pinch.call($this, event, fidget);
					}
				}
				
				
				function callTapHandler() {
					if (defaults.tap)
						defaults.tap.call($this, event, fidget);
				}
				
				
				
				
				
				
				
				
				
				// Current delta of start and current fingers
				function calculateSwipeDistance() {
					//fidget.swipe.distance.x = event.touches[0].pageX - fidget.startFingers[0].pageX;
					//fidget.swipe.distance.y = event.touches[0].pageY - fidget.startFingers[0].pageY;
					return {
						x: event.touches[0].pageX - fidget.startFingers[0].pageX,
						y: event.touches[0].pageY - fidget.startFingers[0].pageY
					};
				}
				
				
				
				// Update the duration value of the gesture in milliseconds 
				function calculateDuration() {
					return new Date().getTime() - startTime;
				}
				
				
				
				// Get the distance between the current first 2 fingers
				function calculateDistance() {
					if (event.touches.length > 1) {
						var dx = event.touches[0].pageX - event.touches[1].pageX;
						var dy = event.touches[0].pageY - event.touches[1].pageY;
						
						return Math.round(Math.sqrt(dx*dx + dy*dy));
					}
				}
				
				
				
				// Get the angle between the first 2 fingers
				function calculateAngle() {
					return Math.cos((event.touches[0].pageY - event.touches[1].pageY) / fidget.pinch.distance);
				}
				
				
				
				
				
			}); // End return each
			
			
			
			
			
			
			
			
			// Reset event properties after end or cancel
			function resetFidget() {
				startFingers = null;
				currentFingers = null;
				swipeEventStatus = '';
				pinchEventStatus = '';
				shouldHaveMomentum = false;
				
				fidget = {
					startFingers: null,
					currentFingers: null,
					duration: 0,
					startPosition: null,
					swipe: {	
						status: '',
						distance: {x: 0, y: 0},
						direction: '',
						shouldHaveMomentum: false		
					},
					pinch: {
						status: '',
						startDistance: 0,
						distance: 0,
						direction: 'unknown',
						angle: 0
					},
					tap: {
						status: '',
						target: null
					},
					doubleTap: {
						status: '',
						target: null
					}
				};
			}
			
			
			
			
			
			// Remove the events from the element
			function removeEvents(element) {
				element.removeEventListener();
				element.removeEventListener();
				element.removeEventListener();
				element.removeEventListener();
			}
			
			
			
			
			
			
			
			
		}
	})
})(jQuery);
